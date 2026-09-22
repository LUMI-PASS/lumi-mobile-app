import 'dart:math' show cos, min, pi, pow;

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/map_marker_bitmap.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/category_picker_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// The map itself — a full-bleed map of the centres the current search
/// matches, with the search screen's own controls floating over it.
///
/// Shared by two screens, which differ only in their furniture:
///   • the **Map tab** (`MapPage`) — no back button;
///   • the **pushed** "На карте" screen (`BranchesMapPage`), reached from the
///     search results, which has a back button.
///
/// Every control writes to the screen's own [SearchCubit], so the pins follow
/// the search exactly as the results grid does: the term, the category, and
/// the filter sheet. The class-level filters (age, price, date, district, …)
/// describe a class rather than a centre — the cubit answers them by plotting
/// the centres that RUN a matching class, see
/// `SearchCubit._fetchBranchesFromClasses`.
class BranchesMapView extends StatefulWidget {
  const BranchesMapView({
    super.key,
    required this.branches,
    required this.branchesLoaded,
    required this.isLoading,
    required this.seed,
    required this.categories,
    required this.selectedCategories,
    required this.searchTerm,
    required this.filter,
    required this.filterCount,
    this.onBack,
  });

  final List<HomBranch> branches;
  final bool branchesLoaded;
  final bool isLoading;

  /// What the search screen already had loaded. It stands in only until this
  /// screen's own first fetch lands — after that it is stale (it predates any
  /// category the user picks here), so it must never be shown again.
  final List<HomBranch> seed;

  final List<HomCategory> categories;
  final List<HomCategory> selectedCategories;

  /// The live search term, so the field comes up carrying it.
  final String searchTerm;

  /// What the filter sheet opens on, and [filterCount] what its badge says.
  final FilterResult? filter;
  final int filterCount;

  /// Omit on the tab — there is nothing behind it to go back to.
  final VoidCallback? onBack;

  @override
  State<BranchesMapView> createState() => _BranchesMapViewState();
}

class _BranchesMapViewState extends State<BranchesMapView> {
  YandexMapController? _mapController;

  HomBranch? _selected;
  bool _mapReady = false;

  bool _locating = false;

  /// The rasterised pills currently on the map. Rebuilt asynchronously — Yandex
  /// placemarks take a bitmap, so markers cannot simply be produced inside
  /// `build`.
  ///
  /// These are handed to a [ClusterizedPlacemarkCollection] rather than plotted
  /// directly: the pills are ~160pt wide, so a city-dense result set overlaps
  /// into an unreadable wall at anything below street zoom.
  List<PlacemarkMapObject> _markers = const [];

  /// Distance in units below which two pills collapse into one bubble.
  static const _clusterRadius = 60.0;

  /// Clusters are shown at this zoom and below; above it every centre is drawn
  /// separately. Chosen to sit at [_maxFitZoom] so selecting a branch — which
  /// zooms to exactly that level — always lands on a real pill rather than
  /// leaving the user's pick swallowed by a bubble.
  static const _clusterMinZoom = 15;

  /// Guards against an older marker rebuild finishing after a newer one and
  /// putting stale pills back on the map.
  int _markerSync = 0;

  /// Signature (sorted ids) of the branch set the camera last fitted to. Guards
  /// against re-fitting on every cubit emit (loading toggles etc.) — the camera
  /// only re-fits when the actual set of centres changes.
  String? _fittedSig;

  static const _minZoom = 4.0;
  static const _maxZoom = 18.0;

  /// The old `CameraFit.bounds(maxZoom: 15)` — a lone centre, or a tight
  /// cluster, must not leave the camera zoomed to the building.
  static const _maxFitZoom = 15.0;

  /// …and the other end: however far apart the centres are, the map never
  /// OPENS further out than this.
  ///
  /// Fitting all of them literally is the wrong opening shot. Tashkent's
  /// centres span the whole city, so the fit lands high enough that every pill
  /// has collapsed into a cluster bubble — a screen of numbered circles, which
  /// says nothing about what is on and nothing about where. This is
  /// neighbourhood scale: street names readable, most pills drawn as pills.
  /// The outliers are a pinch away, and the count pill says how many there
  /// are in total.
  static const _minFitZoom = 13.5;

  /// Measures the floating controls at the top, so the camera fit can keep
  /// every pin out from under them — read live rather than added up from the
  /// widget sizes, which would drift the moment a label wraps or the system
  /// text scale changes.
  final GlobalKey _topControlsKey = GlobalKey();

  /// Same, for the selected centre's card over the bottom edge.
  final GlobalKey _cardKey = GlobalKey();

  /// Distance from the bottom of the screen to the top of whatever the host
  /// screen puts there (the nav pill on the tab, the safe area on the pushed
  /// screen). Written in [build]; read by the camera maths.
  double _bottomBase = 0;

  /// Clearance around a pin so its PILL fits on screen too, not just the
  /// coordinate it is anchored at.
  ///
  /// The pill hangs to the RIGHT of its point and is vertically centred on it
  /// (`BranchMarkerPainter` anchors at `Offset(bleed / width, 0.5)`), so the
  /// margin is deliberately lopsided: a pin on the right edge needs the pill's
  /// whole width behind it, a pin on the left needs almost nothing.
  static const _pillWidth = 160.0;
  static const _pillHalfHeight = 24.0;
  static const _edgeMargin = 12.0;

  /// Gap between the selected centre's card and whatever is below it — the
  /// nav pill on the tab, the screen edge on the pushed screen.
  double get _cardGap => 8.h;

  /// Flips once this screen's own fetch has landed. Until then the seed from
  /// the search screen stands in; after it, the seed is stale and the cubit is
  /// the only source — otherwise picking a category would flash the original
  /// unfiltered centres back onto the map mid-refresh.
  bool _everLoaded = false;

  /// Tashkent — the fallback camera when there is nothing to fit to. Shares the
  /// home feed's fallback so the two never drift to different "centres".
  static final _defaultCenter = Point(
    latitude: kTashkentCentre.lat,
    longitude: kTashkentCentre.lng,
  );

  /// Uzbekistan's bounding box, used only to drop coordinates the backend got
  /// wrong (0,0, swapped lat/lng, …). It is deliberately country-wide and not
  /// Tashkent-tight: a centre a few km outside the city is a real centre, and
  /// clipping to the city silently hid it from the map.
  static const _minLat = 37.0;
  static const _maxLat = 45.7;
  static const _minLng = 55.9;
  static const _maxLng = 73.2;

  /// The centres this screen should be showing right now.
  List<HomBranch> get _source {
    if (widget.branchesLoaded) return widget.branches;
    return _everLoaded ? widget.branches : widget.seed;
  }

  List<HomBranch> get _plottable => _source.where((b) {
        final lat = b.latitude;
        final lng = b.longitude;
        if (lat == null || lng == null) return false;
        return lat >= _minLat &&
            lat <= _maxLat &&
            lng >= _minLng &&
            lng <= _maxLng;
      }).toList();

  /// Stable signature of the current plottable set, so we only re-fit when the
  /// centres actually change (not on every rebuild).
  String get _sig {
    final ids = _plottable.map((b) => b.id ?? '').toList()..sort();
    return ids.join(',');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncMarkers());
  }

  @override
  void didUpdateWidget(covariant BranchesMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.branchesLoaded) _everLoaded = true;
    // Re-fit only when the actual set of centres changed (e.g. category
    // switched) — not on spurious cubit emits, which caused the camera to jump.
    if (_sig != _fittedSig) {
      // Map mode streams the centres in page by page, so a set change is not
      // necessarily a new search — keep the user's pick if it's still plotted.
      final selectedId = _selected?.id;
      if (selectedId == null || !_plottable.any((b) => b.id == selectedId)) {
        _selected = null;
      }
      _syncMarkers();
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitToBranches());
    }
  }

  void _onMapCreated(YandexMapController controller) {
    _mapController = controller;
    _mapReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _fitToBranches());
  }

  /// Rasterises a pill per plotted centre and swaps them onto the map.
  ///
  /// Bitmaps are memoised by (title, selected, dpr), so this is cheap on every
  /// call after the first — a selection change re-renders two pills, not all of
  /// them.
  Future<void> _syncMarkers() async {
    if (!mounted) return;
    final token = ++_markerSync;

    final branches = _plottable;
    final selectedId = _selected?.id;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    final built = <PlacemarkMapObject>[];
    for (var i = 0; i < branches.length; i++) {
      final branch = branches[i];
      final isSelected = branch.id != null && branch.id == selectedId;
      final bitmap = await BranchMarkerPainter.build(
        title: branch.title ?? '',
        isSelected: isSelected,
        devicePixelRatio: dpr,
      );
      built.add(
        PlacemarkMapObject(
          mapId: MapObjectId('branch_${branch.id ?? i}'),
          point: Point(
            latitude: branch.latitude!,
            longitude: branch.longitude!,
          ),
          // Defaults to 0.5 — without this every pill is half transparent.
          opacity: 1,
          // The selected pill draws over any neighbour it overlaps, which is
          // what the old code achieved by emitting it last.
          zIndex: isSelected ? 1 : 0,
          consumeTapEvents: true,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromBytes(bitmap.bytes),
              anchor: bitmap.anchor,
              scale: bitmap.scale,
            ),
          ),
          onTap: (_, __) => _select(branch),
        ),
      );
    }

    // A newer sync started while this one was awaiting — its result wins.
    if (!mounted || token != _markerSync) return;
    setState(() => _markers = built);
  }

  /// Gives a freshly formed cluster its bubble.
  ///
  /// MapKit hands us an appearance placemark carrying only an id and a point —
  /// no icon, and the usual 0.5 opacity — so without this every cluster would
  /// be an invisible hole where a group of centres used to be.
  Future<Cluster> _onClusterAdded(
    ClusterizedPlacemarkCollection self,
    Cluster cluster,
  ) async {
    if (!mounted) return cluster;
    final bitmap = await BranchMarkerPainter.buildCluster(
      count: cluster.size,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    return cluster.copyWith(
      appearance: cluster.appearance.copyWith(
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromBytes(bitmap.bytes),
            anchor: bitmap.anchor,
            scale: bitmap.scale,
          ),
        ),
      ),
    );
  }

  void _onClusterTap(ClusterizedPlacemarkCollection self, Cluster cluster) {
    _zoomIntoCluster(cluster);
  }

  /// Opens a cluster by fitting its members, then guaranteeing the camera ends
  /// up past [_clusterMinZoom].
  ///
  /// The guarantee is the point: centres at (or very near) the same coordinate
  /// produce a degenerate bounding box, so fitting alone would leave the camera
  /// where it was and the bubble would feel dead to the touch.
  Future<void> _zoomIntoCluster(Cluster cluster) async {
    final controller = _mapController;
    if (controller == null || cluster.placemarks.isEmpty) return;

    const animation = MapAnimation(duration: 0.3);
    final points = cluster.placemarks.map((p) => p.point).toList();
    final bounds = _boundsOf(points)!;
    final framed = _framed(bounds);

    if (framed != null) {
      await controller.moveCamera(
        CameraUpdate.newGeometry(Geometry.fromBoundingBox(framed)),
        animation: animation,
      );
      if (!mounted) return;
    }

    final cam = await controller.getCameraPosition();
    if (!mounted) return;
    // Below this the cluster would simply re-form and nothing would appear to
    // have happened — which is what a cluster of centres sharing one
    // coordinate (`framed == null`) would otherwise do every time.
    const floor = _clusterMinZoom + 1.0;
    if (cam.zoom >= floor) return;
    await _centreOn(
      controller,
      framed == null ? points.first : cam.target,
      floor.clamp(_minZoom, _maxZoom),
      animation: animation,
    );
  }

  // ─── Framing the camera ───────────────────────────────────────────────────
  //
  // MapKit fits a geometry edge-to-edge in the WHOLE map view, and this map is
  // full-bleed with controls floating on top of it. Fitting the raw bounds
  // therefore parks the outermost centres underneath the search bar and the
  // nav pill — on screen, but not visible.
  //
  // So the bounds handed to MapKit are grown first: by how much of the view
  // each overlay eats, converted into degrees, so that once the padded box
  // fills the view the REAL box lands exactly in the strip between them.
  // (`CameraUpdate.newGeometry` does take a `focusRect`, which would say this
  // directly — but it is specified in raw screen coordinates, and Android
  // wants physical pixels there while iOS wants points. This is the portable
  // version, and it is exact.)

  /// The map view's own size. Falls back to the window before first layout.
  Size get _viewport =>
      context.size ?? MediaQuery.sizeOf(context);

  /// Height of the controls floating over the top edge.
  double get _topObstruction =>
      (_topControlsKey.currentContext?.size?.height ?? 0) + _edgeMargin.h;

  /// Height of everything floating over the bottom edge: the host's own
  /// furniture, plus the selected centre's card when one is up.
  double get _bottomObstruction {
    final card = _selected == null
        ? 0.0
        : (_cardKey.currentContext?.size?.height ?? 0);
    return _bottomBase + (card > 0 ? card + _cardGap : 0) + _edgeMargin.h;
  }

  /// Longitude degrees per horizontal pixel at [zoom]: the projection is Web
  /// Mercator, so the world is `256 · 2^zoom` pixels wide for 360°.
  static double _lngPerPixel(double zoom) => 360 / (256 * pow(2, zoom));

  /// Latitude degrees per VERTICAL pixel near [lat]. Mercator stretches with
  /// latitude, so a pixel covers `cos(lat)` as many degrees north-south as it
  /// does east-west.
  static double _latPerPixel(double lat, double zoom) =>
      _lngPerPixel(zoom) * cos(lat * pi / 180).abs();

  /// How far north the camera must sit for a point to appear in the middle of
  /// the VISIBLE strip rather than the middle of the view.
  ///
  /// Positive when the top is more obstructed than the bottom: moving the
  /// camera north pushes the point down the screen, out from under the
  /// controls.
  double _bandOffsetLat(double lat, double zoom) =>
      ((_topObstruction - _bottomObstruction) / 2) * _latPerPixel(lat, zoom);

  /// Grows [box] by the obstructed margins, so fitting the result edge-to-edge
  /// lands [box] itself inside the visible strip.
  ///
  /// Returns null when the box is a single point (nothing to scale the margins
  /// against) — the callers handle that case with [_bandOffsetLat] instead.
  BoundingBox? _framed(BoundingBox box) {
    final viewport = _viewport;
    final top = _topObstruction;
    final bottom = _bottomObstruction;
    final left = _edgeMargin.w;
    final right = (_pillWidth + _edgeMargin).w;
    final pillHalf = _pillHalfHeight.h;

    final bandHeight = viewport.height - top - bottom - pillHalf * 2;
    final bandWidth = viewport.width - left - right;
    if (bandHeight <= 0 || bandWidth <= 0) return box;

    final latSpan = box.northEast.latitude - box.southWest.latitude;
    final lngSpan = box.northEast.longitude - box.southWest.longitude;
    if (latSpan <= 0 && lngSpan <= 0) return null;

    // Pixels per projected unit (one unit = one degree of longitude), taking
    // whichever axis binds — the same choice MapKit itself makes when it fits.
    final midLat = (box.southWest.latitude + box.northEast.latitude) / 2;
    final cosLat = cos(midLat * pi / 180).abs().clamp(0.05, 1.0);
    final byLng = lngSpan > 0 ? bandWidth / lngSpan : double.infinity;
    final byLat = latSpan > 0 ? bandHeight * cosLat / latSpan : double.infinity;
    final scale = min(byLng, byLat);
    if (!scale.isFinite || scale <= 0) return box;

    final lngPerPx = 1 / scale;
    final latPerPx = cosLat / scale;

    return BoundingBox(
      southWest: Point(
        latitude: box.southWest.latitude - latPerPx * (bottom + pillHalf),
        longitude: box.southWest.longitude - lngPerPx * left,
      ),
      northEast: Point(
        latitude: box.northEast.latitude + latPerPx * (top + pillHalf),
        longitude: box.northEast.longitude + lngPerPx * right,
      ),
    );
  }

  /// The bounding box of [branches]. Null for an empty list.
  BoundingBox? _boundsOf(List<Point> points) {
    if (points.isEmpty) return null;
    var minLat = points.first.latitude;
    var maxLat = minLat;
    var minLng = points.first.longitude;
    var maxLng = minLng;
    for (final point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }
    return BoundingBox(
      southWest: Point(latitude: minLat, longitude: minLng),
      northEast: Point(latitude: maxLat, longitude: maxLng),
    );
  }

  /// Centres the camera on [point] at [zoom], sitting it in the visible strip
  /// rather than the middle of the view.
  Future<void> _centreOn(
    YandexMapController controller,
    Point point,
    double zoom, {
    MapAnimation? animation,
  }) {
    return controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: point.latitude + _bandOffsetLat(point.latitude, zoom),
            longitude: point.longitude,
          ),
          zoom: zoom,
        ),
      ),
      animation: animation,
    );
  }

  /// Where the crowd is: the median latitude and longitude of [points].
  ///
  /// The median, not the bounding box's centre. A couple of centres out
  /// towards Chirchiq drag a mid-point into empty fields halfway there, and
  /// the opening shot would be of the fields; the median lands wherever most
  /// of the centres actually are.
  Point _medianPoint(List<Point> points) {
    final lats = points.map((p) => p.latitude).toList()..sort();
    final lngs = points.map((p) => p.longitude).toList()..sort();
    final mid = points.length ~/ 2;
    return Point(latitude: lats[mid], longitude: lngs[mid]);
  }

  Future<void> _fitToBranches() async {
    final controller = _mapController;
    if (!_mapReady || controller == null || !mounted) return;
    _fittedSig = _sig;

    final points = _plottable
        .map((b) => Point(latitude: b.latitude!, longitude: b.longitude!))
        .toList();

    final bounds = _boundsOf(points);
    if (bounds == null) {
      await _centreOn(controller, _defaultCenter, _minFitZoom);
      return;
    }

    final framed = _framed(bounds);

    // Every centre at (or very near) the same coordinate — there is no box to
    // fit, so this is a single pin and the zoom is ours to choose.
    if (framed == null) {
      await _centreOn(controller, points.first, _maxFitZoom);
      return;
    }

    await controller.moveCamera(
      CameraUpdate.newGeometry(Geometry.fromBoundingBox(framed)),
    );

    // The fit answers "how far out must I go to show every single one", and
    // that answer is only useful between these two bounds: closer than
    // [_maxFitZoom] is a picture of one building, further than [_minFitZoom]
    // is a picture of cluster bubbles. Outside them, hold the bound and look
    // at where the centres actually are.
    if (!mounted) return;
    final cam = await controller.getCameraPosition();
    if (!mounted) return;
    final clamped = cam.zoom.clamp(_minFitZoom, _maxFitZoom);
    if (clamped == cam.zoom) return;
    await _centreOn(controller, _medianPoint(points), clamped.toDouble());
  }

  /// Zooms in/out by [delta] around the current centre, clamped to the map's
  /// zoom range so the buttons can't drive it into empty grey space.
  ///
  /// Asynchronous where the `flutter_map` version was not: MapKit only reports
  /// its camera over the platform channel, so the current zoom has to be
  /// awaited before it can be clamped.
  Future<void> _zoomBy(double delta) async {
    final controller = _mapController;
    if (!_mapReady || controller == null) return;
    final cam = await controller.getCameraPosition();
    final zoom = (cam.zoom + delta).clamp(_minZoom, _maxZoom);
    if (zoom == cam.zoom) return;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(cam.copyWith(zoom: zoom)),
      animation: const MapAnimation(duration: 0.3),
    );
  }

  /// Centres the map on the device's location, requesting permission first.
  Future<void> _goToMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _showMsg('map_location_off'.tr());
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        _showMsg('map_location_denied'.tr());
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      final here = Point(latitude: pos.latitude, longitude: pos.longitude);
      // MapKit's own location layer replaces the hand-drawn dot the
      // `flutter_map` version used — it is the platform-standard puck, and it
      // keeps following the device instead of freezing at the fetched fix.
      await _mapController?.toggleUserLayer(visible: true);
      final controller = _mapController;
      if (controller == null) return;
      // Same framing as everything else: the puck lands in the strip between
      // the controls, not underneath the search bar.
      await _centreOn(controller, here, _maxFitZoom);
    } catch (_) {
      _showMsg('map_location_error'.tr());
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _select(HomBranch branch) {
    setState(() => _selected = branch);
    _syncMarkers();
    // After the frame that raises the card, so its measured height is part of
    // [_bottomObstruction] by the time the camera moves — otherwise the pin
    // would be centred first and covered by the card a frame later.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _zoomToSelected(branch);
    });
  }

  Future<void> _zoomToSelected(HomBranch branch) async {
    final controller = _mapController;
    if (controller == null) return;
    final cam = await controller.getCameraPosition();
    if (!mounted) return;
    // The card is already up by now, so [_bottomObstruction] counts it and the
    // pin lands above it rather than behind it.
    await _centreOn(
      controller,
      Point(latitude: branch.latitude!, longitude: branch.longitude!),
      cam.zoom < _maxFitZoom ? _maxFitZoom : cam.zoom,
      animation: const MapAnimation(duration: 0.3),
    );
  }

  void _clearSelection() {
    if (_selected == null) return;
    setState(() => _selected = null);
    _syncMarkers();
  }

  /// Opens the same filter sheet the results grid uses and applies what comes
  /// back. The pins are re-derived from it — see [BranchesMapView].
  Future<void> _openFilter() async {
    final cubit = context.read<SearchCubit>();
    final result = await FilterBottomSheet.show(
      context,
      initial: widget.filter,
    );
    if (result == null || !mounted) return;
    _clearSelection();
    cubit.applyFilter(result);
  }

  /// What the dropdown pill says: the generic label with nothing picked, the
  /// one title with a single pick, and the first title plus a "+N" count with
  /// several — spelling out every title would run the pill off the screen.
  String get _categoryLabel {
    final selected = widget.selectedCategories;
    if (selected.isEmpty) return 'categories'.tr();
    if (selected.length == 1) return selected.first.title ?? '';
    return '${selected.first.title ?? ''} +${selected.length - 1}';
  }

  /// Opens the categories list as a bottom sheet and applies what comes back.
  Future<void> _pickCategory() async {
    final cubit = context.read<SearchCubit>();
    final result = await CategoryPickerSheet.show(
      context,
      categories: widget.categories,
      selected: widget.selectedCategories,
    );
    // Null = dismissed without choosing; leave the current filter alone.
    if (result == null || !mounted) return;
    cubit.setCategories(result.categories);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = _selected;
    // What anything floating over the bottom edge has to clear.
    //
    // On the pushed screen that is the home indicator. On the TAB it is the
    // whole glass nav bar: the tabs scaffold runs with `extendBody: true`, and
    // Flutter's Scaffold then reports the bar's height here — including the
    // profile banner when that is up — instead of the bare system inset.
    // Stashed on the state so the camera maths can read it too, see
    // [_bottomObstruction].
    final bottomBase = MediaQuery.of(context).padding.bottom;
    _bottomBase = bottomBase;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      // Full bleed: the map is the screen, and the controls sit ON it. The old
      // layout boxed it into a rounded card under a column of controls, which
      // spent a third of the screen on chrome and left the pins crowded into
      // what was left.
      body: Stack(
        children: [
          Positioned.fill(
            child: YandexMap(
              onMapCreated: _onMapCreated,
              onMapTap: (_) => _clearSelection(),
              // Replaces the light/dark CartoDB tile URLs the `flutter_map`
              // version switched between.
              nightModeEnabled: c.isDark,
              mapObjects: [
                ClusterizedPlacemarkCollection(
                  mapId: const MapObjectId('branches'),
                  placemarks: _markers,
                  radius: _clusterRadius,
                  minZoom: _clusterMinZoom,
                  onClusterAdded: _onClusterAdded,
                  onClusterTap: _onClusterTap,
                ),
              ],
              cameraBounds: const CameraBounds(
                minZoom: _minZoom,
                maxZoom: _maxZoom,
              ),
              // Yandex's terms require the logo to stay visible, so it is
              // moved clear of the zoom controls and the bottom card rather
              // than hidden.
              logoAlignment: const MapAlignment(
                horizontal: HorizontalAlignment.left,
                vertical: VerticalAlignment.bottom,
              ),
              logoPadding: MapPadding(
                horizontal: 8.w.round(),
                vertical: (bottomBase + _cardGap).round(),
              ),
            ),
          ),

          // Filtering lives at the TOP of the screen: the map is what the user
          // is reading, and a strip of controls over its bottom edge covered
          // the very pins the camera had just fitted to.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Column(
                key: _topControlsKey,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.onBack != null) ...[
                    8.verticalSpace,
                    SearchTopBar(
                      title: 'map_title'.tr(),
                      onBack: widget.onBack,
                    ),
                  ],
                  12.verticalSpace,
                  // The search screen's own bar, filter badge and all: a map
                  // the user cannot narrow is a wall of pins.
                  SearchBarRow(
                    initialTerm: widget.searchTerm,
                    onChanged: context.read<SearchCubit>().setSearchTerm,
                    onFilterTap: _openFilter,
                    filterCount: widget.filterCount,
                  ),
                  12.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        if (widget.categories.isNotEmpty)
                          Flexible(
                            child: _CategoryDropdown(
                              label: _categoryLabel,
                              isActive: widget.selectedCategories.isNotEmpty,
                              onTap: _pickCategory,
                            ),
                          ),
                        const Spacer(),
                        // What the current search actually plots. On a map the
                        // count is the only honest feedback that a filter did
                        // anything — pins that vanish off-camera look like a
                        // map that simply moved.
                        _CountPill(
                          label: _plottable.isEmpty && !widget.isLoading
                              ? 'map_no_centres'.tr()
                              : 'map_centres_count'
                                  .tr(args: ['${_plottable.length}']),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (widget.isLoading && _markers.isEmpty)
            const Center(child: CircularProgressIndicator()),

          // The bottom furniture — zoom/locate controls riding above the
          // selected centre's card — laid out as ONE bottom-aligned column.
          //
          // Deliberately not two `Positioned`s with the buttons offset by the
          // card's height: that height can only be had by measuring the card,
          // and `Element.size` may not be read during a build. Stacking them
          // lets layout answer the question instead, and it stays right
          // whatever the card grows to (a long name, a larger text scale).
          Positioned(
            left: 8.w,
            right: 8.w,
            bottom: bottomBase + _cardGap,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // A Row, not an `Align`: this column is bottom-anchored in the
                // Stack, so its children are laid out with an unbounded
                // height — and an Align with no `heightFactor` tries to fill
                // that, which asserts. A Row simply takes its child's height.
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _MapButton(
                              icon: Icons.add_rounded, onTap: () => _zoomBy(1)),
                          8.verticalSpace,
                          _MapButton(
                              icon: Icons.remove_rounded,
                              onTap: () => _zoomBy(-1)),
                          12.verticalSpace,
                          _MapButton(
                            icon: Icons.my_location_rounded,
                            onTap: _goToMyLocation,
                            busy: _locating,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (selected != null) ...[
                  12.verticalSpace,
                  // The key is for the CAMERA, not this layout: the fit reads
                  // the card's height to keep pins out from under it, and it
                  // does that outside build where measuring is allowed.
                  _BranchCard(key: _cardKey, branch: selected),
                ] else
                  16.verticalSpace,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// How many centres the map is currently plotting.
class _CountPill extends StatelessWidget {
  const _CountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(48.r),
        border: Border.all(color: c.controlBorder),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.medium13.copyWith(color: c.textPrimary),
      ),
    );
  }
}

/// The map's category filter — a dropdown pill stating the active category.
///
/// A dropdown rather than the old chip strip: the categories list is long, and
/// a horizontally scrolling strip hid most of it behind a swipe the user had no
/// reason to suspect. Category is the map's only filter, so this is a single
/// pill hugging its label, not a row of controls. The list itself lives in
/// [CategoryPickerSheet].
class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = isActive ? Colors.white : c.textPrimary;

    // The row that lays this out owns the page margin — see
    // [BranchesMapView.build].
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        // Long category titles ellipsize rather than run the pill off the
        // screen. No `alignment` on the container below — an aligned
        // Container expands to its max constraint, which would hold the
        // pill at this width even for a one-word category.
        constraints: BoxConstraints(maxWidth: 260.w),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: isActive ? AppGradients.indigo : null,
            color: isActive ? null : c.control,
            borderRadius: BorderRadius.circular(48.r),
            border: isActive ? null : Border.all(color: c.controlBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.medium13.copyWith(color: fg),
                ),
              ),
              6.horizontalSpace,
              Assets.icons.arrowDown.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A round, theme-aware map control (zoom / locate).
class _MapButton extends StatelessWidget {
  const _MapButton({
    required this.icon,
    required this.onTap,
    this.busy = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: busy ? null : onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface,
          shape: BoxShape.circle,
          border: Border.all(color: c.controlBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: busy
            ? SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(c.primary),
                ),
              )
            : Icon(icon, size: 22.sp, color: c.textPrimary),
      ),
    );
  }
}

/// The raised card for the selected centre (Figma `Avatar` at the bottom).
class _BranchCard extends StatelessWidget {
  const _BranchCard({super.key, required this.branch});

  final HomBranch branch;

  String? get _imageUrl {
    final direct = sanitizeImageUrl(branch.image);
    if (direct != null) return direct;
    final id = branch.id;
    if (id != null && branch.hasPhoto == true) {
      return PhotoService.getImageUrl(id);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final imageUrl = _imageUrl;
    final address = branch.address ?? '';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.router.push(BranchDetailRoute(branch: branch)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: c.controlBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: 45.w,
                height: 45.w,
                child: imageUrl == null
                    ? Container(
                        color: c.control,
                        child: Icon(Icons.business_rounded,
                            size: 20.w, color: c.textPlaceholder),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Container(
                          color: c.control,
                          child: Icon(Icons.business_rounded,
                              size: 20.w, color: c.textPlaceholder),
                        ),
                      ),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    branch.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold16.copyWith(color: c.textPrimary),
                  ),
                  if (address.isNotEmpty) ...[
                    6.verticalSpace,
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.regular12.copyWith(color: c.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            // The card opens the branch — the arrow is what says so. Same
            // affordance the "view on map" row uses. The row is top-aligned for
            // the two-line caption, so the arrow is centred against the
            // thumbnail rather than pinned to the top of it.
            8.horizontalSpace,
            SizedBox(
              height: 45.w,
              child: Center(
                child: Assets.icons.arrowRight.svg(
                  width: 24.w,
                  height: 24.w,
                  colorFilter:
                      ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

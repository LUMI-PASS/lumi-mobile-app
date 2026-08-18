import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/map_marker_bitmap.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/photo_service.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// "На карте" — the centres of the current search plotted on a map (Figma
/// `На карте`).
///
/// Each centre is a labelled pill; tapping one raises its card at the bottom.
/// The category chips along the bottom re-query, which is why this screen
/// carries its own [SearchCubit] rather than a frozen list.
@RoutePage()
class BranchesMapPage
    extends BasePage<SearchCubit, SearchBuildable, SearchListenable> {
  const BranchesMapPage({
    super.key,
    this.branches = const [],
    this.categories = const [],
    this.selectedCategory,
  });

  /// Results already loaded by the search screen — shown immediately so the
  /// map isn't empty while the branches tab loads.
  final List<HomBranch> branches;
  final List<HomCategory> categories;
  final HomCategory? selectedCategory;

  @override
  void init(BuildContext context) {
    // `allBranches` — the map plots pins, so it needs every centre, not the
    // first page the list screens work through.
    context.read<SearchCubit>().init(
          tab: kSearchTabBranches,
          category: selectedCategory,
          allBranches: true,
        );
    super.init(context);
  }

  @override
  Widget builder(BuildContext context, SearchBuildable state) {
    final categories =
        state.categories.isEmpty ? this.categories : state.categories;

    return _BranchesMapView(
      branches: state.branches,
      branchesLoaded: state.branchesLoaded,
      isLoading: state.isLoading,
      seed: branches,
      categories: categories,
      selectedCategory: state.selectedCategory,
    );
  }
}

class _BranchesMapView extends StatefulWidget {
  const _BranchesMapView({
    required this.branches,
    required this.branchesLoaded,
    required this.isLoading,
    required this.seed,
    required this.categories,
    required this.selectedCategory,
  });

  final List<HomBranch> branches;
  final bool branchesLoaded;
  final bool isLoading;

  /// What the search screen already had loaded. It stands in only until this
  /// screen's own first fetch lands — after that it is stale (it predates any
  /// category the user picks here), so it must never be shown again.
  final List<HomBranch> seed;

  final List<HomCategory> categories;
  final HomCategory? selectedCategory;

  @override
  State<_BranchesMapView> createState() => _BranchesMapViewState();
}

class _BranchesMapViewState extends State<_BranchesMapView> {
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

  /// Stands in for the old `padding: EdgeInsets.all(56.w)` on the camera fit.
  /// MapKit fits a geometry edge-to-edge, so the equivalent is to back off by a
  /// fraction of a zoom level afterwards. (`CameraUpdate.newGeometry` does take
  /// a `focusRect`, which would be exact — but it is specified in raw screen
  /// pixels, and Android and iOS disagree about whether those are physical
  /// pixels or points. This is the portable version.)
  static const _fitPaddingZoom = 0.35;

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
  void didUpdateWidget(covariant _BranchesMapView oldWidget) {
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

    final points = cluster.placemarks.map((p) => p.point).toList();
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

    const animation = MapAnimation(duration: 0.3);
    final degenerate = maxLat - minLat < 1e-6 && maxLng - minLng < 1e-6;

    if (!degenerate) {
      await controller.moveCamera(
        CameraUpdate.newGeometry(
          Geometry.fromBoundingBox(
            BoundingBox(
              southWest: Point(latitude: minLat, longitude: minLng),
              northEast: Point(latitude: maxLat, longitude: maxLng),
            ),
          ),
        ),
        animation: animation,
      );
      if (!mounted) return;
    }

    final cam = await controller.getCameraPosition();
    if (!mounted) return;
    // Below this the cluster would simply re-form and nothing would appear to
    // have happened.
    const floor = _clusterMinZoom + 1.0;
    if (cam.zoom >= floor) return;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        cam.copyWith(
          zoom: floor.clamp(_minZoom, _maxZoom),
          target: degenerate ? points.first : cam.target,
        ),
      ),
      animation: animation,
    );
  }

  Future<void> _fitToBranches() async {
    final controller = _mapController;
    if (!_mapReady || controller == null || !mounted) return;
    _fittedSig = _sig;

    final branches = _plottable;

    if (branches.isEmpty) {
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _defaultCenter, zoom: 12),
        ),
      );
      return;
    }

    if (branches.length == 1) {
      await controller.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: Point(
              latitude: branches.first.latitude!,
              longitude: branches.first.longitude!,
            ),
            zoom: _maxFitZoom,
          ),
        ),
      );
      return;
    }

    var minLat = branches.first.latitude!;
    var maxLat = minLat;
    var minLng = branches.first.longitude!;
    var maxLng = minLng;
    for (final branch in branches) {
      final lat = branch.latitude!;
      final lng = branch.longitude!;
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lng < minLng) minLng = lng;
      if (lng > maxLng) maxLng = lng;
    }

    await controller.moveCamera(
      CameraUpdate.newGeometry(
        Geometry.fromBoundingBox(
          BoundingBox(
            southWest: Point(latitude: minLat, longitude: minLng),
            northEast: Point(latitude: maxLat, longitude: maxLng),
          ),
        ),
      ),
    );

    // Back off to stand in for the old fit padding, and hold the old maxZoom.
    if (!mounted) return;
    final cam = await controller.getCameraPosition();
    final zoom =
        (cam.zoom - _fitPaddingZoom).clamp(_minZoom, _maxFitZoom);
    if (zoom == cam.zoom || !mounted) return;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(cam.copyWith(zoom: zoom)),
    );
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
      await _mapController?.moveCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: here, zoom: _maxFitZoom),
        ),
      );
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
    _zoomToSelected(branch);
  }

  Future<void> _zoomToSelected(HomBranch branch) async {
    final controller = _mapController;
    if (controller == null) return;
    final cam = await controller.getCameraPosition();
    if (!mounted) return;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: branch.latitude!,
            longitude: branch.longitude!,
          ),
          zoom: cam.zoom < _maxFitZoom ? _maxFitZoom : cam.zoom,
        ),
      ),
      animation: const MapAnimation(duration: 0.3),
    );
  }

  void _clearSelection() {
    if (_selected == null) return;
    setState(() => _selected = null);
    _syncMarkers();
  }

  void _selectCategory(int index) {
    final category = widget.categories[index];
    final cubit = context.read<SearchCubit>();
    // Tapping the active chip clears the filter.
    final isActive = widget.selectedCategory?.id == category.id;
    cubit.selectCategory(isActive ? null : category);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final selected = _selected;
    final activeIndex = widget.categories
        .indexWhere((cat) => cat.id == widget.selectedCategory?.id);

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            8.verticalSpace,
            SearchTopBar(
              title: 'map_title'.tr(),
              onBack: () => context.router.maybePop(),
            ),
            12.verticalSpace,
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: YandexMap(
                        onMapCreated: _onMapCreated,
                        onMapTap: (_) => _clearSelection(),
                        // Replaces the light/dark CartoDB tile URLs the
                        // `flutter_map` version switched between.
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
                        // Yandex's terms require the logo to stay visible, so it
                        // is moved clear of the zoom controls and the bottom
                        // card rather than hidden.
                        logoAlignment: const MapAlignment(
                          horizontal: HorizontalAlignment.left,
                          vertical: VerticalAlignment.bottom,
                        ),
                        logoPadding: MapPadding(
                          horizontal: 8.w.round(),
                          vertical: 72.h.round(),
                        ),
                      ),
                    ),
                  ),
                  if (widget.isLoading && _markers.isEmpty)
                    const Center(child: CircularProgressIndicator()),
                  // Zoom + locate controls, clear of the bottom chips/card.
                  Positioned(
                    right: 20.w,
                    bottom: MediaQuery.of(context).padding.bottom +
                        (selected != null ? 110.h : 84.h),
                    child: Column(
                      children: [
                        _MapButton(
                          icon: Icons.add_rounded,
                          onTap: () => _zoomBy(1),
                        ),
                        8.verticalSpace,
                        _MapButton(
                          icon: Icons.remove_rounded,
                          onTap: () => _zoomBy(-1),
                        ),
                        12.verticalSpace,
                        _MapButton(
                          icon: Icons.my_location_rounded,
                          onTap: _goToMyLocation,
                          busy: _locating,
                        ),
                      ],
                    ),
                  ),
                  // Category chips float over the bottom of the map.
                  if (widget.categories.isNotEmpty && selected == null)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: MediaQuery.of(context).padding.bottom + 16.h,
                      child: SearchChips(
                        labels: [
                          for (final cat in widget.categories) cat.title ?? '',
                        ],
                        activeIndex: activeIndex,
                        onSelect: _selectCategory,
                      ),
                    ),
                  if (selected != null)
                    Positioned(
                      left: 8.w,
                      right: 8.w,
                      bottom: MediaQuery.of(context).padding.bottom + 16.h,
                      child: _BranchCard(branch: selected),
                    ),
                ],
              ),
            ),
          ],
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
  const _BranchCard({required this.branch});

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
                      style:
                          AppText.regular12.copyWith(color: c.textSecondary),
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

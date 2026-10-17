import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lumi_pass/common/widget/segmented_slider_track.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/map_camera.dart';
import 'package:lumi_pass/common/utils/map_marker_bitmap.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/common/utils/user_location_puck.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// What [LocationFilterPage] hands back. A wrapper so "All" (a null
/// [radiusKm]) and "dismissed" (a null result) stay different answers.
class LocationFilterResult {
  const LocationFilterResult(this.radiusKm);

  /// Null = any distance.
  final double? radiusKm;
}

/// The radius stops, in km. The slider's last stop beyond these is "All".
const kRadiusStepsKm = <double>[0.25, 0.5, 1, 1.5, 2, 3, 5, 10];

/// Where a radius picked away from the map is measured from — the filter
/// sheet's "По расположению" row: the device when it can say and is in
/// Tashkent, else the middle of Tashkent, as the map does.
///
/// Asks for the permission when it was never asked: a parent picking "within
/// 1.5 km" is asking to be located. A refusal still lands on the city centre,
/// so the row is never a dead end.
Future<Point> radiusCentre() async {
  const cityRadiusM = 30000.0;
  final city = Point(
    latitude: kTashkentCentre.lat,
    longitude: kTashkentCentre.lng,
  );
  try {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm != LocationPermission.always &&
        perm != LocationPermission.whileInUse) {
      return city;
    }
    final pos = await Geolocator.getLastKnownPosition() ??
        await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            timeLimit: Duration(seconds: 8),
          ),
        );
    final metres = kTashkentCentre.metersTo(pos.latitude, pos.longitude);
    if (metres == null || metres > cityRadiusM) return city;
    return Point(latitude: pos.latitude, longitude: pos.longitude);
  } catch (_) {
    return city;
  }
}

/// "250 m", "1.5 km" — what the chip and the page both say for a radius.
String radiusLabel(double km) {
  if (km < 1) return 'map_radius_m'.tr(args: ['${(km * 1000).round()}']);
  final text = km == km.roundToDouble() ? '${km.toInt()}' : '$km';
  return 'map_radius_km'.tr(args: [text]);
}

/// The map's "By location" screen: the user's position with a circle of the
/// picked radius around it, the centres on the map for reference, and a
/// slider from 250 m to "All".
///
/// Pushed full-screen rather than shown as a sheet, because the point of it is
/// the map — the circle is how the user judges what "1.5 km" means here.
class LocationFilterPage extends StatefulWidget {
  const LocationFilterPage({
    super.key,
    required this.center,
    required this.branches,
    this.initialRadiusKm,
  });

  /// The user's position — what the radius is measured from.
  final Point center;

  /// The centres the map is showing, plotted as dots for reference.
  final List<HomBranch> branches;

  final double? initialRadiusKm;

  static Future<LocationFilterResult?> show(
    BuildContext context, {
    required Point center,
    required List<HomBranch> branches,
    double? initialRadiusKm,
  }) {
    return Navigator.of(context).push<LocationFilterResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LocationFilterPage(
          center: center,
          branches: branches,
          initialRadiusKm: initialRadiusKm,
        ),
      ),
    );
  }

  @override
  State<LocationFilterPage> createState() => _LocationFilterPageState();
}

class _LocationFilterPageState extends State<LocationFilterPage> {
  YandexMapController? _controller;

  /// The centre dot's bitmap. Placemarks rather than map circles: a 40 m
  /// circle shrank to nothing once the slider zoomed out past a few km, so the
  /// centres vanished exactly when the user was judging a wide radius.
  MarkerBitmap? _dot;

  /// False until the opening camera is placed — MapKit starts on its own
  /// default view, which would otherwise flash first.
  bool _placed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_dot != null) return;
    BranchMarkerPainter.buildDot(
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    ).then((dot) {
      if (mounted) setState(() => _dot = dot);
    });
  }

  /// Index into [kRadiusStepsKm]; one past the end is "All".
  late int _step = _stepFor(widget.initialRadiusKm);

  /// 1.5 km when nothing is picked yet — a walk, which is what most parents
  /// mean by "near me".
  static int _stepFor(double? km) {
    if (km == null) return kRadiusStepsKm.indexOf(1.5);
    final i = kRadiusStepsKm.indexOf(km);
    return i < 0 ? kRadiusStepsKm.length : i;
  }

  bool get _isAll => _step >= kRadiusStepsKm.length;

  double? get _radiusKm => _isAll ? null : kRadiusStepsKm[_step];

  Future<void> _frame({bool animated = true}) async {
    final controller = _controller;
    if (controller == null) return;
    final km = _radiusKm;
    final update = km == null
        ? CameraUpdate.newCameraPosition(
            CameraPosition(target: widget.center, zoom: 11),
          )
        // A little wider than the circle, so its edge is not flush with the
        // view.
        : CameraUpdate.newGeometry(
            Geometry.fromCircle(
              Circle(center: widget.center, radius: km * 1000 * 1.15),
            ),
          );
    if (animated) {
      await controller.moveCamera(
        update,
        animation: const MapAnimation(duration: 0.25),
      );
      return;
    }
    // The opening frame, from onMapCreated — which can fire before the map
    // has a size, when MapKit drops the move and the page opened on the
    // whole world. Retried until it lands; see [moveCameraWhenSized].
    await moveCameraWhenSized(controller, update, isActive: () => mounted);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final km = _radiusKm;

    return Scaffold(
      backgroundColor: c.surface,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: SearchTopBar(
                title: 'map_by_location'.tr(),
                onBack: () => Navigator.of(context).pop(),
                close: true,
                // Back to "All". Apply still commits it, like the slider.
                trailing: _ResetButton(
                  enabled: !_isAll,
                  onTap: () {
                    setState(() => _step = kRadiusStepsKm.length);
                    _frame();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: YandexMap(
                    nightModeEnabled: c.isDark,
                    onUserLocationAdded: (view) => styleUserLocation(
                      view,
                      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                    ),
                    onMapCreated: (controller) async {
                      _controller = controller;
                      try {
                        await controller.toggleUserLayer(visible: true);
                        await _frame(animated: false);
                      } finally {
                        if (mounted) setState(() => _placed = true);
                      }
                    },
                    mapObjects: [
                      if (km != null)
                        CircleMapObject(
                          mapId: const MapObjectId('radius'),
                          circle:
                              Circle(center: widget.center, radius: km * 1000),
                          fillColor: c.primary.withValues(alpha: 0.15),
                          strokeColor: c.primary,
                          strokeWidth: 1.5,
                        ),
                      // Dots rather than the main map's name pills: here the centres
                      // are a reference for the circle, not something to read.
                      if (_dot case final dot?)
                        for (final b in widget.branches)
                          if (b.latitude != null && b.longitude != null)
                            PlacemarkMapObject(
                              mapId: MapObjectId('dot_${b.id}'),
                              point: Point(
                                latitude: b.latitude!,
                                longitude: b.longitude!,
                              ),
                              // Defaults to 0.5.
                              opacity: 1,
                              zIndex: 1,
                              icon: PlacemarkIcon.single(
                                PlacemarkIconStyle(
                                  image: BitmapDescriptor.fromBytes(dot.bytes),
                                  anchor: dot.anchor,
                                  scale: dot.scale,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      opacity: _placed ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      child: ColoredBox(color: c.surface),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              14.w,
              16.h,
              14.w,
              16.h + MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    text: '${'map_within'.tr()} ',
                    style: AppText.medium16.copyWith(color: c.textSecondary),
                    children: [
                      TextSpan(
                        text: km == null
                            ? 'map_radius_all'.tr()
                            : radiusLabel(km),
                        style: AppText.semibold16.copyWith(color: c.primary),
                      ),
                    ],
                  ),
                ),
                8.kh,
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 6.h,
                    activeTrackColor: c.primary,
                    inactiveTrackColor: c.progressTrack,
                    overlayColor: c.primary.withValues(alpha: 0.12),
                    tickMarkShape:
                        const RoundSliderTickMarkShape(tickMarkRadius: 0),
                    // One piece per radius step, the same broken line the time
                    // filter draws.
                    trackShape: SegmentedSliderTrackShape(
                      segments: kRadiusStepsKm.length,
                    ),
                    thumbShape: RingedSliderThumb(color: c.primary),
                    showValueIndicator: ShowValueIndicator.never,
                  ),
                  child: Slider(
                    min: 0,
                    max: kRadiusStepsKm.length.toDouble(),
                    divisions: kRadiusStepsKm.length,
                    value: _step.toDouble(),
                    onChanged: (v) {
                      final step = v.round();
                      if (step == _step) return;
                      setState(() => _step = step);
                      _frame();
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        radiusLabel(kRadiusStepsKm.first),
                        style:
                            AppText.regular12.copyWith(color: c.textSecondary),
                      ),
                      Text(
                        'map_radius_all'.tr(),
                        style:
                            AppText.regular12.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
                20.kh,
                FilterSheetButton(
                  label: 'apply_button'.tr(),
                  gradient: AppGradients.brand,
                  onTap: () => Navigator.of(context)
                      .pop(LocationFilterResult(_radiusKm)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Reset" on the top bar, greyed while the radius is already "All".
class _ResetButton extends StatelessWidget {
  const _ResetButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Text(
          'map_reset'.tr(),
          style: AppText.semibold14.copyWith(
            color: enabled ? c.primary : c.textSecondary,
          ),
        ),
      ),
    );
  }
}

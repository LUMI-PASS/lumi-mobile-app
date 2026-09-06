import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/utils/map_marker_bitmap.dart';
import 'package:lumi_pass/common/widget/map_route_sheet.dart';

/// The venue on a map, as a short strip inside a detail card — class detail
/// and branch detail.
///
/// An address line answers "where is it?" only for a parent who already knows
/// the street. The strip answers it for everyone: the pin's neighbourhood, how
/// far in from a main road, which side of the city. It is a *preview*, not the
/// branches map — the full map screen is a different job (browse and compare
/// centres), and this one only has to place a single venue.
///
/// So it does not pan or zoom. The map view sits under an [IgnorePointer]:
/// gestures are handed straight back to the page's scroll view, which is what
/// a strip embedded mid-scroll has to do — a native map that swallows vertical
/// drags traps the finger and the page stops scrolling. Tapping anywhere on it
/// opens the same route chooser as the address row.
class LocationPreviewMap extends StatefulWidget {
  const LocationPreviewMap({
    super.key,
    required this.lat,
    required this.lng,
    this.title,
    this.subtitle,
    this.height,
    this.zoom = 16,
  });

  final double lat;
  final double lng;

  /// Venue name — drawn on the marker pill and carried into the route sheet.
  final String? title;

  /// Street address, shown as the route sheet's second line.
  final String? subtitle;

  /// Strip height. Deliberately short: it is a locator, not a map screen.
  final double? height;

  final double zoom;

  @override
  State<LocationPreviewMap> createState() => _LocationPreviewMapState();
}

class _LocationPreviewMapState extends State<LocationPreviewMap> {
  YandexMapController? _controller;
  List<PlacemarkMapObject> _objects = const [];

  /// Guards against a stale marker build landing after a newer one.
  int _markerBuild = 0;

  Point get _point => Point(latitude: widget.lat, longitude: widget.lng);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Needs the device pixel ratio, so it can't run in `initState`.
    _syncMarker();
  }

  @override
  void didUpdateWidget(covariant LocationPreviewMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Class detail plots the coordinates the list payload carried, then the
    // ones `/classes/:id` returns — the pin and the camera follow.
    if (oldWidget.lat != widget.lat ||
        oldWidget.lng != widget.lng ||
        oldWidget.title != widget.title) {
      _syncMarker();
      _centre();
    }
  }

  Future<void> _syncMarker() async {
    final token = ++_markerBuild;
    final bitmap = await BranchMarkerPainter.build(
      title: widget.title ?? '',
      // The one venue on this map is the subject of the page, so it wears the
      // selected pill — the same one the branches map raises for the centre a
      // parent tapped.
      isSelected: true,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    if (!mounted || token != _markerBuild) return;
    setState(() {
      _objects = [
        PlacemarkMapObject(
          mapId: const MapObjectId('venue'),
          point: _point,
          // Defaults to 0.5 — without this the pill is half transparent.
          opacity: 1,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromBytes(bitmap.bytes),
              anchor: bitmap.anchor,
              scale: bitmap.scale,
            ),
          ),
        ),
      ];
    });
  }

  Future<void> _centre() async {
    final controller = _controller;
    if (controller == null) return;
    await controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _point, zoom: widget.zoom),
      ),
    );
  }

  void _openRouteSheet() => MapRouteSheet.show(
        context,
        lat: widget.lat,
        lng: widget.lng,
        title: widget.title,
        subtitle: widget.subtitle,
      );

  @override
  Widget build(BuildContext context) {
    // MapKit has no web implementation; the address row and its route button
    // still answer the question there.
    if (kIsWeb) return const SizedBox.shrink();

    final c = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openRouteSheet,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: widget.height ?? 140.h,
          width: double.infinity,
          child: Stack(
            children: [
              // Stands in until MapKit has drawn its first frame, so the strip
              // doesn't flash white inside the card.
              Positioned.fill(child: ColoredBox(color: c.control)),
              Positioned.fill(
                child: IgnorePointer(
                  child: YandexMap(
                    onMapCreated: (controller) {
                      _controller = controller;
                      _centre();
                    },
                    nightModeEnabled: c.isDark,
                    mapObjects: _objects,
                    // Belt and braces: the IgnorePointer already keeps the
                    // finger on the page, and these keep the map still if a
                    // platform ever routes a touch past it anyway.
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    // Yandex's terms require the logo to stay visible.
                    logoAlignment: const MapAlignment(
                      horizontal: HorizontalAlignment.left,
                      vertical: VerticalAlignment.bottom,
                    ),
                    logoPadding: MapPadding(
                      horizontal: 8.w.round(),
                      vertical: 8.h.round(),
                    ),
                  ),
                ),
              ),
              // Same round arrow as the address row, so the strip visibly
              // leads to directions rather than to a bigger map.
              Positioned(
                right: 8.w,
                bottom: 8.h,
                child: RouteIconButton(
                  lat: widget.lat,
                  lng: widget.lng,
                  title: widget.title,
                  subtitle: widget.subtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

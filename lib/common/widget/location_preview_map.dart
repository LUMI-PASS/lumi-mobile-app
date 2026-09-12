import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/widget/map_route_sheet.dart';

/// The route-to-the-venue strip inside a detail card — class detail and branch
/// detail.
///
/// **This draws an illustration, not a map.** The artwork is the same on every
/// venue; only the destination behind the tap changes. It is a signpost to
/// directions, not a locator — the address row above it is what states where
/// the venue actually is, and tapping either opens the same route chooser.
///
/// It carries no venue name: the card header and the address row directly
/// above have already said which venue this is, and a label repeating it in
/// the middle of the artwork read as a map pin promising a location the
/// illustration cannot deliver.
///
/// ## Why there is no real map here
///
/// This started as an embedded Yandex MapKit view. MapKit renders through a
/// **platform view** — a real UIKit/Android view spliced into the Flutter
/// scene — and Flutter's docs are explicit about what that costs inside a
/// scrolling page: on Android hybrid composition "Flutter merges the raster
/// thread into the platform thread", and the texture-layer alternative is
/// "janky during quick scrolling". The strip moves every scroll frame, so it
/// paid that on every frame, plus overlay surfaces for anything drawn on top
/// of it and a rounded clip re-applied to the native view as it moved. That is
/// what made class detail stutter under the finger.
///
/// A tile map (`flutter_map`) fixes the frame cost — tiles are ordinary
/// widgets — but still carries tile fetches, a basemap licence and an
/// attribution line for a 140px strip. An illustration carries none of it: one
/// cached SVG, no network, no key, no provider, and no state.
///
/// The full-screen branches map (`branches_map_page.dart`) and the shop's
/// delivery-point picker keep Yandex MapKit. They are full-screen and
/// interactive, nothing scrolls behind them, so the platform view costs them
/// nothing and they keep Yandex's Uzbekistan data and `uz_UZ` labels. Those
/// screens genuinely need a map; this strip never did.
class LocationPreviewMap extends StatelessWidget {
  const LocationPreviewMap({
    super.key,
    required this.lat,
    required this.lng,
    this.title,
    this.subtitle,
    this.height,
  });

  final double lat;
  final double lng;

  /// Venue name — carried into the route sheet as its first line. Not drawn on
  /// the strip; see the class doc.
  final String? title;

  /// Street address, shown as the route sheet's second line.
  final String? subtitle;

  /// Strip height. Deliberately short: it is a signpost, not a map screen.
  final double? height;

  void _openRouteSheet(BuildContext context) => MapRouteSheet.show(
        context,
        lat: lat,
        lng: lng,
        title: title,
        subtitle: subtitle,
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openRouteSheet(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SizedBox(
          height: height ?? 140.h,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: c.control)),
              // `SvgTheme.currentColor`, NOT `colorFilter`: a colour filter
              // repaints the whole picture, which flattened the route, the pin
              // and the park to one colour along with the roads. The theme
              // substitutes only what the asset left as `currentColor` — the
              // roads — and leaves the brand fills alone.
              //
              // `cover` keeps the pin centred at any strip width.
              Positioned.fill(
                child: Assets.icons.background.mapStripMisc.svg(
                  fit: BoxFit.cover,
                  theme: SvgTheme(currentColor: c.surface),
                ),
              ),
              // Same round arrow as the address row, so the strip visibly
              // leads to directions.
              Positioned(
                right: 8.w,
                bottom: 8.h,
                child: RouteIconButton(
                  lat: lat,
                  lng: lng,
                  title: title,
                  subtitle: subtitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

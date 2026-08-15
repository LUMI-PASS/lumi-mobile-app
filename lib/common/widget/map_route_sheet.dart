import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:url_launcher/url_launcher.dart';

/// "Build a route" chooser — the venue opened for navigation in Yandex Maps or
/// Google Maps.
///
/// Both are always listed rather than only the ones we can detect: on iOS
/// `canLaunchUrl` answers for a scheme only if it is declared in
/// `LSApplicationQueriesSchemes`, and on Android 11+ only with a matching
/// `<queries>` entry, so detection quietly hides apps that are in fact
/// installed. Each tile instead tries the app's own scheme first and falls back
/// to the map site — which the installed app claims as a deep link anyway, and
/// which is the right answer on web and on a phone without either app.
class MapRouteSheet extends StatelessWidget {
  const MapRouteSheet({
    super.key,
    required this.lat,
    required this.lng,
    this.title,
    this.subtitle,
  });

  final double lat;
  final double lng;

  /// Venue name, shown as the sheet's subject line.
  final String? title;

  /// Street address under the name, when one is known.
  final String? subtitle;

  /// Opens the chooser. Returns as soon as the sheet is dismissed — the launch
  /// itself is fire-and-forget, since the user has left for the maps app.
  static Future<void> show(
    BuildContext context, {
    required double lat,
    required double lng,
    String? title,
    String? subtitle,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => MapRouteSheet(
        lat: lat,
        lng: lng,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  /// App scheme first, then the website. `rtext=~lat,lng` is Yandex's
  /// "route to here from my location"; `dir/?api=1` is Google's.
  ///
  /// On web the app schemes are dropped: a browser can't resolve them, and
  /// url_launcher reports the attempt as succeeding, which would swallow the
  /// tap instead of falling through to the site.
  List<Uri> get _yandexTargets => [
        if (!kIsWeb) ...[
          Uri.parse('yandexmaps://maps.yandex.ru/?rtext=~$lat,$lng&rtt=auto'),
          Uri.parse('yandexnavi://build_route_on_map?lat_to=$lat&lon_to=$lng'),
        ],
        Uri.parse('https://yandex.com/maps/?rtext=~$lat,$lng&rtt=auto'),
      ];

  List<Uri> get _googleTargets => [
        if (!kIsWeb)
          Uri.parse('comgooglemaps://?daddr=$lat,$lng&directionsmode=driving'),
        Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
        ),
      ];

  Future<void> _open(BuildContext context, List<Uri> targets) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).pop();
    for (final uri in targets) {
      try {
        final opened = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
        if (opened) return;
      } catch (_) {
        // That app isn't installed (Android throws rather than returning
        // false) — fall through to the next target.
      }
    }
    messenger?.showSnackBar(SnackBar(content: Text('route_open_failed'.tr())));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = title?.trim() ?? '';
    final address = subtitle?.trim() ?? '';

    return Padding(
      padding: EdgeInsets.only(
        bottom: 16.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          12.verticalSpace,
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: c.textSecondary.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          16.verticalSpace,
          Text(
            'branch_build_route'.tr(),
            style: AppText.heading20.copyWith(color: c.textPrimary),
          ),
          if (name.isNotEmpty) ...[
            6.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                address.isEmpty ? name : '$name · $address',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.regular13.copyWith(color: c.textSecondary),
              ),
            ),
          ],
          16.verticalSpace,
          _MapTile(
            c: c,
            // Brand icons ship with the map_launcher package we already depend
            // on, so there is no local asset (and no generated getter) for
            // these two — hence the raw path plus `package:`.
            iconAsset: 'assets/icons/yandexMaps.svg',
            label: 'Yandex Maps',
            onTap: () => _open(context, _yandexTargets),
          ),
          8.verticalSpace,
          _MapTile(
            c: c,
            iconAsset: 'assets/icons/google.svg',
            label: 'Google Maps',
            onTap: () => _open(context, _googleTargets),
          ),
        ],
      ),
    );
  }
}

/// One app row: its icon, its name, and a chevron.
class _MapTile extends StatelessWidget {
  const _MapTile({
    required this.c,
    required this.iconAsset,
    required this.label,
    required this.onTap,
  });

  final AppColorScheme c;
  final String iconAsset;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
          decoration: BoxDecoration(
            color: c.control,
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: SvgPicture.asset(
                  iconAsset,
                  package: 'map_launcher',
                  width: 40.w,
                  height: 40.w,
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: Text(
                  label,
                  style: AppText.semibold14.copyWith(color: c.textPrimary),
                ),
              ),
              Assets.icons.arrowRight.svg(
                width: 16.w,
                height: 16.w,
                colorFilter:
                    ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The affordance that opens [MapRouteSheet] — a round map button sized to sit
/// inside the venue row on the detail screens.
class RouteIconButton extends StatelessWidget {
  const RouteIconButton({
    super.key,
    required this.lat,
    required this.lng,
    this.title,
    this.subtitle,
  });

  final double lat;
  final double lng;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => MapRouteSheet.show(
        context,
        lat: lat,
        lng: lng,
        title: title,
        subtitle: subtitle,
      ),
      child: Container(
        width: 32.w,
        height: 32.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: detailChipFill(c),
          shape: BoxShape.circle,
        ),
        // The navigation arrow, not a folded map and not a tour marker: this
        // button starts directions somewhere, and both of those read as "look
        // at a map" instead. It is the glyph iOS itself puts on its navigate
        // control, so it needs no learning.
        //
        // Cupertino rather than an SVG from `assets/icons` only because there
        // is no arrow glyph in there yet — drop one in and this becomes
        // `Assets.icons.<name>.svg(...)` like every other icon in the app.
        child: Icon(
          CupertinoIcons.location_north_fill,
          size: 18.w,
          color: c.textPrimary,
        ),
      ),
    );
  }
}

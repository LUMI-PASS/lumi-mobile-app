import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/user_location.dart';

/// How far a place is from the user, e.g. "1.2 km" — the distance line every
/// activity, course and centre card carries.
///
/// It measures locally, from the centre's own coordinates and
/// [currentUserLocation], rather than reading a `distance` off the payload:
/// the server sorts by distance but has never sent the number (see
/// `geo.ts` — "nothing is shown to a user in kilometres"), and every card in
/// the app already carries its branch's lat/lng. So this works on the home
/// rows, the see-all grid, search results and the branch page alike, with no
/// API change and nothing to keep in sync.
///
/// It renders NOTHING — not a dash, not a placeholder — unless there is a real
/// answer. That means all of:
///   - the user's position is known AND is the device's own
///     ([UserLocation.isPrecise]); the Tashkent-centre fallback orders a list
///     fine but is not somewhere to measure from, and quoting it would be a
///     confident lie;
///   - the place has usable coordinates (see [isUsableCoords]).
/// A missing distance is a missing line, and the address beside it simply gets
/// the width back.
class DistanceLabel extends StatelessWidget {
  const DistanceLabel({
    super.key,
    required this.latitude,
    required this.longitude,
    this.style,
    this.iconSize = 12,
    this.showIcon = true,
  });

  /// The place being measured to — typically `homClass.branch`'s pair.
  final double? latitude;
  final double? longitude;

  /// Defaults to the same muted 12pt the address line uses, so the two read as
  /// one row rather than as two competing facts.
  final TextStyle? style;

  /// The pin's HEIGHT. Its width follows from the asset's own proportions —
  /// see [_pinAspect].
  final double iconSize;

  /// Off for tight rows that already carry a pin.
  final bool showIcon;

  /// `assets/icons/location.svg` is 18×23: a teardrop is taller than it is
  /// wide, and forcing it into a square box squashes it into a blob. Sized off
  /// its height so it lines up with the text beside it, with the width derived
  /// rather than assumed.
  static const _pinAspect = 18 / 23;

  /// The line this would render for ([lat], [lng]) right now, or null when
  /// there is nothing honest to say — see the class doc for what disqualifies
  /// a card.
  ///
  /// Public so a caller can lay out AROUND the distance: a row needs to know
  /// whether to spend a gap on it before the widget itself gets a chance to
  /// answer. Read inside a [ValueListenableBuilder] on [currentUserLocation],
  /// or it won't notice the fix arriving.
  static String? labelFor(double? lat, double? lng) {
    if (!isUsableCoords(lat, lng)) return null;
    final here = currentUserLocation.value;
    // Not `here == null` alone: an imprecise fallback must stay silent too.
    if (here == null || !here.isPrecise) return null;
    final meters = here.metersTo(lat, lng);
    return meters == null ? null : format(meters);
  }

  /// "320 m" / "1.2 km" / "12 km", localised.
  static String format(double meters) {
    final (key, figure) = parts(meters);
    return key.tr(args: [figure]);
  }

  /// [format] before localisation: the translation key and the figure to put
  /// in it. Split out so the rounding can be asserted on its own — the wording
  /// is the translators' business, the buckets and the digits are ours.
  ///
  /// Precision falls off with distance on purpose: under a kilometre the exact
  /// figure is walkable detail, past ten it is noise — nobody picks a centre on
  /// 12.4 vs 12 km, and the extra digit only makes a straight-line estimate
  /// look like a routed one.
  @visibleForTesting
  static (String, String) parts(double meters) {
    if (meters < 950) {
      // To the nearest 10 m. A GPS fix isn't good to the metre and neither is
      // a great-circle line, so "317 m" would be spurious precision.
      return ('distance_m', '${(meters / 10).round() * 10}');
    }
    final km = meters / 1000;
    return (
      'distance_km',
      km < 10 ? km.toStringAsFixed(1) : '${km.round()}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isUsableCoords(latitude, longitude)) return const SizedBox.shrink();

    return ValueListenableBuilder<UserLocation?>(
      valueListenable: currentUserLocation,
      builder: (context, _, __) {
        final label = labelFor(latitude, longitude);
        if (label == null) return const SizedBox.shrink();

        final c = context.colors;
        final textStyle =
            style ?? AppText.regular12.copyWith(color: c.textSecondary);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              // A single-path outline pin, so `srcIn` recolours the stroke and
              // leaves the hollow centre alone. The asset ships `fill="white"`
              // — invisible until tinted, which is the point.
              Assets.icons.location.svg(
                width: (iconSize * _pinAspect).w,
                height: iconSize.w,
                colorFilter: ColorFilter.mode(
                  textStyle.color ?? c.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              2.horizontalSpace,
            ],
            Text(
              label,
              maxLines: 1,
              // The row that holds this gives it exactly the width it asked
              // for, so this never actually elides — it is here so a wildly
              // long localisation can't overflow the card.
              overflow: TextOverflow.ellipsis,
              style: textStyle,
            ),
          ],
        );
      },
    );
  }
}

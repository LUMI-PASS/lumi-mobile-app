import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';

/// A rounded-square glyph tile on a tint of its own accent — the badge that
/// starts a row in the list-and-card layouts (bookings, settings, services).
///
/// The accent is passed in rather than derived so a list of rows can be read
/// at a glance by colour: the date row is not the venue row is not the money
/// row. The tint is the accent at 12%, which is legible on both themes without
/// needing a second colour defined per surface.
class SoftIconTile extends StatelessWidget {
  const SoftIconTile({
    super.key,
    required this.accent,
    this.asset,
    this.icon,
    this.size = 36,
  }) : assert(asset != null || icon != null, 'give the tile a glyph');

  /// SVG from the generated asset bundle — tinted to [accent].
  final SvgGenImage? asset;

  /// Material fallback, for a glyph with no asset of its own.
  final IconData? icon;
  final Color accent;

  /// Edge of the square, in design pixels.
  final double size;

  @override
  Widget build(BuildContext context) {
    final glyph = size * 0.5;
    return Container(
      width: size.w,
      height: size.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular((size / 2.8).r),
      ),
      child: asset != null
          ? asset!.svg(
              width: glyph.sp,
              height: glyph.sp,
              colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
            )
          : Icon(icon, size: glyph.sp, color: accent),
    );
  }
}

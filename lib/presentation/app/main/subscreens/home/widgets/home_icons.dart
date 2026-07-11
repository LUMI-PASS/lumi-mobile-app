import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';

/// Iconsax icons pulled from the Figma redesign (`Assets.icons.home`,
/// `Assets.icons.detail`), rendered monochrome so they can be tinted per state.
class HomeIcon extends StatelessWidget {
  const HomeIcon(
    this.icon, {
    super.key,
    required this.size,
    this.color,
  });

  final SvgGenImage icon;
  final double size;

  /// Tint applied via `srcIn`. Pass `null` to render the SVG's own colours
  /// (for multicolour icons like the detail info-tile glyphs).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return icon.svg(
      width: size.w,
      height: size.w,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}

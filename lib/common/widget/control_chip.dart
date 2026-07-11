import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';

/// Theme-aware control chip — the small rounded square behind a glyph in page
/// chrome: the app-bar back button, an accordion chevron, a row's trailing
/// icon.
///
/// This is the sibling of `FrostedCard`, and the two are **not**
/// interchangeable:
///
/// - [ControlChip] follows the theme (`control` fill + `controlBorder`
///   hairline). Use it on a themed page, where the surface underneath goes
///   dark in dark mode. Its glyph is tinted `context.colors.textPrimary`.
/// - `FrostedCard` is always light *by design* — it sits on top of a photo
///   (the hero back / share / heart chips, the carousel dots pill), so it must
///   stay pale in both themes. Its glyphs use the fixed `AppColors.ink`.
///
/// Putting a `FrostedCard` on a themed page is the bug this widget exists to
/// prevent: a white chip glued to a dark page, with a white glyph on it.
class ControlChip extends StatelessWidget {
  const ControlChip({
    super.key,
    this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.borderWidth = 1,
    this.hasBorder = true,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.margin,
  });

  final Widget? child;
  final VoidCallback? onTap;

  /// Inner padding. Defaults to `EdgeInsets.all(8.w)` — the chip size.
  final EdgeInsetsGeometry? padding;

  /// Corner radius. Defaults to `BorderRadius.circular(12.r)`.
  final BorderRadius? borderRadius;
  final double borderWidth;
  final bool hasBorder;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final box = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? EdgeInsets.all(8.w),
      alignment: alignment,
      decoration: BoxDecoration(
        color: colors.control,
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        border: hasBorder
            ? Border.all(color: colors.controlBorder, width: borderWidth)
            : null,
      ),
      child: child,
    );

    if (onTap == null) return box;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: box,
    );
  }
}

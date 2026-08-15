import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';

/// Theme-aware frosted card. It uses the pale-lavender → off-white gradient in
/// light mode and a raised charcoal gradient in dark mode.
///
/// This is the shared "gradient card" used across the app: notification
/// cards, hero control chips (back / share / heart), the carousel dots pill,
/// icon badges, and similar raised surfaces. Prefer this over
/// re-declaring the gradient + white border inline on a [Container].
class FrostedCard extends StatelessWidget {
  const FrostedCard({
    super.key,
    this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1,
    this.hasBorder = true,
    this.gradient,
    this.boxShadow,
    this.width,
    this.height,
    this.alignment,
    this.margin,
    this.clipBehavior = Clip.none,
  });

  final Widget? child;
  final VoidCallback? onTap;

  /// Inner padding. Defaults to `EdgeInsets.all(8.w)` — the frosted-chip size.
  final EdgeInsetsGeometry? padding;

  /// Corner radius. Defaults to `BorderRadius.circular(12.r)`.
  final BorderRadius? borderRadius;

  /// Overrides the theme-aware border colour.
  final Color? borderColor;
  final double borderWidth;

  /// Set `false` for borderless variants (e.g. the carousel dots pill).
  final bool hasBorder;

  /// Fill gradient. Defaults to [AppGradients.frostedControl] in light mode
  /// and [AppGradients.frostedControlDark] in dark mode.
  final Gradient? gradient;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? margin;

  /// Set [Clip.antiAlias] when the child deliberately overflows the card (e.g.
  /// artwork bleeding past the rounded corners) and must be cut to its shape.
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedGradient = gradient ??
        (colors.isDark
            ? AppGradients.frostedControlDark
            : AppGradients.frostedControl);
    final resolvedBorderColor =
        borderColor ?? (colors.isDark ? colors.controlBorder : Colors.white);
    final contentColor = colors.textPrimary;

    final box = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? EdgeInsets.all(8.w),
      alignment: alignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        gradient: resolvedGradient,
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        border: hasBorder
            ? Border.all(color: resolvedBorderColor, width: borderWidth)
            : null,
        boxShadow: boxShadow,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: contentColor),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: contentColor),
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );

    if (onTap == null) return box;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: box,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';

/// Frosted light card — the pale-lavender → off-white gradient
/// ([AppGradients.frostedControl]) with a white hairline border.
///
/// This is the shared "gradient card" used across the app: notification
/// cards, hero control chips (back / share / heart), the carousel dots pill,
/// icon badges, and similar raised light surfaces. Prefer this over
/// re-declaring the gradient + white border inline on a [Container].
class FrostedCard extends StatelessWidget {
  const FrostedCard({
    super.key,
    this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.borderColor = Colors.white,
    this.borderWidth = 1,
    this.hasBorder = true,
    this.gradient = AppGradients.frostedControl,
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
  final Color borderColor;
  final double borderWidth;

  /// Set `false` for borderless variants (e.g. the carousel dots pill).
  final bool hasBorder;

  /// Fill gradient. Defaults to [AppGradients.frostedControl].
  final Gradient gradient;
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
    final box = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? EdgeInsets.all(8.w),
      alignment: alignment,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        border:
            hasBorder ? Border.all(color: borderColor, width: borderWidth) : null,
        boxShadow: boxShadow,
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

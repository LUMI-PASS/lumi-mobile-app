import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';

/// Which dark-theme surface an [AdaptiveCard] sits on.
enum CardTone {
  /// Content cards — `color/shape` in Figma.
  surface,

  /// Controls and list rows — `color/shape-2`, one step lighter.
  control,
}

/// A card that keeps [FrostedCard]'s pale gradient in light, and swaps to a
/// flat raised surface in dark.
///
/// [FrostedCard] is a light-only treatment — its `#f2f4ff → #f8f8f8` gradient
/// glows on an ink background. Screens that exist in both themes want this
/// instead, so their text can stay on `context.colors` roles.
class AdaptiveCard extends StatelessWidget {
  const AdaptiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
    this.tone = CardTone.surface,
    this.bordered = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final CardTone tone;

  /// Draw a hairline in dark. Light always carries the frosted white border.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = borderRadius ?? BorderRadius.circular(12.r);

    if (!colors.isDark) {
      return FrostedCard(
        onTap: onTap,
        padding: padding,
        borderRadius: radius,
        borderWidth: 2,
        child: child,
      );
    }

    final box = Container(
      padding: padding ?? EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: tone == CardTone.control ? colors.control : colors.surface,
        borderRadius: radius,
        border: bordered ? Border.all(color: colors.controlBorder) : null,
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

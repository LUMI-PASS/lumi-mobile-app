import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// − N + — the one counter the whole shop uses.
///
/// It was three near-identical private steppers before (grid card, product
/// page, basket line), which is how the three of them drifted apart. One
/// widget, two shapes: [expanded] fills the width where it replaces a button,
/// and hugs its content where it sits at the end of a row.
///
/// A null [onDecrease] / [onIncrease] is what disables that end — passing the
/// callback and a separate `enabled` flag let the two disagree.
class ShopQuantityStepper extends StatelessWidget {
  const ShopQuantityStepper({
    super.key,
    required this.count,
    required this.onDecrease,
    required this.onIncrease,
    this.expanded = false,
  });

  final int count;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  /// Fill the available width instead of hugging the digits.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final label = Text(
      '$count',
      textAlign: TextAlign.center,
      style: AppText.semibold14.copyWith(color: c.textPrimary),
    );

    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
        children: [
          _StepEnd(icon: Icons.remove_rounded, onTap: onDecrease),
          if (expanded)
            Expanded(child: label)
          else
            SizedBox(width: 32.w, child: label),
          _StepEnd(icon: Icons.add_rounded, onTap: onIncrease),
        ],
      ),
    );
  }
}

class _StepEnd extends StatelessWidget {
  const _StepEnd({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      // Opaque so the whole end of the pill is the target, not just the glyph.
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 40.w,
        height: double.infinity,
        child: Icon(
          icon,
          size: 18.w,
          color: onTap == null ? c.disabled : AppColors.brandPurple,
        ),
      ),
    );
  }
}

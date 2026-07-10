import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/bouncing_button.dart';

/// A selectable language row from the "Выберите язык" screen.
/// Figma: full-width pill, r36, surface bg (or brand pink when selected),
/// 24px circular flag, medium-16 label.
class LanguageOptionTile extends StatelessWidget {
  const LanguageOptionTile({
    super.key,
    required this.flagAsset,
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String flagAsset;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Bouncing(
      onTap: () => onTap?.call(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.brandPurple : colors.surface,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                flagAsset,
                width: 24.r,
                height: 24.r,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: AppText.medium16.copyWith(
                color: selected ? AppColors.onBrand : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

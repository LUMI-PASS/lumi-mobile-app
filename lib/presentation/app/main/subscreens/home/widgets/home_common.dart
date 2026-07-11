import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// Section header used across the home feed — a bold title on the left and a
/// muted "View all" affordance on the right (Figma `Category header`).
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
  });

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.bold18.copyWith(color: c.textPrimary),
            ),
          ),
          if (onViewAll != null)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onViewAll,
              child: Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Text(
                  'view_all'.tr(),
                  style: AppText.medium13.copyWith(color: AppColors.brandPurple),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small rounded pill with a "skeuomorphic" inner highlight, matching the
/// category / provider / promo tags in the Figma design.
class HomePillTag extends StatelessWidget {
  const HomePillTag({
    super.key,
    required this.label,
    this.leading,
    this.gradient,
    this.color,
  }) : assert(gradient != null || color != null);

  final String label;
  final Widget? leading;
  final Gradient? gradient;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: gradient,
        color: color,
        borderRadius: BorderRadius.circular(48.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            4.horizontalSpace,
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.medium10.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

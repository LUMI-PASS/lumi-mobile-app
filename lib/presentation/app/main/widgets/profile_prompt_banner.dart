import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// The "add your name and child" nudge that rides above the bottom nav on every
/// tab.
///
/// Filling in the parent's name and their child is what lets the feed filter and
/// recommend properly, but it is not worth blocking anyone at the door for — so
/// instead of the old sheet that greeted every new user, this sits quietly above
/// the nav until they either act on it or close it. Closing it is remembered
/// (see `Storage.profilePromptDismissed`), so it never comes back.
class ProfilePromptBanner extends StatelessWidget {
  const ProfilePromptBanner({
    super.key,
    required this.onTap,
    required this.onDismiss,
  });

  /// Opens the name + child form.
  final VoidCallback onTap;

  /// The ×. Puts the banner away for good.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: c.controlBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: c.isDark ? 0.30 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.brand,
                ),
                child: Icon(Icons.auto_awesome_rounded,
                    size: 18.sp, color: Colors.white),
              ),
              10.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'profile_prompt_title'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppText.semibold14.copyWith(color: c.textPrimary),
                    ),
                    2.verticalSpace,
                    Text(
                      'profile_prompt_sub'.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style:
                          AppText.regular12.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              // The × is its own hit target, so tapping it closes the banner
              // instead of opening the form underneath.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onDismiss,
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(Icons.close_rounded,
                      size: 16.sp, color: c.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

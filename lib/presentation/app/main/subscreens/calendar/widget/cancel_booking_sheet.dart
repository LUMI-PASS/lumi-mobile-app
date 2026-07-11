import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// Confirmation sheet for cancelling a booking (Figma 96:3421).
///
/// Resolves `true` when the user confirms the cancellation, `false` / `null`
/// when they back out — so callers can `if (await showCancelBookingSheet(...)
/// != true) return;`.
Future<bool?> showCancelBookingSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.8),
    builder: (_) => const _CancelBookingSheet(),
  );
}

class _CancelBookingSheet extends StatelessWidget {
  const _CancelBookingSheet();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        14.w,
        12.h,
        14.w,
        MediaQuery.of(context).viewPadding.bottom + 24.h,
      ),
      decoration: BoxDecoration(
        color: c.scaffoldBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pull handle.
          Container(
            width: 32.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.inkMuted.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          12.verticalSpace,
          // Multicolour glyph — renders its own colours, no tint.
          Assets.icons.coupons.icTicketDelete.svg(width: 48.w, height: 48.w),
          8.verticalSpace,
          Text(
            'booking_cancel_confirm'.tr(),
            textAlign: TextAlign.center,
            style: AppText.semibold18
                .copyWith(fontSize: 20.sp, color: c.textPrimary),
          ),
          8.verticalSpace,
          Text(
            'booking_cancel_warning'.tr(),
            textAlign: TextAlign.center,
            style: AppText.regular14.copyWith(color: c.textSecondary),
          ),
          24.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _SheetButton(
                  label: 'booking_keep'.tr(),
                  background: c.surface,
                  foreground: c.textPrimary,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: _SheetButton(
                  label: 'booking_cancel_title'.tr(),
                  background: AppColors.error,
                  foreground: Colors.white,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(44.r),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppText.medium16.copyWith(color: foreground),
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/shop/shop_order.dart';

/// The status pill, shared by the list and the detail screen so the two can
/// never label the same order differently.
class ShopStatusChip extends StatelessWidget {
  const ShopStatusChip({super.key, required this.status});

  final ShopOrderStatus status;

  Color get _color => switch (status) {
        ShopOrderStatus.isNew => AppColors.link,
        ShopOrderStatus.confirmed => AppColors.brandPurple,
        ShopOrderStatus.delivering => AppColors.warning,
        ShopOrderStatus.delivered => AppColors.green,
        ShopOrderStatus.canceled => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        status.labelKey.tr(),
        style: AppText.semibold12.copyWith(color: _color),
      ),
    );
  }
}

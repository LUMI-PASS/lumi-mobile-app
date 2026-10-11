import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/sale_label.dart';
import 'package:lumi_pass/data/api_model/activity_sale/activity_sale.dart';

/// A centre's sale, said in full: how much, and — on the same block, never
/// apart from it — on which days, between which hours and until when.
///
/// Used wherever there is room to say it properly: the prices card on the
/// activity page and the top of the booking sheet. The cards on the feed say
/// the same thing as two badges (see `_ClassImage`).
class SaleNotice extends StatelessWidget {
  const SaleNotice({super.key, required this.sale, this.applies = true});

  final ActivitySale sale;

  /// False where the notice sits beside prices the sale is NOT moving — the
  /// booking sheet with a day or an hour picked that it does not cover. It
  /// then says so in as many words and steps back, because "−10%" above a
  /// full price reads as a price that failed to update.
  final bool applies;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Opacity(
      opacity: applies ? 1 : 0.6,
      child: _body(c),
    );
  }

  Widget _body(AppColorScheme c) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: c.discountBand,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: applies ? AppColors.error : c.textMuted,
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Text(
              salePercentLabel(sale),
              style: AppText.semibold14.copyWith(color: Colors.white),
            ),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'sale_title'.tr(),
                  style: AppText.semibold14.copyWith(color: c.textPrimary),
                ),
                2.verticalSpace,
                Text(
                  saleTermsLabel(sale),
                  style: AppText.regular12.copyWith(color: c.textSecondary),
                ),
                if (!applies) ...[
                  2.verticalSpace,
                  Text(
                    'sale_not_this_time'.tr(),
                    style: AppText.medium12.copyWith(color: c.textPrimary),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

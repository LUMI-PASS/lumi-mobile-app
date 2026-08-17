import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/payment_sheet_chrome.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';

/// Confirms forgetting a card. Resolves true when the user goes through with it.
Future<bool?> showDeleteCardSheet(BuildContext context, SavedCard card) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _DeleteCardSheet(card: card),
  );
}

class _DeleteCardSheet extends StatelessWidget {
  const _DeleteCardSheet({required this.card});

  final SavedCard card;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PaymentSheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          8.kh,
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.credit_card_off_rounded,
                size: 26.sp, color: AppColors.error),
          ),
          14.kh,
          Text(
            'card_delete_title'.tr(),
            textAlign: TextAlign.center,
            style: AppText.bold18.copyWith(color: c.textPrimary),
          ),
          8.kh,
          Text(
            'card_delete_confirm'.tr(args: [card.label]),
            textAlign: TextAlign.center,
            style: AppText.regular13
                .copyWith(color: c.textSecondary, height: 1.4),
          ),
          20.kh,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(false),
                  child: Container(
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: c.divider,
                      borderRadius: BorderRadius.circular(44.r),
                    ),
                    child: Text('cancel'.tr(),
                        style: AppText.medium16
                            .copyWith(color: c.textSecondary)),
                  ),
                ),
              ),
              8.kw,
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).pop(true),
                  child: Container(
                    height: 50.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(44.r),
                    ),
                    child: Text(
                      'card_delete_action'.tr(),
                      style:
                          AppText.medium16.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

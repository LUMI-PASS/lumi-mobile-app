import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/cashback.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/data/api_model/wallet/cashback_preview.dart';

/// "1% cashback" pill for a class or course detail screen.
///
/// Renders nothing at all when the class earns nothing — the feature being off,
/// the rule being inactive, or the class's margin being too thin all arrive as
/// `percent: 0`, so there is one condition to check rather than three.
///
/// The rate must come from `GET /api/cashback/preview`, never from the public
/// config: the config reports what was configured, this reports what the class
/// can actually pay.
class CashbackChip extends StatelessWidget {
  const CashbackChip({super.key, required this.preview});

  final CashbackPreview preview;

  @override
  Widget build(BuildContext context) {
    if (!preview.hasRate) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        // A fixed ink on a translucent green wash: this chip sits over class
        // photography on the detail hero, so it stays legible in both themes
        // rather than following the surface roles.
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.coinLumi.image(width: 14.w, height: 14.w),
          4.kw,
          Text(
            'cashback_percent_chip'
                .tr(args: [formatCashbackPercent(preview.percent)]),
            style: AppText.semibold12.copyWith(color: AppColors.green),
          ),
        ],
      ),
    );
  }
}

/// "You'll earn ~12 000 🪙" — the line under the total in a booking summary.
///
/// [orderAmount] is what the buyer pays with money, i.e. the total after any
/// promocode or coupon discount. The amount is computed locally from the
/// server's rate ([cashbackFor]) so it re-prices as tickets are added without a
/// request per tap; it is deliberately approximate ("~"), because the credit is
/// re-derived server-side when the payment lands.
class CashbackEarnLine extends StatelessWidget {
  const CashbackEarnLine({
    super.key,
    required this.preview,
    required this.orderAmount,
  });

  final CashbackPreview preview;
  final num orderAmount;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final amount = cashbackFor(preview, orderAmount);
    // Nothing to promise — an order under the rule's minimum, or a rate too
    // small to round up to a whole soum.
    if (amount <= 0) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: Text(
            'cashback_you_will_earn'.tr(),
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
        ),
        CoinAmount(
          amount: amount,
          prefix: '~',
          style: AppText.semibold14,
          color: AppColors.green,
        ),
      ],
    );
  }
}

/// "+12 000 🪙 added to your balance" — the booking success screen.
///
/// Still approximate. The wallet is credited by the payment webhook, which can
/// land after this screen does, so this reports what the order earns rather
/// than reading a balance that may not have moved yet.
class CashbackCreditedLine extends StatelessWidget {
  const CashbackCreditedLine({super.key, required this.amount});

  final num amount;

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) return const SizedBox.shrink();
    final c = context.colors;

    return Row(
      children: [
        CoinAmount(
          amount: amount,
          prefix: '+',
          style: AppText.semibold14,
          color: AppColors.green,
        ),
        6.kw,
        Expanded(
          child: Text(
            'cashback_credited_suffix'.tr(),
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

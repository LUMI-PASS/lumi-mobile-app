import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';

/// "Use balance" — the wallet switch in a booking summary.
///
/// Renders nothing when there is nothing to spend, so every caller can drop it
/// into a column unconditionally.
///
/// **Not subject to the promocode/coupon rules.** The promocode field is hidden
/// for a buyer who holds a coupon plan, because those two are alternative
/// discounts and never stack. The wallet is neither — it is a payment method,
/// so it sits alongside whichever discount already applied and reduces what the
/// card is charged rather than what the order costs.
class UseBalanceRow extends StatelessWidget {
  const UseBalanceRow({
    super.key,
    required this.wallet,
    required this.enabled,
    required this.applied,
    required this.onChanged,
  });

  final WalletBalance wallet;

  /// Whether the switch can be touched. False while a checkout is in flight —
  /// the amount is already committed at that point.
  final bool enabled;

  /// How much the wallet would cover of the current order. Computed by the
  /// caller against the live total, and re-decided server-side at checkout.
  final num applied;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Nothing spendable — a frozen wallet included. An affordance that can only
    // refuse is worse than no affordance.
    if (wallet.available <= 0 || wallet.isFrozen) {
      return const SizedBox.shrink();
    }

    final on = applied > 0;

    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(12.r),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Assets.icons.coinLumi.image(width: 24.w, height: 24.w),
          10.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'wallet_use_balance'.tr(),
                  style: AppText.semibold14.copyWith(color: c.textPrimary),
                ),
                2.kh,
                // What's on offer when off, what's being taken when on — the
                // buyer should never have to toggle it to find out. Built as a
                // Row rather than an interpolated string so the amount can
                // carry the coin mark.
                Row(
                  children: [
                    Text(
                      on
                          ? 'wallet_applied_label'.tr()
                          : 'wallet_available_label'.tr(),
                      style: AppText.regular12.copyWith(
                        color: on ? AppColors.green : c.textSecondary,
                      ),
                    ),
                    4.kw,
                    CoinAmount(
                      amount: on ? applied : wallet.available,
                      style: AppText.semibold12,
                      color: on ? AppColors.green : c.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: on,
            onChanged: enabled ? onChanged : null,
            activeColor: AppColors.brandPurple,
          ),
        ],
      ),
    );
  }
}

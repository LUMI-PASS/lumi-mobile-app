import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';

/// Wallet balance card on the profile screen.
///
/// Leads with what the user can actually spend ([WalletBalance.available]) and
/// only surfaces the other two counters when they're non-zero — most users will
/// never have a pending or held balance, and three numbers where one would do
/// reads as an accounting statement rather than a wallet.
class WalletSection extends StatelessWidget {
  const WalletSection({
    super.key,
    required this.wallet,
    this.onTap,
    this.debugError,
  });

  final WalletBalance wallet;

  /// Debug-only failure reason. When set, the balance shown is a placeholder
  /// rather than real data — so it's labelled loudly instead of quietly reading
  /// as a genuine zero. Never populated in release builds.
  final String? debugError;

  /// Opens the ledger. Null until the history screen lands (step 5), which is
  /// also why there's no chevron before then — an affordance that does nothing
  /// is worse than none.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasPending = wallet.pendingBalance > 0;
    final hasHeld = wallet.heldBalance > 0;

    return FrostedCard(
      onTap: onTap,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      borderRadius: BorderRadius.circular(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'wallet_available_label'.tr(),
                      style: AppText.regular13.copyWith(color: c.textSecondary),
                    ),
                    6.kh,
                    CoinAmount(
                      amount: wallet.available,
                      style: AppText.heading20,
                      color: c.textPrimary,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22.w,
                  color: c.textSecondary,
                ),
            ],
          ),
          if (hasPending || hasHeld) ...[
            12.kh,
            Divider(height: 1, color: c.border),
            10.kh,
            if (hasPending)
              _WalletSubLine(
                label: 'wallet_pending_label'.tr(),
                amount: wallet.pendingBalance,
                // Earned but not yet matured — it will become spendable, so a
                // positive-but-muted treatment rather than a warning.
                color: c.textSecondary,
              ),
            if (hasPending && hasHeld) 6.kh,
            if (hasHeld)
              _WalletSubLine(
                label: 'wallet_held_label'.tr(),
                amount: wallet.heldBalance,
                // "Held" is the line that generates support tickets, so it gets
                // the accent colour and an explanatory string.
                color: AppColors.warning,
              ),
          ],
          if (wallet.isFrozen) ...[
            10.kh,
            Text(
              'wallet_frozen_note'.tr(),
              style: AppText.regular12.copyWith(color: AppColors.error),
            ),
          ],
          if (debugError != null) ...[
            10.kh,
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              // Deliberately untranslated: this string never reaches a user.
              child: Text(
                'DEBUG — wallet not loaded\n$debugError',
                style: AppText.regular12.copyWith(color: AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WalletSubLine extends StatelessWidget {
  const _WalletSubLine({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final num amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppText.regular12.copyWith(color: color),
          ),
        ),
        CoinAmount(
          amount: amount,
          style: AppText.semibold12,
          color: color,
        ),
      ],
    );
  }
}

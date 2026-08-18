import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_transaction.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_tx_kind.dart';

/// How one ledger kind reads: a label, a glyph and a tint.
///
/// Switched exhaustively with no `default`, so a kind added to
/// [WalletTxKind] surfaces here as a compile-time warning rather than
/// silently rendering as whatever the fallback happened to be.
({String key, IconData icon, Color tint}) _describe(WalletTxKind kind) {
  switch (kind) {
    case WalletTxKind.earn:
      return (key: 'wallet_kind_earn', icon: Icons.savings_outlined, tint: AppColors.green);
    case WalletTxKind.earnMatured:
      return (key: 'wallet_kind_earn_matured', icon: Icons.lock_open_rounded, tint: AppColors.green);
    case WalletTxKind.earnReversed:
      return (key: 'wallet_kind_earn_reversed', icon: Icons.undo_rounded, tint: AppColors.error);
    case WalletTxKind.hold:
      return (key: 'wallet_kind_hold', icon: Icons.lock_clock, tint: AppColors.warning);
    case WalletTxKind.holdReleased:
      return (key: 'wallet_kind_hold_released', icon: Icons.lock_open_rounded, tint: AppColors.warning);
    case WalletTxKind.spend:
      return (key: 'wallet_kind_spend', icon: Icons.shopping_bag_outlined, tint: AppColors.brandPurple);
    case WalletTxKind.spendRefunded:
      return (key: 'wallet_kind_spend_refunded', icon: Icons.replay_rounded, tint: AppColors.green);
    case WalletTxKind.adjustment:
      return (key: 'wallet_kind_adjustment', icon: Icons.tune_rounded, tint: AppColors.brandPink);
    case WalletTxKind.expired:
      return (key: 'wallet_kind_expired', icon: Icons.hourglass_disabled, tint: AppColors.error);
    // A kind this app version doesn't model yet. Render it neutrally — the
    // amount is still true, and a blank row is better than a crashed list.
    case WalletTxKind.unknown:
      return (key: 'wallet_kind_unknown', icon: Icons.receipt_long_outlined, tint: AppColors.inkMuted);
  }
}

/// One row of the wallet history.
class WalletEntryTile extends StatelessWidget {
  const WalletEntryTile({super.key, required this.entry});

  final WalletTransactionModel entry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final d = _describe(entry.kind);
    final date = entry.createdAtDate;

    // A reservation moves money between "available" and "reserved" without
    // changing the balance, so it must not be printed as a plain −. Everything
    // else takes its sign from the signed amount rather than from the kind —
    // an adjustment can go either way.
    final isReservation = entry.kind.isReservation;

    // The class leads when we know it: "what was that for?" is the question
    // this screen exists to answer, and a column of "Cashback earned" rows
    // answers it for none of them. The kind then moves to the subtitle, where
    // it explains the amount rather than labelling the row. Rows with no
    // source — a manual adjustment — keep the kind as their title.
    final source = entry.sourceLabel;
    final kindLabel = d.key.tr();
    final title = source ?? kindLabel;
    final subtitle = [
      if (source != null)
        entry.isTrial ? 'wallet_source_trial'.tr(args: [kindLabel]) : kindLabel,
      if (date != null) '${date.day} ${'month_short_${date.month}'.tr()}',
      if ((entry.note ?? '').isNotEmpty) entry.note!,
    ].join(' · ');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: d.tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(d.icon, size: 20.w, color: d.tint),
          ),
          12.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.semibold14.copyWith(color: c.textPrimary),
                ),
                2.kh,
                Text(
                  // The kind, the date, and support's note on a manual
                  // correction — which is the only explanation a user will
                  // ever get for one.
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.regular12.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
          8.kw,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CoinAmount(
                amount: entry.magnitude,
                prefix: isReservation ? '' : (entry.isPositive ? '+' : '−'),
                style: AppText.semibold14,
                color: isReservation
                    ? c.textSecondary
                    : (entry.isPositive ? AppColors.green : c.textPrimary),
              ),
              if (entry.isPending) ...[
                2.kh,
                Text(
                  'wallet_pending_badge'.tr(),
                  style: AppText.regular12.copyWith(color: AppColors.warning),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

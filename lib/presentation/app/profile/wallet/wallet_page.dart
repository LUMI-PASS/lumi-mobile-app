import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/cashback.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';
import 'package:lumi_pass/presentation/app/profile/wallet/cubit/wallet_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/wallet/cubit/wallet_state.dart';
import 'package:lumi_pass/presentation/app/profile/wallet/widgets/wallet_entry_tile.dart';

/// The wallet: what you have, and where every soum of it came from.
///
/// One scroll rather than a balance screen with a "history" button behind it.
/// The balance on its own is unexplainable — "why is it 12 000?" is the whole
/// question — and a ledger is the only answer, so the two belong on one screen.
@RoutePage()
class WalletPage
    extends BasePage<WalletCubit, WalletBuildable, WalletListenable> {
  const WalletPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<WalletCubit>().load();
    super.init(context);
  }

  @override
  Widget builder(BuildContext context, WalletBuildable state) {
    final c = context.colors;
    final cubit = context.read<WalletCubit>();
    final wallet = state.wallet ?? WalletBalance.empty;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'wallet_title'.tr()),
      body: RefreshIndicator(
        color: AppColors.brandPurple,
        onRefresh: cubit.refresh,
        child: NotificationListener<ScrollNotification>(
          // Paging on scroll rather than a "load more" button: the ledger is
          // read, not navigated.
          onNotification: (n) {
            if (n.metrics.pixels >= n.metrics.maxScrollExtent - 300) {
              cubit.loadMore();
            }
            return false;
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
            children: [
              _Hero(wallet: wallet, c: c),
              24.kh,
              if (state.isLoading)
                const _HistoryShimmer()
              else if (state.isEmpty)
                _EmptyHistory(state: state, c: c)
              else ...[
                Text(
                  'wallet_history_title'.tr(),
                  style: AppText.semibold16.copyWith(color: c.textPrimary),
                ),
                4.kh,
                ...state.entries.map((e) => WalletEntryTile(entry: e)),
                if (state.isLoadingMore) ...[
                  16.kh,
                  const Center(child: CircularProgressIndicator.adaptive()),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Balance card: the mascot, what you can spend, and the two counters that
/// only appear when they're non-zero.
class _Hero extends StatelessWidget {
  const _Hero({required this.wallet, required this.c});

  final WalletBalance wallet;
  final AppColorScheme c;

  @override
  Widget build(BuildContext context) {
    final hasPending = wallet.pendingBalance > 0;
    final hasHeld = wallet.heldBalance > 0;

    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(20.r),
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Assets.images.mascot.mascotInfo.image(
            width: 120.w,
            height: 120.w,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
          8.kh,
          Text(
            'wallet_available_label'.tr(),
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
          6.kh,
          // The one number the user came for.
          CoinAmount(
            amount: wallet.available,
            style: AppText.heading20,
            color: c.textPrimary,
          ),
          if (hasPending || hasHeld) ...[
            16.kh,
            Divider(height: 1, color: c.border),
            12.kh,
            if (hasPending)
              _SubLine(
                label: 'wallet_pending_label'.tr(),
                amount: wallet.pendingBalance,
                // Earned but not matured — it will become spendable, so muted
                // rather than warned about.
                color: c.textSecondary,
              ),
            if (hasPending && hasHeld) 8.kh,
            if (hasHeld)
              _SubLine(
                label: 'wallet_held_label'.tr(),
                amount: wallet.heldBalance,
                // The line that generates support tickets: money that is
                // present but unspendable. It gets the accent and its own
                // explanation.
                color: AppColors.warning,
              ),
          ],
          if (wallet.isFrozen) ...[
            12.kh,
            Text(
              'wallet_frozen_note'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular12.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

class _SubLine extends StatelessWidget {
  const _SubLine({
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
          child: Text(label, style: AppText.regular12.copyWith(color: color)),
        ),
        CoinAmount(amount: amount, style: AppText.semibold12, color: color),
      ],
    );
  }
}

/// Nothing has ever moved in this wallet.
///
/// Explains how to get money into it rather than just saying "empty" — the
/// rate is read from the live config, so it can't drift from what actually
/// accrues, and the whole line drops out when cashback is switched off.
class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.state, required this.c});

  final WalletBuildable state;
  final AppColorScheme c;

  @override
  Widget build(BuildContext context) {
    final config = state.config;
    final rate = config == null || !config.isEnabled
        ? null
        : [
            config.rules.activity.percent,
            config.rules.trialLesson.percent,
            config.rules.course.percent,
          ].where((p) => p > 0).fold<num?>(null, (a, b) => a == null || b > a ? b : a);

    return Column(
      children: [
        24.kh,
        Assets.images.mascot.mascotHello.image(
          width: 140.w,
          height: 140.w,
          fit: BoxFit.contain,
          excludeFromSemantics: true,
        ),
        16.kh,
        Text(
          'wallet_empty_title'.tr(),
          textAlign: TextAlign.center,
          style: AppText.semibold16.copyWith(color: c.textPrimary),
        ),
        8.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            rate == null
                ? 'wallet_empty_body'.tr()
                : 'wallet_empty_body_rate'
                    .tr(args: [formatCashbackPercent(rate)]),
            textAlign: TextAlign.center,
            style: AppText.regular13.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _HistoryShimmer extends StatelessWidget {
  const _HistoryShimmer();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: List.generate(
        5,
        (_) => Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: c.border,
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              12.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12.h, width: 140.w, color: c.border),
                    6.kh,
                    Container(height: 10.h, width: 80.w, color: c.border),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

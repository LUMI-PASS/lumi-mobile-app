import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/new_coins_summary.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/cubit/app_state.dart';

/// "Lumi Coin" as the app currently knows it. Read this rather than `AppCubit`
/// directly so every coin surface asks the question the same way.
///
/// `watch`, so a tile or a price rebuilds the instant a pack is bought or a
/// booking is paid with coins. Never null: before the first sync lands it is
/// the empty summary, whose `isVisible` is false.
NewCoinsSummary watchNewCoins(BuildContext context) {
  final app = context.watch<AppCubit>().state.buildable ?? const AppBuildable();
  return app.newCoins ?? const NewCoinsSummary();
}

/// Non-listening variant for callers outside a build (checkout paths).
NewCoinsSummary readNewCoins(BuildContext context) {
  final app = context.read<AppCubit>().state.buildable ?? const AppBuildable();
  return app.newCoins ?? const NewCoinsSummary();
}

/// What a ticket costs in Lumi Coin, in a pill of its own.
///
/// The shop's coin-price pill, for the same reason it is a pill there: it says
/// "or, this way" beside a so'm price rather than reading as part of that
/// number. A SECOND price, not a discount on the first — a booking is paid
/// either wholly in coins or wholly in money.
class NewCoinPricePill extends StatelessWidget {
  const NewCoinPricePill({
    super.key,
    required this.amount,
    this.large = false,
    this.color,
  });

  final num amount;
  final bool large;

  /// The pill's fill. Defaults to the control tint, which is what the shop's
  /// pill uses; a row already filled with that tint passes its own.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color ?? c.control,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: CoinAmount(
        amount: amount,
        style: large ? AppText.semibold14 : AppText.semibold12,
        color: c.textPrimary,
        iconSize: large ? 16 : 14,
      ),
    );
  }
}

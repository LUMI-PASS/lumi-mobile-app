import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/new_coins_summary.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
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

/// What an ACTIVITY priced at [price] so'm is quoted as in coins, or null where
/// the caller keeps its so'm figure: no pack on sale and no balance (the
/// feature is invisible), no rate, or nothing to pay.
///
/// Never call it for a course or a trial — those are money-only. [sent] is the
/// server's own figure for this exact price (`new_coin_price` on a card) and
/// wins when present; `ceil(price / rate)` is the fallback for a figure the
/// server did not quote, such as the cheapest PAID ticket of an activity whose
/// cheapest ticket is free. Checkout quotes the booking again and its answer
/// is the one that is spent.
int? watchNewCoinPriceOf(BuildContext context, num price, {num? sent}) {
  final coins = watchNewCoins(context);
  if (!coins.isVisible) return null;
  if (sent != null && sent > 0) return sent.ceil();
  return newCoinPriceFor(price, coins.activityRate);
}

/// An activity's price in Lumi Coin, as the catalogue prints it: the figure
/// and the coin, with the "from" wording around it when [from] is set.
///
/// This REPLACES the so'm price rather than sitting beside it — an activity is
/// paid in coins, so a so'm figure on its card is a price nobody is charged.
/// No coupon strike-through either: a coupon plan does not discount a coin
/// price.
class NewCoinPriceText extends StatelessWidget {
  const NewCoinPriceText({
    super.key,
    required this.amount,
    this.from = false,
    this.style,
    this.color,
  });

  final num amount;
  final bool from;
  final TextStyle? style;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final textStyle = (style ?? AppText.semibold14).copyWith(color: color);
    final amountWidget = CoinAmount(amount: amount, style: textStyle);
    if (!from) return amountWidget;

    // "from {}" in English and Russian, "{} dan" in Uzbek: the wording falls
    // on either side of the figure, so the template is split around it rather
    // than assumed to be a prefix.
    const slot = '\u0001';
    final parts = 'price_from'.tr(args: [slot]).split(slot);
    final before = parts.first.trim();
    final after = parts.length > 1 ? parts.last.trim() : '';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (before.isNotEmpty) ...[
          Text(before, style: textStyle),
          SizedBox(width: 4.w),
        ],
        amountWidget,
        if (after.isNotEmpty) ...[
          SizedBox(width: 4.w),
          Text(after, style: textStyle),
        ],
      ],
    );
  }
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

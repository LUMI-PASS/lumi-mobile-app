import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/coin_amount.dart';

/// A price, the way the shop says it — in money, and in coins.
///
/// The money figure carries the weight and the brand colour; the currency word
/// is deliberately smaller and grey. That split is the whole trick — "30 000"
/// is the thing being read, "so'm" is a unit, and setting them at the same
/// size makes a price tag look like a sentence.
///
/// [coinPrice] renders as a pill under it, carrying the coin mark. It is a
/// SECOND PRICE, not a conversion of the first: merch is the one place where a
/// coin is not a so'm. The pill shape is doing work here — it says "or, this
/// way" rather than looking like part of the number above it, which is what a
/// bare coin-marked figure next to a so'm figure would look like.
class ShopPrice extends StatelessWidget {
  const ShopPrice({
    super.key,
    required this.price,
    this.oldPrice,
    this.coinPrice,
    this.large = false,
    this.reserveOldPriceLine = false,
    this.oldPriceWithUnit = false,
  });

  final num price;

  /// The pre-discount price. Ignored unless it is actually higher.
  final num? oldPrice;

  /// What the same goods cost in coins. Omitted where the buyer has already
  /// chosen how they are paying — a coin-funded order has no use for the so'm
  /// price, and repeating both would invite the reader to add them up.
  final num? coinPrice;

  final bool large;

  /// Keep the struck-through line's height even when there is no discount.
  ///
  /// The grid needs this: tiles are one fixed height, so an undiscounted card
  /// has to occupy the same space as a discounted one or the row goes ragged.
  final bool reserveOldPriceLine;

  /// Repeat the currency word on the struck-through line.
  ///
  /// Off in the grid, where the tile is two columns wide and a bare number is
  /// unambiguous directly under a price that already carries the unit. On in
  /// the basket, where the line has room and the two figures are the whole
  /// point of the row — "110 000 so'm" struck through reads as a price that
  /// was, where "110 000" alone reads as a quantity.
  final bool oldPriceWithUnit;

  bool get _discounted => (oldPrice ?? 0) > price;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final figure = large ? AppText.bold18 : AppText.bold16;
    final unit = large ? AppText.regular14 : AppText.regular13;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: price.toGrouped(),
                      style: figure.copyWith(color: AppColors.brandPurple),
                    ),
                    TextSpan(
                      text: ' ${uzsCurrencyLabel()}',
                      style: unit.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_discounted) ...[
              6.kw,
              _DiscountTag(percent: _percentOff),
            ],
          ],
        ),
        if (_discounted)
          Text(
            oldPriceWithUnit
                ? '${oldPrice!.toGrouped()} ${uzsCurrencyLabel()}'
                : oldPrice!.toGrouped(),
            style: AppText.regular13.copyWith(
              color: c.textPlaceholder,
              decoration: TextDecoration.lineThrough,
              decorationColor: c.textPlaceholder,
            ),
          )
        else if (reserveOldPriceLine)
          // An empty line of the same metrics — not a SizedBox of guessed
          // height, so it tracks the OS text-size setting like real text does.
          Text('', style: AppText.regular13),
        if (coinPrice != null && coinPrice! > 0) ...[
          4.kh,
          _CoinPricePill(amount: coinPrice!, large: large),
        ],
      ],
    );
  }

  int get _percentOff =>
      (100 - (price / oldPrice!) * 100).round().clamp(1, 99);
}

/// "↓67%" — how much is off, not what it now costs.
class _DiscountTag extends StatelessWidget {
  const _DiscountTag({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.south_rounded,
          size: 12.w,
          color: AppColors.brandPink,
        ),
        Text(
          '$percent%',
          style: AppText.semibold12.copyWith(color: AppColors.brandPink),
        ),
      ],
    );
  }
}

/// The coin price, in a pill of its own.
class _CoinPricePill extends StatelessWidget {
  const _CoinPricePill({required this.amount, required this.large});

  final num amount;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(8.r),
      ),
      // The amount keeps the coin mark, which is the rule for every
      // wallet-side number in the app — and here it is the only thing
      // distinguishing this figure from the so'm one above it.
      child: CoinAmount(
        amount: amount,
        style: large ? AppText.semibold14 : AppText.semibold12,
        color: c.textPrimary,
        iconSize: large ? 16 : 14,
      ),
    );
  }
}

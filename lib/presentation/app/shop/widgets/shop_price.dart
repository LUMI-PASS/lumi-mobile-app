import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// A price, the way the shop says it.
///
/// The figure carries the weight and the brand colour; the currency word is
/// deliberately smaller and grey. That split is the whole trick — "30 000" is
/// the thing being read, "so'm" is a unit, and setting them at the same size
/// makes a price tag look like a sentence.
///
/// Never coin-marked: the coin mark belongs to wallet-side numbers, and a
/// price wearing it would read as a second currency. Coins enter at checkout.
class ShopPrice extends StatelessWidget {
  const ShopPrice({
    super.key,
    required this.price,
    this.oldPrice,
    this.large = false,
    this.reserveOldPriceLine = false,
  });

  final num price;

  /// The pre-discount price. Ignored unless it is actually higher.
  final num? oldPrice;

  final bool large;

  /// Keep the struck-through line's height even when there is no discount.
  ///
  /// The grid needs this: tiles are one fixed height, so an undiscounted card
  /// has to occupy the same space as a discounted one or the row goes ragged.
  final bool reserveOldPriceLine;

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
            oldPrice!.toGrouped(),
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

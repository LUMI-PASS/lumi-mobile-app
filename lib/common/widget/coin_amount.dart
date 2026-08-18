import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// A wallet amount, marked with the Lumi coin instead of a "so'm" suffix.
///
/// **One Lumi coin is one so'm** — this is a skin, not a second currency, and
/// nothing anywhere converts between them. It exists because balance, cashback
/// and redemption are Lumi's own money rather than the buyer's cash, and giving
/// them their own mark is what stops "12 000" on the wallet card reading as the
/// same thing as "12 000" on a price tag.
///
/// Prices stay in so'm. Use this only for wallet-side numbers: balances, earned
/// cashback, and the part of an order settled from the balance. Printing both a
/// coin and a "so'm" suffix on one number would read as two currencies, which
/// is exactly the confusion this is meant to avoid — so it deliberately renders
/// the digits alone ([PriceNumFormatter.toGrouped]) and never `toRawUzsPrice`.
class CoinAmount extends StatelessWidget {
  const CoinAmount({
    super.key,
    required this.amount,
    this.style,
    this.color,
    this.prefix,
    this.iconSize,
  });

  final num amount;

  /// Text style for the digits. The coin scales with the font size unless
  /// [iconSize] overrides it, so a heading-sized amount gets a bigger coin
  /// without every caller doing the arithmetic.
  final TextStyle? style;

  /// Tint for the digits only — never for the coin, which is fixed gold
  /// artwork and must not be recoloured to match a row's text.
  final Color? color;

  /// A sign or qualifier printed before the digits: `−`, `+`, `~`.
  final String? prefix;

  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final textStyle = (style ?? AppText.semibold14).copyWith(color: color);
    final size = iconSize ?? (textStyle.fontSize ?? 14) * 1.15;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('${prefix ?? ''}${amount.toGrouped()}', style: textStyle),
        SizedBox(width: 4.w),
        Assets.icons.coinLumi.image(
          width: size.w,
          height: size.w,
          // Never tinted, and never given a semantic label — the coin is
          // decoration on a number the text already reads out.
          excludeFromSemantics: true,
        ),
      ],
    );
  }
}

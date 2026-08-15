import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';

extension RussianDateFormat on DateTime {
  String toRussianShortFormat(BuildContext context) {
    final now = DateTime.now().toLocal();
    final localDate = this.toLocal();

    final monthFormat = DateFormat.MMMM(context.locale.languageCode);
    final day = localDate.day;
    final month = monthFormat.format(localDate);
    final year = localDate.year;

    final showYear = year != now.year;

    return showYear ? '$day $month $year' : '$day $month';
  }
}


extension PriceStringFormatter on String {
  String toFormattedPrice() {
    final cleaned = replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) return '0';

    final number = double.tryParse(cleaned) ?? 0;
    final divided = (number / 100).round();

    final integerPart = divided.toString();

    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ' ',
    );

    return formattedInteger;
  }
}

String _uzsCurrencyLabel() {
  switch (currentLang) {
    case 'ru':
      return 'сум';
    case 'uz':
      return "so'm";
    default:
      return 'sum';
  }
}

extension PriceNumFormatter on num {
  /// Coin amount → `"50 000 so'm"` style string.
  String toUzsPrice() => "${toString().toFormattedPrice()} ${_uzsCurrencyLabel()}";

  /// Raw UZS amount (already in soums) → `"250 000 so'm"`.
  /// Use this for prices that are NOT stored in coins/tiyin.
  String toRawUzsPrice() => "${toGrouped()} ${_uzsCurrencyLabel()}";

  /// Just the digits, space-grouped: `250000` → `"250 000"`.
  ///
  /// For amounts whose unit is shown some other way — wallet balances carry the
  /// Lumi coin mark instead of a "so'm" suffix (see [CoinAmount]), and printing
  /// both would read as two different currencies.
  String toGrouped() => toInt().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ' ',
      );
}

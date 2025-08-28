import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
    // Remove everything except digits and decimal point
    final cleaned = replaceAll(RegExp(r'[^\d.]'), '');
    if (cleaned.isEmpty) return '0';

    // Parse the cleaned string to double
    final number = double.tryParse(cleaned) ?? 0;

    // Split into integer and decimal parts
    final parts = number.toString().split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Format integer part with spaces every 3 digits
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ' ',
    );

    // Return formatted price
    if (decimalPart.isEmpty || decimalPart == '0') {
      return formattedInteger;
    } else {
      return formattedInteger;
    }
  }
}

// Usage examples:
// '2300.1222'.toFormattedPrice() → '2 300.1222'
// '0.33'.toFormattedPrice() → '0.33'
// '23000'.toFormattedPrice() → '23 000'
// '$2,300.50'.toFormattedPrice() → '2 300.5'
// 'abc123def'.toFormattedPrice() → '123'

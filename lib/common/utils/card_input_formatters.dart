import 'package:flutter/services.dart';

/// Groups a card number into blocks of four as the user types:
/// `8600123456789012` → `8600 1234 5678 9012`.
///
/// Pair it with [FilteringTextInputFormatter.digitsOnly] and a length limit —
/// this one only inserts the spacing.
class CardNumberInputFormatter extends TextInputFormatter {
  const CardNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats an expiry as `MM/YY` while typing.
///
/// The slash only appears once there is something to put after it, so
/// backspacing past it doesn't leave a dangling separator.
class ExpiryInputFormatter extends TextInputFormatter {
  const ExpiryInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 4 ? digits.substring(0, 4) : digits;
    final text = capped.length > 2
        ? '${capped.substring(0, 2)}/${capped.substring(2)}'
        : capped;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// `MM/YY` (or four bare digits) → `MMYY`, the form the gateway expects.
/// Returns '' when the input isn't a complete expiry.
String expiryToMmYy(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  return digits.length == 4 ? digits : '';
}

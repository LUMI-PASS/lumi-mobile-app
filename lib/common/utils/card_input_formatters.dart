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

/// `MM/YY` (as typed) → `YYMM` (as the gateway wants). `09/30` → `3009`.
///
/// **The order is the whole point, and it is easy to get backwards.** WLCM's
/// own type comment calls this field "MMYY, e.g. 3003" — but 3003 cannot be
/// MMYY, because there is no month 30. Their Subscribe API documents `YYMM`
/// outright, and both booking screens have sent YYMM since the rail was built.
///
/// Sending MMYY does not fail loudly: `0930` is read as year 09, and the
/// gateway answers `card_is_expired` for a card that expires in 2030.
///
/// Returns '' when the input isn't a complete expiry.
String expiryToYyMm(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.length != 4) return '';
  return digits.substring(2, 4) + digits.substring(0, 2);
}

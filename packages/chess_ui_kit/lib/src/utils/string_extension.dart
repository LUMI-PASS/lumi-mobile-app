import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:chess_ui_kit/src/services/number_masking.dart';

extension StringExtension on String {
  String? formatPhone(Country? country) {
    if (country != null) {
      return country.dialCode + replaceAll(RegExp(r'\D+'), '');
    }
    return null;
  }

  String get getMaskedFormat {
    final formatter = MaskTextInputFormatter(
      mask: "+### ## ###-##-##",
      initialText: this,
    );

    return formatter.getMaskedText();
  }

  String formatUrl(String baseUrl) {
    // Check if the url starts with "http" or "https"
    if (startsWith('http')) {
      // If it's a full link, return it as is
      return this;
    } else {
      // If it's a relative link, append the baseUrl
      return baseUrl + this;
    }
  }
}

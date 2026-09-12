import 'package:lumi_pass/common/utils/app_locale.dart';

/// Reads a `{uz, ru, en}` map in the user's language.
///
/// Falls through rather than returning an empty string when a translation is
/// missing: a product named only in Russian should still be readable by
/// somebody browsing in Uzbek. Showing nothing is never the better answer.
String multiLang(Map<String, dynamic>? map, {String fallback = ''}) {
  if (map == null) return fallback;
  final value = map[currentLang] ?? map['ru'] ?? map['uz'] ?? map['en'];
  if (value is String && value.trim().isNotEmpty) return value.trim();
  return fallback;
}

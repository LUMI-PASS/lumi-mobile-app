import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';

/// Returns the current language code for API calls ('uz', 'ru', 'en').
/// Reads from storage (set when user changes language).
/// Falls back to 'en'.
String get currentLang {
  try {
    final stored = getIt<Storage>().localeCode.call();
    if (stored != null && stored.isNotEmpty) return stored;
  } catch (_) {}
  return 'uz';
}

/// Initialize the lang in storage if not yet set.
void initLangIfNeeded(String langCode) {
  try {
    final stored = getIt<Storage>().localeCode.call();
    if (stored == null || stored.isEmpty) {
      getIt<Storage>().localeCode.set(langCode);
    }
  } catch (_) {}
}

/// Save language code to storage for API usage.
void setCurrentLang(String langCode) {
  try {
    getIt<Storage>().localeCode.set(langCode);
  } catch (_) {}
}

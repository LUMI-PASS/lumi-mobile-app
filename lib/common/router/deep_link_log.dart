import 'package:flutter/foundation.dart';

/// Console logger for the deep-link path.
///
/// Uses [debugPrint] rather than `dart:developer`'s `log()` on purpose:
/// `flutter run` does NOT echo `log()` output on iOS — it goes to the VM
/// service, so it is visible in DevTools and nowhere else. Every line the
/// deep-link code wrote was therefore invisible in the terminal, which is the
/// one place anyone actually watches while testing a link.
///
/// [kDebugMode]-gated so a release build stays quiet.
void dlog(String message) {
  if (kDebugMode) debugPrint('[DEEPLINK] $message');
}

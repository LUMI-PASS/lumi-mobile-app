import 'package:flutter/foundation.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:js_interop';

// Telegram WebApp JS interop
@JS('Telegram.WebApp')
external TelegramWebApp? get _telegramWebApp;

@JS()
@staticInterop
class TelegramWebApp {}

extension TelegramWebAppExt on TelegramWebApp {
  external void expand();
  external void ready();
  external void close();
  external void enableClosingConfirmation();
  external void disableClosingConfirmation();
  external TelegramInitData get initDataUnsafe;
  external String get initData;
  external String get colorScheme; // 'light' | 'dark'
  external TelegramThemeParams get themeParams;
}

@JS()
@staticInterop
class TelegramInitData {}

extension TelegramInitDataExt on TelegramInitData {
  external TelegramUser? get user;
}

@JS()
@staticInterop
class TelegramUser {}

extension TelegramUserExt on TelegramUser {
  external int get id;
  external String get first_name;
  external String? get last_name;
  external String? get username;
  external String? get language_code;
}

@JS()
@staticInterop
class TelegramThemeParams {}

extension TelegramThemeParamsExt on TelegramThemeParams {
  external String? get bg_color;
  external String? get text_color;
  external String? get hint_color;
  external String? get link_color;
  external String? get button_color;
  external String? get button_text_color;
}

/// Safe wrapper — all calls are no-ops outside of Telegram or on mobile.
class TelegramWebAppHelper {
  static bool get isAvailable =>
      kIsWeb && _telegramWebApp != null;

  static void expand() {
    if (isAvailable) _telegramWebApp!.expand();
  }

  static void ready() {
    if (isAvailable) _telegramWebApp!.ready();
  }

  static void close() {
    if (isAvailable) _telegramWebApp!.close();
  }

  /// Returns the Telegram user ID if running inside a Telegram Mini App.
  static int? get telegramUserId {
    if (!isAvailable) return null;
    return _telegramWebApp!.initDataUnsafe.user?.id;
  }

  /// Raw initData string for server-side validation.
  static String? get initData {
    if (!isAvailable) return null;
    final data = _telegramWebApp!.initData;
    return data.isEmpty ? null : data;
  }

  static bool get isDarkTheme {
    if (!isAvailable) return false;
    return _telegramWebApp!.colorScheme == 'dark';
  }
}

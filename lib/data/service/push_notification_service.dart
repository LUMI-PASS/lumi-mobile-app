import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

// ignore: avoid_print
void _log(String msg) => print('[FCM] $msg');

/// Manages the Firebase device token lifecycle:
///   1. Asks for notification permission (iOS).
///   2. Resolves the FCM token (waits for APNs on iOS so the first call
///      doesn't return null on a fresh install).
///   3. Registers the token with the backend so push routing works.
///   4. Listens for token refresh and re-registers automatically.
///   5. Unregisters on logout.
///
/// Wire this once after the user is authenticated — the registration
/// endpoint is auth-gated. Call [unregister] before clearing the auth
/// tokens so the backend hears about the logout while the request is
/// still authorized.
@lazySingleton
class PushNotificationService {
  PushNotificationService(this._dio, this._storage);

  final Dio _dio;
  final Storage _storage;

  StreamSubscription<String>? _refreshSub;
  bool _registering = false;

  Future<void> registerCurrentDevice({String? locale}) async {
    if (_registering) return;
    _registering = true;
    try {
      final messaging = FirebaseMessaging.instance;

      // On web, requesting permission requires a user gesture — skip the prompt
      // and only proceed if permission was already granted by a previous gesture.
      if (kIsWeb) {
        final current = await messaging.getNotificationSettings();
        if (current.authorizationStatus != AuthorizationStatus.authorized) {
          _log('permission not granted on web — skipping register');
          return;
        }
      } else {
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        _log('permission status: ${settings.authorizationStatus}');
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          _log('permission denied — skipping register');
          return;
        }
      }

      // Subscribe to refresh before calling getToken() so we never miss the
      // token on iOS fresh installs where APNs isn't ready yet.
      _refreshSub ??= messaging.onTokenRefresh.listen((next) {
        _log('token refreshed via service — re-registering');
        _sendToBackend(next, locale: locale);
      });

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        _log('waiting for APNs token…');
        final ready = await _waitForApnsToken(messaging);
        if (!ready) {
          _log('APNs token not ready — will retry via onTokenRefresh');
          return;
        }
        _log('APNs token ready');
      }

      _log('fetching FCM token…');
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) {
        _log('FCM token unavailable');
        return;
      }
      _log('FCM token obtained: $token');
      await _sendToBackend(token, locale: locale);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('apns-token-not-set')) {
        _log('APNs token not yet set — registration deferred');
        return;
      }
      _log('register failed: $e');
    } finally {
      _registering = false;
    }
  }

  Future<void> unregister() async {
    final stored = _storage.deviceToken();
    _refreshSub?.cancel();
    _refreshSub = null;
    if (stored == null || stored.isEmpty) {
      _log('unregister: no stored token, skipping');
      return;
    }
    _log('unregistering device token: $stored');
    try {
      await _dio.delete('notifications/devices/$stored');
      _log('unregister backend DELETE OK');
    } catch (e) {
      _log('unregister backend DELETE failed (ignored): $e');
    }
    try {
      await FirebaseMessaging.instance.deleteToken();
      _log('FCM token deleted');
    } catch (e) {
      _log('FCM deleteToken failed (ignored): $e');
    }
  }

  Future<void> _sendToBackend(String token, {String? locale}) async {
    try {
      // The app's OWN language, not the phone's, and read here rather than
      // asked of every caller — all three of them (login, sign-up, warm start)
      // called `registerCurrentDevice()` bare, so this field went up null and
      // the backend had no record of ANY user's language. That is what makes a
      // language-targeted campaign possible at all: without it every device
      // falls into `getUserLocale`'s 'uz' default.
      //
      // An explicit argument still wins, for a caller registering on behalf of
      // a language the storage hasn't been switched to yet.
      final resolvedLocale = locale ?? _storage.localeCode();

      String? appVersion;
      try {
        final info = await PackageInfo.fromPlatform();
        appVersion = info.version;
      } catch (_) {/* optional */}

      final platform = kIsWeb
          ? 'web'
          : defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android';

      _log('registering with backend — platform:$platform version:$appVersion locale:$resolvedLocale');
      await _dio.post('notifications/devices', data: {
        'token': token,
        'platform': platform,
        if (appVersion != null) 'app_version': appVersion,
        if (resolvedLocale != null && resolvedLocale.isNotEmpty)
          'locale': resolvedLocale,
      });
      await _storage.deviceToken.set(token);
      _log('device registered successfully');
    } catch (e) {
      _log('register POST failed: $e');
    }
  }

  /// Polls for the APNs token that FCM requires on iOS before issuing an FCM
  /// token. Returns true when the token is available, false if it times out.
  Future<bool> _waitForApnsToken(FirebaseMessaging messaging) async {
    for (var i = 0; i < 10; i++) {
      final apns = await messaging.getAPNSToken();
      if (apns != null && apns.isNotEmpty) return true;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }
}

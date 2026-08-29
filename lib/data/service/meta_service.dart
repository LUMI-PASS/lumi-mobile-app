import 'dart:async';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/env/meta_env.dart';
import 'package:lumi_pass/data/service/analytics_event.dart';

// ignore: avoid_print
void _log(String msg) => print('[Meta] $msg');

/// Meta's standard App Events catalogue. Same reasoning as [AfEvent] in
/// [AppsFlyerService]: sending these instead of our own names is what lets
/// Meta Ads optimize campaigns against these events — anything else only
/// counts as a custom event.
class MetaEvent {
  const MetaEvent._();

  static const login = 'login';
  static const addToCart = 'fb_mobile_add_to_cart';
}

/// Wraps `facebook_app_events`: App Events logging and advanced matching for
/// Meta Ads attribution/optimization.
///
/// Nothing here is on a critical path — every method swallows its errors and
/// no-ops when the SDK is unavailable (web, a build without an App ID). Ads
/// telemetry must never break a flow.
///
/// Events reach this class through [AnalyticsService], which mirrors every
/// Firebase event here alongside AppsFlyer; screens don't call it directly.
@lazySingleton
class MetaService {
  final FacebookAppEvents _events = FacebookAppEvents();

  bool _enabled = false;

  bool get isEnabled => _enabled;

  /// Starts the SDK. Call once, any time after [AppsFlyerService.init] raises
  /// the shared ATT prompt (order doesn't matter functionally — the native
  /// SDK reads the iOS ATT verdict itself — but keeping Meta second avoids
  /// two SDKs racing to be the one that triggers the first frame).
  Future<void> init() async {
    if (_enabled) return;

    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      _log('skipped — unsupported platform');
      return;
    }
    if (!MetaEnv.hasCredentials) {
      _log('skipped — no App ID (pass --dart-define=META_APP_ID=... '
          '--dart-define=META_CLIENT_TOKEN=...)');
      return;
    }

    try {
      // Consent to *attempt* advertiser-id collection. On iOS the SDK only
      // actually collects it once ATT is authorized — this doesn't bypass
      // that. On Android there's no OS-level gate, so this is the real switch.
      await _events.setAdvertiserIdCollectionEnabled(true);
      await _events.activateApp();
      _enabled = true;
      _log('initialised');
    } catch (e) {
      _log('init failed (ignored): $e');
    }
  }

  /// Advanced matching: lets Meta match events to a user via hashed
  /// email/phone even without a click id. Call after login/registration.
  Future<void> setUserData({String? email, String? phone}) async {
    if (!_enabled) return;
    try {
      await _events.setUserData(email: email, phone: phone);
    } catch (e) {
      _log('setUserData failed (ignored): $e');
    }
  }

  /// Drops the identity on logout.
  Future<void> clearUserData() async {
    if (!_enabled) return;
    try {
      await _events.clearUserData();
    } catch (e) {
      _log('clearUserData failed (ignored): $e');
    }
  }

  /// Mirrors one of our [AnalyticsEvent]s into Meta App Events, translated
  /// onto a typed standard event where the params support it. Fire-and-forget.
  Future<void> logAppEvent(String name, Map<String, Object> params) async {
    if (!_enabled) return;

    // Meta counts sessions itself via activateApp(); re-sending app_open
    // would double-count it, same reasoning as the AppsFlyer mirror.
    if (name == AnalyticsEvent.appOpen) return;

    try {
      final contentId = _contentId(params);
      final contentType = _contentType(params);
      final amount = _amount(params);
      final currency = (params['currency'] as String?) ?? 'UZS';

      switch (name) {
        case AnalyticsEvent.login:
          await _events.logEvent(name: MetaEvent.login, parameters: params);

        case AnalyticsEvent.signUp:
        case AnalyticsEvent.registrationCompleted:
          await _events.logCompletedRegistration(
            registrationMethod: params['method'] as String?,
            parameters: params,
          );

        case AnalyticsEvent.classDetailViewed:
        case AnalyticsEvent.activityDetailViewed:
        case AnalyticsEvent.branchDetailViewed:
          await _events.logViewContent(
            id: contentId,
            type: contentType,
            currency: amount != null ? currency : null,
            price: amount,
            parameters: params,
          );

        case AnalyticsEvent.bookButtonTapped:
          // logAddToCart requires id/type/currency/price — fall back to a
          // plain event when the call site didn't send enough to fill them.
          if (contentId != null && contentType != null && amount != null) {
            await _events.logAddToCart(
              id: contentId,
              type: contentType,
              currency: currency,
              price: amount,
              parameters: params,
            );
          } else {
            await _events.logEvent(
              name: MetaEvent.addToCart,
              parameters: params,
            );
          }

        case AnalyticsEvent.bookingCheckoutStarted:
        case AnalyticsEvent.checkoutPageOpened:
        case AnalyticsEvent.planPurchaseStarted:
        case AnalyticsEvent.subscriptionPurchaseStarted:
          await _events.logInitiatedCheckout(
            totalPrice: amount,
            currency: currency,
            contentType: contentType,
            contentId: contentId,
            parameters: params,
          );

        case AnalyticsEvent.paymentSucceeded:
          if (amount != null) {
            await _events.logPurchase(
              amount: amount,
              currency: currency,
              parameters: params,
            );
          } else {
            // No amount to report — still worth a custom event over nothing.
            await _events.logEvent(name: name, parameters: params);
          }

        default:
          await _events.logEvent(name: name, parameters: params);
      }
      _log('event:$name');
    } catch (e) {
      _log('logAppEvent($name) failed (ignored): $e');
    }
  }

  // ─── Param extraction ──────────────────────────────────────────────────────
  // Same source fields AppsFlyerService derives af_content_id/af_revenue from.

  static const _contentIdKeys = <String, String>{
    'class_id': 'class',
    'activity_id': 'activity',
    'plan_id': 'plan',
    'branch_id': 'branch',
  };

  String? _contentId(Map<String, Object> params) {
    for (final key in _contentIdKeys.keys) {
      final id = params[key];
      if (id != null && (id is! String || id.isNotEmpty)) return id.toString();
    }
    return null;
  }

  String? _contentType(Map<String, Object> params) {
    for (final entry in _contentIdKeys.entries) {
      final id = params[entry.key];
      if (id != null && (id is! String || id.isNotEmpty)) return entry.value;
    }
    return null;
  }

  double? _amount(Map<String, Object> params) {
    final amount = params['amount'] ?? params['price'];
    if (amount is num) return amount.toDouble();
    return null;
  }
}

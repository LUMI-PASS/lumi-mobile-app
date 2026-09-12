import 'dart:async';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/env/meta_env.dart';
import 'package:lumi_pass/data/service/analytics_event.dart';
import 'package:lumi_pass/data/storage/storage.dart';

// ignore: avoid_print
void _log(String msg) => print('[Meta] $msg');

/// Meta's standard in-app event names. Same reasoning as `AfEvent`: only
/// catalogue events can be optimised against and attributed to ad spend in Ads
/// Manager. Anything else arrives as a custom event and can only be counted.
///
/// Spelled out here rather than read off [FacebookAppEvents] so the mapping
/// table below reads the same way the AppsFlyer one does.
class MetaEvent {
  const MetaEvent._();

  static const completeRegistration = 'fb_mobile_complete_registration';
  static const contentView = 'fb_mobile_content_view';
  static const addToCart = 'fb_mobile_add_to_cart';
  static const initiatedCheckout = 'fb_mobile_initiated_checkout';
  static const purchase = 'fb_mobile_purchase';
}

/// Meta's standard event parameters.
class MetaParam {
  const MetaParam._();

  static const contentId = 'fb_content_id';
  static const contentType = 'fb_content_type';
  static const currency = 'fb_currency';
  static const orderId = 'fb_order_id';
  static const numItems = 'fb_num_items';
  static const registrationMethod = 'fb_registration_method';
}

/// Wraps the Meta (Facebook) SDK for app-install and in-app-event attribution.
///
/// Mirrors [AppsFlyerService] in shape and in guarantees: nothing here is on a
/// critical path, every method swallows its errors, and the whole class turns
/// into no-ops when Meta can't run (web, an unconfigured build). Attribution
/// must never break a user flow.
///
/// Events reach this class through [AnalyticsService], which mirrors every
/// Firebase event here; screens don't call it directly.
///
/// **The SDK is configured natively, not from Dart.** The app id and client
/// token are read out of `Info.plist` / `strings.xml` at process start — see
/// `docs/META.md`. [MetaEnv] only decides whether we talk to it at all.
@lazySingleton
class MetaService {
  MetaService(this._storage);

  final Storage _storage;

  FacebookAppEvents? _sdk;

  bool get isEnabled => _sdk != null;

  /// Brings the SDK up. Call once, before `runApp`.
  ///
  /// Returns normally on every platform — when Meta can't run, [isEnabled]
  /// stays false and the rest of the class is inert.
  Future<void> init() async {
    if (_sdk != null) return;

    // The plugin is iOS/Android only; the web build shares this DI graph.
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      _log('skipped — unsupported platform');
      return;
    }
    if (!MetaEnv.isConfigured) {
      _log('skipped — no app id / client token (see docs/META.md)');
      return;
    }

    try {
      final sdk = FacebookAppEvents();

      // The IDFA (iOS) / GAID (Android) is what lets Meta match an install
      // back to the ad that caused it. On iOS 17+ the SDK ignores this unless
      // ATT was granted — AppsFlyerService already raises that prompt one
      // frame after launch, and both SDKs read the same verdict.
      await sdk.setAdvertiserIdCollectionEnabled(true);

      // Attribute the session to the logged-in user from the first event when
      // we already know who they are (warm start after a previous login).
      final userId = _storage.userId();
      if (userId != null && userId.isNotEmpty) await sdk.setUserID(userId);

      // Logs the install/activation. Redundant while
      // FacebookAutoLogAppEventsEnabled is true, but harmless — the SDK
      // deduplicates activations — and it keeps this working if that flag is
      // ever turned off.
      await sdk.activateApp();

      _sdk = sdk;
      _log('initialised (app ${MetaEnv.appId})');
    } catch (e) {
      _log('init failed (ignored): $e');
    }
  }

  /// Ties subsequent events to our own user id. Call after login.
  Future<void> setUserId(String? id) async {
    if (id == null || id.isEmpty) return;
    try {
      await _sdk?.setUserID(id);
    } catch (e) {
      _log('setUserId failed (ignored): $e');
    }
  }

  /// Drops the identity on logout. The device keeps its own Meta identifiers
  /// and stays attributed, which is what we want.
  Future<void> clearUserId() async {
    try {
      await _sdk?.clearUserID();
    } catch (e) {
      _log('clearUserId failed (ignored): $e');
    }
  }

  /// Mirrors one of our [AnalyticsEvent]s into Meta, translated onto the
  /// standard catalogue where one fits. Fire-and-forget.
  Future<void> logAppEvent(String name, Map<String, Object> params) async {
    final sdk = _sdk;
    if (sdk == null) return;

    // The SDK logs its own activation event; re-sending app_open would
    // double-count every session in Ads Manager.
    if (name == AnalyticsEvent.appOpen) return;

    try {
      final metaName = _standardEventNames[name] ?? name;
      final values = _metaValues(metaName, params);
      final amount = _amountOf(params);

      // A purchase has to go through logPurchase: it is what populates the
      // revenue/ROAS columns. logEvent('fb_mobile_purchase') does not.
      if (metaName == MetaEvent.purchase && amount != null) {
        await sdk.logPurchase(
          amount: amount,
          currency: _currencyOf(params),
          parameters: values,
        );
        _log('purchase:$amount ${_currencyOf(params)} values:$values');
        return;
      }

      await sdk.logEvent(
        name: metaName,
        parameters: values.isEmpty ? null : values,
        // Anything with a price carries it as the summable value, which is
        // what Meta optimises "value" campaigns on.
        valueToSum: amount,
      );
      _log('event:$metaName values:$values');
    } catch (e) {
      _log('logAppEvent($name) failed (ignored): $e');
    }
  }

  // ─── Event translation ─────────────────────────────────────────────────────

  /// Our names → Meta's catalogue. Anything absent is sent unchanged as a
  /// custom event.
  ///
  /// There is deliberately no entry for `login`: Meta has no standard login
  /// event, so it goes through under its own name.
  static const _standardEventNames = <String, String>{
    AnalyticsEvent.signUp: MetaEvent.completeRegistration,
    AnalyticsEvent.registrationCompleted: MetaEvent.completeRegistration,
    AnalyticsEvent.classDetailViewed: MetaEvent.contentView,
    AnalyticsEvent.activityDetailViewed: MetaEvent.contentView,
    AnalyticsEvent.branchDetailViewed: MetaEvent.contentView,
    AnalyticsEvent.bookButtonTapped: MetaEvent.addToCart,
    AnalyticsEvent.bookingCheckoutStarted: MetaEvent.initiatedCheckout,
    AnalyticsEvent.planPurchaseStarted: MetaEvent.initiatedCheckout,
    AnalyticsEvent.subscriptionPurchaseStarted: MetaEvent.initiatedCheckout,
    AnalyticsEvent.checkoutPageOpened: MetaEvent.initiatedCheckout,
    AnalyticsEvent.paymentSucceeded: MetaEvent.purchase,
  };

  /// Same id-carrying params [AppsFlyerService] reads, mapped to the content
  /// type they describe.
  static const _contentIdKeys = <String, String>{
    'class_id': 'class',
    'activity_id': 'activity',
    'plan_id': 'plan',
    'branch_id': 'branch',
  };

  /// Params that must never reach Meta.
  ///
  /// [AnalyticsService] stamps **every** event with `user_id` and
  /// `phone_number` for our own reporting. Meta's platform terms forbid
  /// sending personal data as event parameters — a phone number in a
  /// parameter is exactly the case they call out — and events carrying it get
  /// dropped or the app flagged. The user id still reaches Meta, but through
  /// `setUserID`, which is the supported channel and hashes it natively.
  static const _piiKeys = <String>{'phone_number', 'user_id'};

  /// Meta only accepts `String` / `num` / `bool` parameter values, so
  /// everything else is stringified.
  Map<String, dynamic> _metaValues(
    String metaName,
    Map<String, Object> params,
  ) {
    final values = <String, dynamic>{};
    params.forEach((key, value) {
      if (_piiKeys.contains(key)) return;
      values[key] = value is num || value is bool ? value : value.toString();
    });

    for (final entry in _contentIdKeys.entries) {
      final id = params[entry.key];
      if (id == null || (id is String && id.isEmpty)) continue;
      values[MetaParam.contentId] = id is num ? id : id.toString();
      values[MetaParam.contentType] = entry.value;
      break;
    }

    final orderId = params['order_id'];
    if (orderId != null) {
      values[MetaParam.orderId] =
          orderId is num ? orderId : orderId.toString();
    }

    final tickets = params['ticket_count'];
    if (tickets is num) values[MetaParam.numItems] = tickets;

    final method = params['method'];
    if (method != null && metaName == MetaEvent.completeRegistration) {
      values[MetaParam.registrationMethod] = method.toString();
    }

    if (_amountOf(params) != null) {
      values[MetaParam.currency] = _currencyOf(params);
    }

    return values;
  }

  /// `amount` is what the checkout flow sends; `price` is what the detail
  /// pages send. Either way it's the sum in soʻm.
  double? _amountOf(Map<String, Object> params) {
    final amount = params['amount'] ?? params['price'];
    return amount is num ? amount.toDouble() : null;
  }

  String _currencyOf(Map<String, Object> params) {
    final currency = params['currency'];
    return currency is String && currency.isNotEmpty
        ? currency
        : MetaEnv.currency;
  }
}

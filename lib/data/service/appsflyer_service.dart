import 'dart:async';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/env/app_env.dart';
import 'package:lumi_pass/common/env/appsflyer_env.dart';
import 'package:lumi_pass/data/service/analytics_event.dart';
import 'package:lumi_pass/data/storage/storage.dart';

// ignore: avoid_print
void _log(String msg) => print('[AppsFlyer] $msg');

/// AppsFlyer's standard in-app event names. Sending these instead of our own
/// names is what lets the dashboard build install→purchase funnels and report
/// ROAS per media source; anything not in the catalogue arrives as a custom
/// event and can only be counted, not attributed to spend.
class AfEvent {
  const AfEvent._();

  static const login = 'af_login';
  static const completeRegistration = 'af_complete_registration';
  static const contentView = 'af_content_view';
  static const addToCart = 'af_add_to_cart';
  static const initiatedCheckout = 'af_initiated_checkout';
  static const purchase = 'af_purchase';
}

/// Standard AppsFlyer event parameters. Same reasoning as [AfEvent] — revenue
/// only shows up in the dashboard under `af_revenue` + `af_currency`.
class AfParam {
  const AfParam._();

  static const contentId = 'af_content_id';
  static const contentType = 'af_content_type';
  static const currency = 'af_currency';
  static const revenue = 'af_revenue';
  static const price = 'af_price';
  static const orderId = 'af_order_id';
  static const quantity = 'af_quantity';
  static const registrationMethod = 'af_registration_method';
}

/// Wraps the AppsFlyer SDK: attribution, install/session tracking, in-app
/// events and OneLink deep links.
///
/// Nothing here is on a critical path — every method swallows its errors and
/// no-ops when the SDK is unavailable (web, a build without an iOS App Store
/// id, a checkout without a dev key). Attribution must never break a flow.
///
/// Events reach this class through [AnalyticsService], which mirrors every
/// Firebase event here; screens don't call it directly.
@lazySingleton
class AppsFlyerService {
  AppsFlyerService(this._storage);

  final Storage _storage;

  AppsflyerSdk? _sdk;

  /// Where a resolved OneLink lands. Wired to `DeeplinkService` in `main.dart`
  /// rather than injected, because the deep-link service is registered by hand
  /// after `getIt.init()` and isn't visible to injectable.
  void Function(Uri uri, {required bool deferred})? onDeepLink;

  bool get isEnabled => _sdk != null;

  /// Builds and starts the SDK. Call once, before `runApp`.
  ///
  /// Returns normally on every platform — when AppsFlyer can't run, [isEnabled]
  /// stays false and the rest of the class turns into no-ops.
  Future<void> init() async {
    if (_sdk != null) return;

    // The plugin is iOS/Android only; the web build shares this DI graph.
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      _log('skipped — unsupported platform');
      return;
    }
    if (!AppsFlyerEnv.hasDevKey) {
      _log('skipped — no dev key (pass --dart-define=APPSFLYER_DEV_KEY=...)');
      return;
    }
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;
    // The SDK asserts on the App Store id shape and won't attribute an iOS
    // build without it. Better to run unattributed than to crash a debug build.
    if (isIos && !AppsFlyerEnv.hasValidIosAppId) {
      _log('skipped — set APPSFLYER_IOS_APP_ID to the numeric App Store id');
      return;
    }

    try {
      final sdk = AppsflyerSdk(AppsFlyerOptions(
        afDevKey: AppsFlyerEnv.devKey,
        appId: AppsFlyerEnv.iosAppId,
        showDebug: AppEnv.isDev,
        // iOS only. AppsFlyer holds the install postback for up to this many
        // seconds waiting for the ATT verdict, so the IDFA (if granted) rides
        // along on it instead of arriving too late to attribute the install.
        // [_requestTrackingAuthorization] is what actually resolves the wait.
        timeToWaitForATTUserAuthorization: isIos ? 60 : null,
        // The OneLink *template* id, not the domain — it only feeds
        // `generateInviteLink`. Unset until we actually generate invites.
        appInviteOneLink: AppsFlyerEnv.oneLinkTemplateId.isEmpty
            ? null
            : AppsFlyerEnv.oneLinkTemplateId,
      ));

      // Every callback must be registered before initSdk, or the first
      // launch — the one that carries the deferred deep link — misses it.
      sdk.onDeepLinking(_onDeepLinking);
      sdk.onInstallConversionData((res) => _log('conversion data: $res'));
      sdk.onAppOpenAttribution((res) => _log('open attribution: $res'));

      // Attribute the session to the logged-in user from the very first event
      // when we already know who they are (warm start after a previous login).
      final userId = _storage.userId();
      if (userId != null && userId.isNotEmpty) sdk.setCustomerUserId(userId);
      sdk.setCurrencyCode(AppsFlyerEnv.currency);

      await sdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );
      _sdk = sdk;
      _log('initialised (debug:${AppEnv.isDev})');

      if (isIos) _scheduleTrackingAuthorizationRequest();
    } catch (e) {
      _log('init failed (ignored): $e');
    }
  }

  /// Ties every subsequent event to our own user id, so AppsFlyer's raw-data
  /// exports can be joined against the backend. Call after login.
  void setCustomerUserId(String? id) {
    if (id == null || id.isEmpty) return;
    try {
      _sdk?.setCustomerUserId(id);
    } catch (e) {
      _log('setCustomerUserId failed (ignored): $e');
    }
  }

  /// Drops the identity on logout. AppsFlyer has no "unset", so the id is
  /// cleared to the empty string — the device keeps its own AppsFlyer UID and
  /// stays attributed, which is what we want.
  void clearCustomerUserId() {
    try {
      _sdk?.setCustomerUserId('');
    } catch (e) {
      _log('clearCustomerUserId failed (ignored): $e');
    }
  }

  /// Mirrors one of our [AnalyticsEvent]s into AppsFlyer, translated onto the
  /// standard catalogue where one fits. Fire-and-forget.
  Future<void> logAppEvent(String name, Map<String, Object> params) async {
    final sdk = _sdk;
    if (sdk == null) return;

    // AppsFlyer counts sessions itself; re-sending app_open would double-count
    // it against every session in the dashboard.
    if (name == AnalyticsEvent.appOpen) return;

    try {
      final afName = _standardEventNames[name] ?? name;
      final values = _afValues(afName, params);
      await sdk.logEvent(afName, values);
      _log('event:$afName values:$values');
    } catch (e) {
      _log('logAppEvent($name) failed (ignored): $e');
    }
  }

  // ─── Event translation ─────────────────────────────────────────────────────

  /// Our names → AppsFlyer's catalogue. Anything absent is sent unchanged as a
  /// custom event, which is fine: only the funnel below drives campaign
  /// optimisation.
  static const _standardEventNames = <String, String>{
    AnalyticsEvent.login: AfEvent.login,
    AnalyticsEvent.signUp: AfEvent.completeRegistration,
    AnalyticsEvent.registrationCompleted: AfEvent.completeRegistration,
    AnalyticsEvent.classDetailViewed: AfEvent.contentView,
    AnalyticsEvent.activityDetailViewed: AfEvent.contentView,
    AnalyticsEvent.branchDetailViewed: AfEvent.contentView,
    AnalyticsEvent.bookButtonTapped: AfEvent.addToCart,
    AnalyticsEvent.bookingCheckoutStarted: AfEvent.initiatedCheckout,
    AnalyticsEvent.planPurchaseStarted: AfEvent.initiatedCheckout,
    AnalyticsEvent.subscriptionPurchaseStarted: AfEvent.initiatedCheckout,
    AnalyticsEvent.checkoutPageOpened: AfEvent.initiatedCheckout,
    AnalyticsEvent.paymentSucceeded: AfEvent.purchase,
  };

  /// The id-carrying param each screen happens to send, in the order we'd
  /// rather use them, mapped to the content type they describe.
  static const _contentIdKeys = <String, String>{
    'class_id': 'class',
    'activity_id': 'activity',
    'plan_id': 'plan',
    'branch_id': 'branch',
  };

  /// Keeps our own params (they're useful in raw-data exports) and adds the
  /// standard `af_*` ones on top, derived from whatever the call site sent.
  Map<String, Object> _afValues(String afName, Map<String, Object> params) {
    final values = Map<String, Object>.of(params);

    for (final entry in _contentIdKeys.entries) {
      final id = params[entry.key];
      if (id == null || (id is String && id.isEmpty)) continue;
      values[AfParam.contentId] = id;
      values[AfParam.contentType] = entry.value;
      break;
    }

    final orderId = params['order_id'];
    if (orderId != null) values[AfParam.orderId] = orderId;

    final tickets = params['ticket_count'];
    if (tickets != null) values[AfParam.quantity] = tickets;

    final method = params['method'];
    if (method != null && afName == AfEvent.completeRegistration) {
      values[AfParam.registrationMethod] = method;
    }

    // `amount` is what the checkout flow sends; `price` is what the detail
    // pages send. Either way it's the sum in soʻm.
    final amount = params['amount'] ?? params['price'];
    if (amount is num) {
      values[AfParam.currency] =
          params['currency'] ?? AppsFlyerEnv.currency;
      // Revenue is only real once the order is paid — tagging an abandoned
      // checkout with af_revenue would inflate ROAS.
      values[afName == AfEvent.purchase ? AfParam.revenue : AfParam.price] =
          amount;
    }

    return values;
  }

  // ─── Deep links ────────────────────────────────────────────────────────────

  void _onDeepLinking(DeepLinkResult result) {
    _log('UDL ${result.status.toShortString()} ${result.deepLink}');
    if (result.status != Status.FOUND) return;

    final link = result.deepLink;
    if (link == null) return;

    final uri = _uriFromDeepLink(link);
    if (uri == null) {
      _log('UDL had no usable target: ${link.clickEvent}');
      return;
    }
    onDeepLink?.call(uri, deferred: link.isDeferred ?? false);
  }

  /// Turns a OneLink click event into a URI the app's own deep-link router
  /// understands.
  ///
  /// Handles the two shapes a OneLink can be configured with:
  ///   * `deep_link_value` holding a whole URI — `lumi://class/<id>` or the
  ///     `https://mobile-api.lumipass.uz/share/class/<id>` share link;
  ///   * `deep_link_value: class` plus the id in `deep_link_sub1` / `class_id`,
  ///     which is how the OneLink UI nudges you to model it.
  Uri? _uriFromDeepLink(DeepLink link) {
    final value = link.deepLinkValue ?? link.getStringValue('af_dp');

    if (value != null && value.contains('://')) return Uri.tryParse(value);

    if (value == 'class' || value == 'activity') {
      final id = link.getStringValue('deep_link_sub1') ??
          link.getStringValue('class_id') ??
          link.afSub1;
      if (id != null && id.isNotEmpty) return Uri.parse('lumi://class/$id');
    }

    // Last resort: the raw link that was clicked. Carries the /share/class/
    // path when the OneLink simply wraps our own share URL.
    final raw = link.getStringValue('link');
    return raw == null ? null : Uri.tryParse(raw);
  }

  // ─── App Tracking Transparency (iOS) ───────────────────────────────────────

  /// Asks for IDFA access once the first frame is up.
  ///
  /// iOS silently drops the ATT prompt while the app is still launching, so
  /// this waits for a frame plus a beat rather than firing from [init].
  void _scheduleTrackingAuthorizationRequest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(
        const Duration(milliseconds: 500),
        _requestTrackingAuthorization,
      );
    });
  }

  Future<void> _requestTrackingAuthorization() async {
    try {
      final current = await AppTrackingTransparency.trackingAuthorizationStatus;
      // Anything other than notDetermined means the user already answered (or
      // the OS won't ask); re-requesting is a no-op but not worth the trip.
      if (current != TrackingStatus.notDetermined) {
        _log('ATT already resolved: $current');
        return;
      }
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      _log('ATT: $status');
    } catch (e) {
      _log('ATT request failed (ignored): $e');
    }
  }
}

import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/service/appsflyer_service.dart';
import 'package:lumi_pass/data/service/meta_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';

// [AnalyticsEvent] used to live here; it moved so the AppsFlyer service can
// read it without an import cycle. Re-exported so every existing
// `import '.../analytics_service.dart'` still sees it.
export 'package:lumi_pass/data/service/analytics_event.dart';

// ignore: avoid_print
void _log(String msg) => print('[Analytics] $msg');

/// Thin wrapper around [FirebaseAnalytics] that stamps **every** event with the
/// logged-in user's `user_id` and `phone_number`, as requested. Read the values
/// from [Storage] on each call so events fired right after login (before the
/// service is re-identified) still carry the freshest identity.
///
/// Every event is also mirrored into AppsFlyer and Meta App Events through
/// [AppsFlyerService] and [MetaService], so screens keep a single analytics
/// entry point and attribution stays in step with the product funnel
/// automatically.
///
/// All methods are best-effort and never throw — analytics must never break a
/// user flow.
@lazySingleton
class AnalyticsService {
  AnalyticsService(this._storage, this._appsFlyer, this._meta);

  final Storage _storage;
  final AppsFlyerService _appsFlyer;
  final MetaService _meta;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Sets the Firebase user id and a `phone_number` user property so funnels
  /// and audiences can be built on identity. Call after login/registration.
  Future<void> identify() async {
    try {
      final userId = _storage.userId();
      final phone = _currentPhone();
      // Before Firebase, for the same reason logEvent fires AppsFlyer first:
      // a Firebase throw must not leave AppsFlyer/Meta un-identified.
      _appsFlyer.setCustomerUserId(userId);
      unawaited(_meta.setUserData(phone: phone));
      await _analytics.setUserId(id: userId);
      if (phone != null && phone.isNotEmpty) {
        await _analytics.setUserProperty(name: 'phone_number', value: phone);
      }
      _log('identified user_id:$userId phone:$phone');
    } catch (e) {
      _log('identify failed (ignored): $e');
    }
  }

  /// Clears identity on logout so subsequent events aren't attributed to the
  /// previous user.
  Future<void> clear() async {
    try {
      _appsFlyer.clearCustomerUserId();
      unawaited(_meta.clearUserData());
      await _analytics.setUserId(id: null);
      await _analytics.setUserProperty(name: 'phone_number', value: null);
    } catch (e) {
      _log('clear failed (ignored): $e');
    }
  }

  /// Logs [name] with [params], automatically merging the current `user_id`
  /// and `phone_number`. Null/empty params are dropped and values are coerced
  /// to the String/num types Firebase requires.
  Future<void> logEvent(String name, {Map<String, Object?>? params}) async {
    try {
      final merged = <String, Object>{};

      final userId = _storage.userId();
      if (userId != null && userId.isNotEmpty) merged['user_id'] = userId;
      final phone = _currentPhone();
      if (phone != null && phone.isNotEmpty) merged['phone_number'] = phone;

      if (params != null) {
        params.forEach((key, value) {
          if (value == null) return;
          merged[key] = value is num ? value : value.toString();
        });
      }

      // First, and unawaited: they guard themselves, and a Firebase throw
      // further down must not cost us the AppsFlyer/Meta copy of the event.
      unawaited(_appsFlyer.logAppEvent(name, merged));
      unawaited(_meta.logAppEvent(name, merged));

      await _analytics.logEvent(
        name: name,
        parameters: merged.isEmpty ? null : merged,
      );
      _log('event:$name params:$merged');
    } catch (e) {
      _log('logEvent($name) failed (ignored): $e');
    }
  }

  /// Phone is stored persistently in [Storage.userPhone]; fall back to the
  /// transient onboarding [Storage.pendingPhone] when the persistent value
  /// hasn't been written yet (e.g. brand-new signups mid-flow).
  String? _currentPhone() {
    final phone = _storage.userPhone();
    if (phone != null && phone.isNotEmpty) return phone;
    return _storage.pendingPhone();
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/storage/storage.dart';

// ignore: avoid_print
void _log(String msg) => print('[Analytics] $msg');

/// Canonical analytics event names. Keep these stable — renaming an event
/// breaks historical reporting in the Firebase console.
class AnalyticsEvent {
  const AnalyticsEvent._();

  static const appOpen = 'app_open';
  static const classDetailViewed = 'class_detail_viewed';
  static const activityDetailViewed = 'activity_detail_viewed';
  static const branchDetailViewed = 'branch_detail_viewed';
  static const otpRequested = 'otp_requested';
  static const otpResent = 'otp_resent';
  static const login = 'login';
  static const signUp = 'sign_up';
  static const registrationCompleted = 'registration_completed';
  static const logout = 'logout';
  // ─── Purchase / booking funnel ──────────────────────────────────────────
  // Ordered funnel: book_button_tapped → booking_checkout_started →
  // checkout_page_opened → payme_redirect → payment_succeeded.
  // Failure branches: booking_checkout_failed, payme_open_failed.
  static const bookButtonTapped = 'book_button_tapped';
  static const bookingCheckoutStarted = 'booking_checkout_started';
  static const bookingCheckoutFailed = 'booking_checkout_failed';
  static const bookingRequested = 'booking_requested';
  static const planPurchaseStarted = 'plan_purchase_started';
  static const subscriptionPurchaseStarted = 'subscription_purchase_started';
  static const checkoutPageOpened = 'checkout_page_opened';
  static const paymeRedirect = 'payme_redirect';
  static const paymeOpenFailed = 'payme_open_failed';
  static const paymentSucceeded = 'payment_succeeded';
  static const paymentAbandoned = 'payment_abandoned';
}

/// Thin wrapper around [FirebaseAnalytics] that stamps **every** event with the
/// logged-in user's `user_id` and `phone_number`, as requested. Read the values
/// from [Storage] on each call so events fired right after login (before the
/// service is re-identified) still carry the freshest identity.
///
/// All methods are best-effort and never throw — analytics must never break a
/// user flow.
@lazySingleton
class AnalyticsService {
  AnalyticsService(this._storage);

  final Storage _storage;
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Sets the Firebase user id and a `phone_number` user property so funnels
  /// and audiences can be built on identity. Call after login/registration.
  Future<void> identify() async {
    try {
      final userId = _storage.userId();
      final phone = _currentPhone();
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

/// Canonical analytics event names. Keep these stable — renaming an event
/// breaks historical reporting in the Firebase console.
///
/// Lives in its own file so [AppsFlyerService] can map these onto AppsFlyer's
/// standard `af_*` catalogue without importing `analytics_service.dart` (which
/// imports the AppsFlyer service right back). `analytics_service.dart`
/// re-exports it, so existing `import '.../analytics_service.dart'` call sites
/// keep working.
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

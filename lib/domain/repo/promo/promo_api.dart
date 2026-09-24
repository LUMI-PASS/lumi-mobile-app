import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw calls to the "аксия" (promo bundle) endpoints.
///
/// The payment half of [purchase] is deliberately shaped like
/// `OrdersApi.checkoutSubscription`'s: the same provider keys, the same
/// saved-card and card fields, the same response. That is what lets the app's
/// existing payment chooser, card OTP sheet and redirect handling drive a
/// bundle purchase with no second implementation of any of them.
@injectable
class PromoApi {
  final Dio _dio;

  PromoApi(this._dio);

  /// The bundles on sale. No auth required — an offer is a reason to sign up.
  /// Sent with a token, each campaign also carries the passes the caller holds.
  Future<Response> getCampaigns() => _dio.get('promo-campaigns');

  /// One bundle, by id or slug. Deep links carry the slug.
  Future<Response> getCampaign(String idOrSlug) =>
      _dio.get('promo-campaigns/$idOrSlug');

  /// Creates the order and routes it to a payment rail.
  ///
  /// [savedCardId] replaces [paymentProvider] rather than accompanying it: the
  /// server answers with the PENDING order and no gateway call, to be charged
  /// through `OrdersApi.payOrderWithSavedCard`. Exactly as the subscription and
  /// booking checkouts behave.
  Future<Response> purchase(
    String idOrSlug, {
    String? lang,
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  }) {
    final saved = savedCardId?.trim();
    final hasSaved = saved != null && saved.isNotEmpty;
    return _dio.post('promo-campaigns/$idOrSlug/purchase', data: {
      if (hasSaved) 'saved_card_id': saved,
      if (paymentProvider != null && !hasSaved)
        'payment_provider': paymentProvider,
      if (returnUrl != null) 'return_url': returnUrl,
      if (cardNumber != null && cardNumber.trim().isNotEmpty)
        'card_number': cardNumber.replaceAll(RegExp(r'\s'), ''),
      if (expireDate != null && expireDate.trim().isNotEmpty)
        'expire_date': expireDate.replaceAll(RegExp(r'[^0-9]'), ''),
      if (lang != null) 'lang': lang,
      if (test) 'test': true,
    });
  }

  /// Every pass this user has bought, live ones first.
  Future<Response> getPasses() => _dio.get('promo-passes');

  Future<Response> getPass(String id) => _dio.get('promo-passes/$id');

  /// Can a pass pay for this booking? A preview — it reserves nothing.
  ///
  /// [ticketDate] is omitted while the buyer has not picked a date yet, which
  /// tells the server to skip the deadline test for now; it is re-tested at
  /// checkout, when there is a date to test.
  Future<Response> eligibility({
    required String activityId,
    String? ticketDate,
    num? subtotal,
  }) {
    return _dio.get('promo-passes/eligibility', queryParameters: {
      'activity_id': activityId,
      if (ticketDate != null && ticketDate.isNotEmpty) 'ticket_date': ticketDate,
      if (subtotal != null) 'subtotal': subtotal.round(),
    });
  }
}

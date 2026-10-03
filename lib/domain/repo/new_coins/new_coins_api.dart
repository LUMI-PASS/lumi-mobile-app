import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw calls to the "new coins" endpoints — packs of coins bought with money
/// and spent on activity bookings.
///
/// Not the cashback wallet (`WalletApi`): a separate balance in a separate
/// unit. Spending happens on the ordinary booking checkout
/// (`OrdersApi.checkout` with `payWith`), not here.
///
/// The payment half of both purchases is deliberately `PromoApi.purchase`'s:
/// the same provider keys, the same saved-card and card fields, the same
/// response — which is what lets the existing payment chooser, card OTP sheet
/// and redirect handling drive it with no second implementation of any of them.
@injectable
class NewCoinsApi {
  final Dio _dio;

  NewCoinsApi(this._dio);

  /// The packs on sale, the loose-coin price and the rate. No auth required;
  /// sent with a token it also says whether this user may buy extras.
  Future<Response> getPacks() => _dio.get('new-coins/packs');

  /// Coins held, lot by lot, with their deadlines.
  Future<Response> getBalance() => _dio.get('new-coins/balance');

  Future<Response> getTransactions({int page = 1, int limit = 20}) =>
      _dio.get('new-coins/transactions', queryParameters: {
        'page': page,
        'limit': limit,
      });

  Map<String, dynamic> _paymentBody({
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
    return {
      if (hasSaved) 'saved_card_id': saved,
      // [savedCardId] replaces [paymentProvider] rather than accompanying it:
      // the server answers with the PENDING order and no gateway call, to be
      // charged through `OrdersApi.payOrderWithSavedCard`.
      if (paymentProvider != null && !hasSaved)
        'payment_provider': paymentProvider,
      if (returnUrl != null) 'return_url': returnUrl,
      if (cardNumber != null && cardNumber.trim().isNotEmpty)
        'card_number': cardNumber.replaceAll(RegExp(r'\s'), ''),
      if (expireDate != null && expireDate.trim().isNotEmpty)
        'expire_date': expireDate.replaceAll(RegExp(r'[^0-9]'), ''),
      if (lang != null) 'lang': lang,
      if (test) 'test': true,
    };
  }

  /// Creates the order for a pack and routes it to a payment rail. The coins
  /// appear only once the payment confirms.
  Future<Response> purchasePack(
    String packId, {
    String? lang,
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  }) {
    return _dio.post(
      'new-coins/packs/$packId/purchase',
      data: _paymentBody(
        lang: lang,
        paymentProvider: paymentProvider,
        returnUrl: returnUrl,
        cardNumber: cardNumber,
        expireDate: expireDate,
        savedCardId: savedCardId,
        test: test,
      ),
    );
  }

  /// Loose coins at the unit price — for the one or two a booking is short.
  Future<Response> purchaseSingle({
    required int quantity,
    String? lang,
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  }) {
    return _dio.post('new-coins/single/purchase', data: {
      'quantity': quantity,
      ..._paymentBody(
        lang: lang,
        paymentProvider: paymentProvider,
        returnUrl: returnUrl,
        cardNumber: cardNumber,
        expireDate: expireDate,
        savedCardId: savedCardId,
        test: test,
      ),
    });
  }
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Raw calls to the Lumi Shop endpoints.
///
/// The payment half of [checkout] is deliberately shaped like `OrdersApi`'s:
/// the same provider keys, the same saved-card and OTP fields, the same
/// response. That is what lets the app's existing payment sheet, card OTP
/// sheet and checkout webview drive a merch purchase with no second
/// implementation of any of them.
@injectable
class ShopApi {
  final Dio _dio;

  ShopApi(this._dio);

  /// The catalog. No auth required — a merch grid is a reason to sign up.
  Future<Response> getProducts({int page = 1, int limit = 20}) {
    return _dio.get('shop/products', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  Future<Response> getProduct(String id) => _dio.get('shop/products/$id');

  /// Creates the order and routes it to a payment rail.
  ///
  /// [payWith] decides which of the product's two prices is charged, and an
  /// order is paid entirely one way. `'coins'` charges the coin prices to the
  /// wallet and comes back already `paid`, with no `checkout_url` and no
  /// gateway opened at all; `'money'` charges the so'm prices to a rail. There
  /// is no rate between the two, so there is no part-coin order to ask for.
  Future<Response> checkout({
    required List<({String productId, int count})> items,
    required double lat,
    required double lng,
    required String address,
    String? contactName,
    String? contactPhone,
    String? comment,
    String payWith = 'money',
    String? paymentProvider,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    String? lang,
  }) {
    return _dio.post('shop/checkout', data: {
      'items': items
          .map((it) => {'product_id': it.productId, 'count': it.count})
          .toList(),
      'delivery': {
        'lat': lat,
        'lng': lng,
        'address': address,
        if (contactName != null && contactName.isNotEmpty)
          'contact_name': contactName,
        if (contactPhone != null && contactPhone.isNotEmpty)
          'contact_phone': contactPhone,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
      'pay_with': payWith,
      if (paymentProvider != null) 'payment_provider': paymentProvider,
      if (cardNumber != null) 'card_number': cardNumber,
      if (expireDate != null) 'expire_date': expireDate,
      if (savedCardId != null) 'saved_card_id': savedCardId,
      if (lang != null) 'lang': lang,
    });
  }

  Future<Response> getOrders({int page = 1, int limit = 20}) {
    return _dio.get('shop/orders', queryParameters: {
      'page': page,
      'limit': limit,
    });
  }

  Future<Response> getOrder(String id) => _dio.get('shop/orders/$id');

  Future<Response> cancelOrder(String id, {String? reason}) {
    return _dio.patch('shop/orders/$id/cancel', data: {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
  }
}

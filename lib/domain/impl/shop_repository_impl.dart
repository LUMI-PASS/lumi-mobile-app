import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/shop/shop_order.dart';
import 'package:lumi_pass/data/api_model/shop/shop_product.dart';
import 'package:lumi_pass/domain/repo/shop/shop_api.dart';
import 'package:lumi_pass/domain/repo/shop/shop_repository.dart';

@Injectable(as: ShopRepository)
class ShopRepositoryImpl extends ShopRepository {
  final ShopApi _api;

  ShopRepositoryImpl(this._api);

  /// The `data:` envelope is not applied consistently across this backend —
  /// some endpoints wrap, some don't. Unwrap defensively rather than assuming,
  /// the same way `wallet_repository_impl.dart` does.
  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is Map && raw['data'] is Map) {
      return Map<String, dynamic>.from(raw['data'] as Map);
    }
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  /// A list endpoint puts its pagination at the root and the rows under `data`.
  ShopPage<T> _page<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) parse,
    int requestedPage,
  ) {
    final List list;
    if (raw is Map && raw['data'] is List) {
      list = raw['data'] as List;
    } else if (raw is List) {
      list = raw;
    } else {
      list = const [];
    }

    int readInt(String key, int fallback) {
      final v = raw is Map ? raw[key] : null;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? fallback;
    }

    return ShopPage<T>(
      items: list
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList(),
      page: readInt('page', requestedPage),
      totalPages: readInt('pages', 1),
      total: readInt('total', 0),
    );
  }

  @override
  Future<ShopPage<ShopProduct>> getProducts({int page = 1, int limit = 20}) {
    return _api
        .getProducts(page: page, limit: limit)
        .then((res) => _page(res.data, ShopProduct.fromJson, page));
  }

  @override
  Future<ShopProduct> getProduct(String id) {
    return _api
        .getProduct(id)
        .then((res) => ShopProduct.fromJson(_unwrap(res.data)));
  }

  @override
  Future<CheckoutResult> checkout({
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
    return _api
        .checkout(
          items: items,
          lat: lat,
          lng: lng,
          address: address,
          contactName: contactName,
          contactPhone: contactPhone,
          comment: comment,
          payWith: payWith,
          paymentProvider: paymentProvider,
          cardNumber: cardNumber,
          expireDate: expireDate,
          savedCardId: savedCardId,
          lang: lang,
        )
        .then((res) => CheckoutResult.fromJson(_unwrap(res.data)));
  }

  @override
  Future<ShopPage<ShopOrder>> getOrders({int page = 1, int limit = 20}) {
    return _api
        .getOrders(page: page, limit: limit)
        .then((res) => _page(res.data, ShopOrder.fromJson, page));
  }

  @override
  Future<ShopOrder> getOrder(String id) {
    return _api
        .getOrder(id)
        .then((res) => ShopOrder.fromJson(_unwrap(res.data)));
  }

  @override
  Future<void> cancelOrder(String id, {String? reason}) {
    return _api.cancelOrder(id, reason: reason).then((_) {});
  }
}

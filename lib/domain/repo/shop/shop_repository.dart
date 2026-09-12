import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/shop/shop_order.dart';
import 'package:lumi_pass/data/api_model/shop/shop_product.dart';

/// One page of a paginated shop list.
class ShopPage<T> {
  final List<T> items;
  final int page;
  final int totalPages;
  final int total;

  const ShopPage({
    required this.items,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
  });

  bool get hasMore => page < totalPages;

  static ShopPage<T> empty<T>() => ShopPage<T>(items: const []);
}

abstract class ShopRepository {
  Future<ShopPage<ShopProduct>> getProducts({int page = 1, int limit = 20});

  Future<ShopProduct> getProduct(String id);

  /// Buys merch.
  ///
  /// Returns the same [CheckoutResult] a booking does — deliberately, because
  /// the payment tail is the same code: a redirect URL for Payme/Click/Uzum, a
  /// transaction to confirm for a card, and neither of those when coins
  /// covered the whole thing (`status: paid`).
  Future<CheckoutResult> checkout({
    required List<({String productId, int count})> items,
    required double lat,
    required double lng,
    required String address,
    String? contactName,
    String? contactPhone,
    String? comment,
    bool useWallet = false,
    num? walletAmount,
    String? paymentProvider,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    String? lang,
  });

  Future<ShopPage<ShopOrder>> getOrders({int page = 1, int limit = 20});

  Future<ShopOrder> getOrder(String id);

  Future<void> cancelOrder(String id, {String? reason});
}

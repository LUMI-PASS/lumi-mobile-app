import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/shop/shop_cart.dart';
import 'package:lumi_pass/data/api_model/shop/shop_product.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/shop/shop_repository.dart';

/// The basket.
///
/// A plain `Cubit<ShopCart>` rather than a `BaseCubit`: there is one piece of
/// state here and no loading or error to model — a basket either has things in
/// it or it does not.
///
/// **Registered as a singleton.** Every screen that shows the badge, the
/// product grid, the basket tab and the checkout must all be looking at the
/// same basket; a factory would give each of them a private copy and the
/// badge would never move.
@lazySingleton
class CartCubit extends Cubit<ShopCart> {
  CartCubit(this._storage, this._shop) : super(ShopCart.empty) {
    _restore();
  }

  final Storage _storage;
  final ShopRepository _shop;

  /// Rebuilds the basket from storage, re-fetching each product.
  ///
  /// Only the ids were persisted, deliberately: a cached product goes stale —
  /// wrong price, wrong stock, sometimes deleted outright — and a basket that
  /// quietly prices yesterday's cup is worse than one that took a second to
  /// load. Anything that no longer resolves is dropped rather than shown as a
  /// line the checkout would refuse.
  Future<void> _restore() async {
    final raw = _storage.shopCart.call();
    if (raw == null || raw.isEmpty) return;

    final wanted = <String, int>{};
    for (final entry in raw) {
      if (entry is! Map) continue;
      final id = entry['product_id']?.toString();
      final count = int.tryParse('${entry['count']}') ?? 0;
      if (id != null && id.isNotEmpty && count > 0) wanted[id] = count;
    }
    if (wanted.isEmpty) return;

    var cart = ShopCart.empty;
    for (final entry in wanted.entries) {
      try {
        final product = await _shop.getProduct(entry.key);
        // add(), not setCount(): it clamps to what may actually be bought
        // today. A basket stored when three were on the shelf must not come
        // back asking for three when one is left — setCount would have
        // restored it verbatim and the checkout would have refused the whole
        // order. A line whose product is now unbuyable drops out here.
        cart = cart.add(product, count: entry.value);
      } catch (_) {
        // Gone, hidden, or unreachable. Skip the line rather than fail the
        // whole basket over one of them.
      }
    }

    if (!isClosed) {
      emit(cart);
      _persist(cart);
    }
  }

  void add(ShopProduct product, {int count = 1}) =>
      _update(state.add(product, count: count));

  void setCount(ShopProduct product, int count) =>
      _update(state.setCount(product, count));

  void remove(String productId) => _update(state.remove(productId));

  /// Emptied after a successful purchase — the basket has become an order.
  void clear() => _update(ShopCart.empty);

  void _update(ShopCart next) {
    emit(next);
    _persist(next);
  }

  void _persist(ShopCart cart) {
    _storage.shopCart.set(cart.lines.map((line) => line.toJson()).toList());
  }
}

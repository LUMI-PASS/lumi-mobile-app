import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/shop/shop_repository.dart';
import 'package:lumi_pass/domain/repo/wallet/wallet_repository.dart';

import 'shop_state.dart';

/// The shop grid, plus the coin balance shown above it.
///
/// The balance is loaded here rather than on the checkout screen because it is
/// the reason this screen exists: "you have N coins" is what turns a merch
/// grid into something a buyer acts on. It is best-effort — a shop that cannot
/// show a balance is still a shop, so a failed wallet read leaves the header
/// off instead of failing the page.
@injectable
class ShopCubit extends BaseCubit<ShopBuildable, ShopListenable> {
  ShopCubit(this._shop, this._wallet) : super(const ShopBuildable());

  final ShopRepository _shop;
  final WalletRepository _wallet;

  static const _pageSize = 20;

  bool get _isSignedIn => getIt<Storage>().tokens.call()?.access != null;

  Future<void> load() async {
    build((s) => s.copyWith(isLoading: true, hasError: false));
    try {
      final products = await _shop.getProducts(page: 1, limit: _pageSize);

      build((s) => s.copyWith(
            products: products.items,
            page: products.page,
            totalPages: products.totalPages,
            isLoading: false,
          ));
    } catch (_) {
      build((s) => s.copyWith(isLoading: false, hasError: true));
      return;
    }

    // Both need a signed-in user, and neither is worth failing the grid over.
    // Fetched after the products rather than alongside them so the shop paints
    // as soon as it can.
    if (!_isSignedIn) return;
    await _loadBuyerContext();
  }

  /// The balance and the buyer's own orders.
  ///
  /// Two independent reads, each swallowing its own failure: a wallet outage
  /// must not also hide the "my orders" row, and neither may take the grid
  /// down with it.
  Future<void> _loadBuyerContext() async {
    final wallet =
        await _wallet.getWallet().catchError((_) => WalletBalance.empty);
    build((s) => s.copyWith(wallet: wallet));

    try {
      final orders = await _shop.getOrders(page: 1, limit: 20);
      build((s) => s.copyWith(orders: orders.items));
    } catch (_) {
      // Leave whatever was already there.
    }
  }

  Future<void> refresh() => load();

  /// Append the next page. Guarded against double-firing, which a scroll
  /// listener will otherwise do on every frame near the bottom.
  Future<void> loadMore() async {
    final state = buildable;
    if (state.isLoadingMore || !state.hasMore) return;

    build((s) => s.copyWith(isLoadingMore: true));
    try {
      final next = await _shop.getProducts(
        page: state.page + 1,
        limit: _pageSize,
      );
      build((s) => s.copyWith(
            products: [...s.products, ...next.items],
            page: next.page,
            totalPages: next.totalPages,
            isLoadingMore: false,
          ));
    } catch (_) {
      build((s) => s.copyWith(isLoadingMore: false));
    }
  }
}

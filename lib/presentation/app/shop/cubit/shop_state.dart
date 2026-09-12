import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/shop/shop_order.dart';
import 'package:lumi_pass/data/api_model/shop/shop_product.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';

part 'shop_state.freezed.dart';

@freezed
class ShopBuildable with _$ShopBuildable {
  const factory ShopBuildable({
    /// First paint only. Paging in more products must not blank the grid,
    /// which is why appending has its own flag.
    @Default(true) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasError,
    @Default([]) List<ShopProduct> products,
    @Default(1) int page,
    @Default(1) int totalPages,

    /// What the buyer can spend. Null for a guest, and for anybody whose
    /// balance has not landed yet — the header renders nothing rather than a
    /// zero, because "0 coins" and "we don't know yet" are different claims.
    WalletBalance? wallet,

    /// The buyer's own purchases, for the "my orders" entry point. Only the
    /// count is used on this screen; the list screen loads its own.
    @Default([]) List<ShopOrder> orders,
  }) = _ShopBuildable;

  const ShopBuildable._();

  bool get hasMore => page < totalPages;

  bool get isEmpty => !isLoading && products.isEmpty;

  /// Orders still on their way — the number on the "my orders" row.
  int get activeOrderCount => orders.where((o) => !o.status.isFinished).length;
}

@freezed
class ShopListenable with _$ShopListenable {
  const factory ShopListenable({
    required ShopEffect effect,
    String? message,
  }) = _ShopListenable;
}

enum ShopEffect { none, error }

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_product.freezed.dart';
part 'shop_product.g.dart';

/// One piece of Lumi merch, from `GET /api/shop/products`.
///
/// [price] is in so'm AND is the coin price: one Lumi coin is one so'm (see
/// `coin_amount.dart`), so nothing here converts between them and a product
/// never carries two prices. Paying with coins is a payment method, not a
/// second price list.
@freezed
class ShopProduct with _$ShopProduct {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ShopProduct({
    @Default('') String id,
    @Default({}) Map<String, dynamic> name,
    @Default(null) Map<String, dynamic>? description,
    @Default([]) List<String> images,
    @Default(0) num price,
    num? oldPrice,
    @Default('UZS') String currency,

    /// What can actually be put in a basket right now — stock minus whatever
    /// unpaid checkouts are holding. The raw stock figure is deliberately not
    /// sent to the app: it would promise units that are already spoken for.
    @Default(0) int available,
    @Default(false) bool inStock,
    @Default(5) int maxPerOrder,
    @Default(0) int soldCount,
    @Default([]) List<String> tags,
  }) = _ShopProduct;

  const ShopProduct._();

  factory ShopProduct.fromJson(Map<String, dynamic> json) =>
      _$ShopProductFromJson(json);

  /// The cover image, or an empty string when a product has none.
  String get image => images.isNotEmpty ? images.first : '';

  /// Struck-through only when it is genuinely higher — a stale `old_price`
  /// below the current one would read as a price rise.
  bool get hasDiscount => (oldPrice ?? 0) > price;
}

import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_product.freezed.dart';
part 'shop_product.g.dart';

/// One piece of Lumi merch, from `GET /api/shop/products`.
///
/// Carries TWO independent prices, and merch is the one place in Lumi where a
/// coin is not a so'm. Everywhere else — bookings, cashback, refunds — one
/// coin is one so'm and `coin_amount.dart` says so. Here, [price] is what it
/// costs in money and [coinPrice] is what it costs in coins, with no
/// arithmetic between them: a cup may be 50 000 so'm or 30 000 coins because
/// somebody priced it that way, not because of a rate.
///
/// The consequence the UI has to respect: an order is paid entirely one way or
/// entirely the other. With no rate there is no way to price a part-coin
/// basket, and the server refuses to try.
@freezed
class ShopProduct with _$ShopProduct {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ShopProduct({
    @Default('') String id,
    @Default({}) Map<String, dynamic> name,
    @Default(null) Map<String, dynamic>? description,
    @Default([]) List<String> images,
    @Default(0) num price,

    /// What it costs in coins. NOT derived from [price] — see the class
    /// comment. Products created before the split were backfilled to their
    /// so'm price on the server, so this is never absent in practice.
    @Default(0) num coinPrice,

    /// The struck-through "was" price, in so'm. There is no coin equivalent:
    /// a discount is a money story.
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

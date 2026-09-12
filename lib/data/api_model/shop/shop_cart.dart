import 'package:lumi_pass/data/api_model/shop/shop_product.dart';

/// One line of the basket: a product, and how many of it.
///
/// Carries the whole [ShopProduct] rather than an id, so the basket screen can
/// draw itself without refetching the catalog. The price shown there is
/// therefore the price as of when it was added — the server re-prices at
/// checkout and its answer is what the buyer pays, which is why nothing here
/// is ever used to compute what is charged.
class ShopCartLine {
  const ShopCartLine({required this.product, required this.count});

  final ShopProduct product;
  final int count;

  num get lineTotal => product.price * count;

  /// What this line would have cost at the pre-discount price. Equal to
  /// [lineTotal] when the product is not discounted, so the summary can
  /// subtract the two without asking whether there is a discount at all.
  num get lineSubtotal => (product.oldPrice ?? product.price) * count;

  ShopCartLine copyWith({int? count}) =>
      ShopCartLine(product: product, count: count ?? this.count);

  /// Only the id and the count are persisted. A cached product would go stale
  /// — wrong price, wrong stock, possibly deleted — and the basket reloads
  /// them from the catalog on the way back in.
  Map<String, dynamic> toJson() => {
        'product_id': product.id,
        'count': count,
      };
}

/// The basket.
///
/// Immutable: every mutation returns a new cart, so a cubit can emit it and
/// Flutter can tell that something changed. Lines are keyed by product id —
/// adding a product already in the basket raises its count rather than
/// appending a second line, which is what makes the per-order ceiling
/// meaningful on this side too.
class ShopCart {
  const ShopCart({this.lines = const []});

  final List<ShopCartLine> lines;

  static const empty = ShopCart();

  bool get isEmpty => lines.isEmpty;

  /// The badge on the basket tab: units, not lines. Two cups and a pen is 3.
  int get count => lines.fold(0, (sum, line) => sum + line.count);

  num get total => lines.fold<num>(0, (sum, line) => sum + line.lineTotal);

  /// The basket before its discounts — the "N tovar" line of the summary.
  num get subtotal =>
      lines.fold<num>(0, (sum, line) => sum + line.lineSubtotal);

  /// What the old prices claim the buyer is saving. Shown as a line of its own
  /// because a total that is simply lower than the sum of its parts reads like
  /// an arithmetic error.
  num get discount => subtotal - total;

  bool get hasDiscount => discount > 0;

  int countOf(String productId) =>
      lines
          .where((line) => line.product.id == productId)
          .fold(0, (sum, line) => sum + line.count);

  bool contains(String productId) => countOf(productId) > 0;

  /// Adds [count] of [product], clamped to what may actually be bought.
  ///
  /// The ceiling is the lower of the per-order limit and what is left on the
  /// shelf: offering a basket the checkout would refuse is worse than refusing
  /// it here, where the buyer can still see why.
  ShopCart add(ShopProduct product, {int count = 1}) {
    final ceiling = product.maxPerOrder < product.available
        ? product.maxPerOrder
        : product.available;
    if (ceiling <= 0) return this;

    final existing = countOf(product.id);
    final next = (existing + count).clamp(1, ceiling);
    return setCount(product, next);
  }

  /// Sets an exact count. Zero or less removes the line.
  ShopCart setCount(ShopProduct product, int count) {
    if (count <= 0) return remove(product.id);

    final updated = <ShopCartLine>[];
    var found = false;
    for (final line in lines) {
      if (line.product.id == product.id) {
        found = true;
        // The product is replaced as well as the count: a basket reloaded from
        // storage carries a freshly fetched product, and this is where the new
        // price and stock take effect.
        updated.add(ShopCartLine(product: product, count: count));
      } else {
        updated.add(line);
      }
    }
    if (!found) updated.add(ShopCartLine(product: product, count: count));

    return ShopCart(lines: updated);
  }

  ShopCart remove(String productId) => ShopCart(
        lines: lines.where((line) => line.product.id != productId).toList(),
      );

  ShopCart clear() => empty;

  /// What `POST /api/shop/checkout` takes.
  List<({String productId, int count})> toCheckoutItems() => lines
      .map((line) => (productId: line.product.id, count: line.count))
      .toList();
}

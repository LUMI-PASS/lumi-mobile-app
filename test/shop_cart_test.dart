import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/shop/shop_cart.dart';
import 'package:lumi_pass/data/api_model/shop/shop_product.dart';

/// The basket's arithmetic.
///
/// What is really being defended: a basket can never hold more of something
/// than the shop can deliver. The checkout refuses an over-large line with a
/// 400, so a basket that lets one be built is a basket that leads the buyer to
/// a dead end they cannot see the cause of.
ShopProduct product({
  String id = 'p1',
  num price = 10000,
  int available = 10,
  int maxPerOrder = 3,
}) =>
    ShopProduct(
      id: id,
      name: const {'en': 'Cup'},
      price: price,
      available: available,
      inStock: available > 0,
      maxPerOrder: maxPerOrder,
    );

void main() {
  group('adding', () {
    test('a new product becomes a line of one', () {
      final cart = ShopCart.empty.add(product());

      expect(cart.lines, hasLength(1));
      expect(cart.count, 1);
      expect(cart.total, 10000);
    });

    test('adding the same product again raises the count, not the line count', () {
      // Two lines of the same product would each pass the per-order ceiling
      // and together break it — the server folds them for exactly this reason.
      final cart = ShopCart.empty.add(product()).add(product());

      expect(cart.lines, hasLength(1));
      expect(cart.count, 2);
    });

    test('never exceeds the per-order limit', () {
      var cart = ShopCart.empty;
      for (var i = 0; i < 10; i++) {
        cart = cart.add(product(maxPerOrder: 3));
      }

      expect(cart.count, 3);
    });

    test('never exceeds what is left on the shelf', () {
      // Two left, a limit of five: two is the answer.
      var cart = ShopCart.empty;
      for (var i = 0; i < 5; i++) {
        cart = cart.add(product(available: 2, maxPerOrder: 5));
      }

      expect(cart.count, 2);
    });

    test('a sold-out product cannot be added at all', () {
      final cart = ShopCart.empty.add(product(available: 0));

      expect(cart.isEmpty, isTrue);
    });
  });

  group('changing a line', () {
    test('setting a count to zero removes the line', () {
      final item = product();
      final cart = ShopCart.empty.add(item).setCount(item, 0);

      expect(cart.isEmpty, isTrue);
    });

    test('setting a count replaces the product as well as the number', () {
      // A basket restored from storage carries a freshly fetched product, and
      // this is where a new price takes effect — otherwise the basket would
      // quietly price yesterday's cup.
      final cart = ShopCart.empty
          .add(product(price: 10000))
          .setCount(product(price: 12000), 2);

      expect(cart.total, 24000);
    });

    test('removing one product leaves the others alone', () {
      final cart = ShopCart.empty
          .add(product(id: 'a'))
          .add(product(id: 'b'))
          .remove('a');

      expect(cart.lines, hasLength(1));
      expect(cart.contains('a'), isFalse);
      expect(cart.contains('b'), isTrue);
    });
  });

  group('totals and the checkout payload', () {
    test('counts units, not lines', () {
      // The badge says 3 for two cups and a pen, which is what went in.
      final cart = ShopCart.empty
          .add(product(id: 'a'), count: 2)
          .add(product(id: 'b'));

      expect(cart.lines, hasLength(2));
      expect(cart.count, 3);
    });

    test('sums every line', () {
      final cart = ShopCart.empty
          .add(product(id: 'a', price: 10000), count: 2)
          .add(product(id: 'b', price: 25000));

      expect(cart.total, 45000);
    });

    test('sends only ids and counts — never a price', () {
      // Prices in the basket are a preview. The server re-prices at checkout,
      // and letting the client post an amount is how you get a shop that can
      // be bought from at a discount of the buyer's choosing.
      final cart = ShopCart.empty.add(product(id: 'a'), count: 2);
      final items = cart.toCheckoutItems();

      expect(items, hasLength(1));
      expect(items.first.productId, 'a');
      expect(items.first.count, 2);
    });
  });
}

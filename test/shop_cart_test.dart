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
  num coinPrice = 6000,
  int available = 10,
}) =>
    ShopProduct(
      id: id,
      name: const {'en': 'Cup'},
      price: price,
      // Never a round fraction of `price` in these fixtures: the two prices
      // are unrelated by design, and a test that passes because 6000 happens
      // to be 0.6 × 10000 is not testing anything.
      coinPrice: coinPrice,
      available: available,
      inStock: available > 0,
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

    test('never exceeds what is left on the shelf', () {
      // Stock is the only ceiling now — there is no per-order limit on either
      // side any more. Two left means two, however many times it is added.
      var cart = ShopCart.empty;
      for (var i = 0; i < 9; i++) {
        cart = cart.add(product(available: 2));
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

  group('two prices', () {
    test('totals the money and the coin bills independently', () {
      final cart = ShopCart.empty
          .setCount(product(price: 10000, coinPrice: 6000), 2)
          .setCount(product(id: 'p2', price: 25000, coinPrice: 18000), 1);

      // 2 × 10 000 + 25 000 in money, 2 × 6 000 + 18 000 in coins. Neither is
      // derivable from the other, which is the whole point of the split.
      expect(cart.total, 45000);
      expect(cart.coinTotal, 30000);
    });

    test('a line knows both of its totals', () {
      final cart = ShopCart.empty.setCount(product(coinPrice: 6000), 3);

      expect(cart.lines.single.lineTotal, 30000);
      expect(cart.lines.single.lineCoinTotal, 18000);
    });

    test('an empty basket costs nothing in either unit', () {
      expect(ShopCart.empty.total, 0);
      expect(ShopCart.empty.coinTotal, 0);
    });
  });
}

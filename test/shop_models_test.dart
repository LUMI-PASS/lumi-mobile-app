import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/shop/shop_order.dart';
import 'package:lumi_pass/data/api_model/shop/shop_product.dart';

/// Parsing the shop payloads, and the two derived numbers the screens lead
/// with: what can actually be bought, and how an order was funded.
void main() {
  group('ShopProduct', () {
    test('reads the catalog payload', () {
      final product = ShopProduct.fromJson({
        'id': 'p1',
        'name': {'ru': 'Кружка', 'uz': 'Krujka', 'en': 'Cup'},
        'images': ['/uploads/cup.png', '/uploads/cup2.png'],
        'price': 85000,
        'old_price': 100000,
        'available': 8,
        'in_stock': true,
        'max_per_order': 3,
        'sold_count': 4,
      });

      expect(product.id, 'p1');
      expect(product.price, 85000);
      // The cover is the first image — the grid renders exactly this one.
      expect(product.image, '/uploads/cup.png');
      expect(product.hasDiscount, isTrue);
      expect(product.available, 8);
    });

    test('does not claim a discount when the old price is not higher', () {
      // A stale `old_price` at or below the current one would render as a
      // struck-through price rise, which reads as a mistake.
      final product = ShopProduct.fromJson({
        'id': 'p1',
        'price': 85000,
        'old_price': 85000,
      });
      expect(product.hasDiscount, isFalse);
    });

    test('survives a payload with nothing but an id', () {
      // The backend can add and drop fields; a product that fails to parse
      // takes the whole grid down with it.
      final product = ShopProduct.fromJson({'id': 'p1'});
      expect(product.image, '');
      expect(product.inStock, isFalse);
      expect(product.hasDiscount, isFalse);
    });
  });

  group('ShopOrder', () {
    Map<String, dynamic> payload({String status = 'new', num wallet = 30000}) => {
          'id': 'o1',
          'code': 'SHOP-7F3A-9B21',
          'order_id': 'ord1',
          'status': status,
          'items': [
            {
              'product_id': 'p1',
              'name': {'ru': 'Кружка'},
              'unit_price': 85000,
              'count': 2,
            },
          ],
          'delivery': {
            'lat': 41.311,
            'lng': 69.24,
            'address': 'Chilonzor 12',
            'contact_phone': '+998901112233',
          },
          'total_amount': 170000,
          'wallet_amount': wallet,
          'paid_amount': 140000,
          'promised_by': '2026-09-15T07:46:10.704Z',
          'timeline': [
            {'status': 'new', 'at': '2026-09-12T07:46:10.704Z'},
          ],
        };

    test('reads the order payload, delivery and timeline included', () {
      final order = ShopOrder.fromJson(payload());

      expect(order.code, 'SHOP-7F3A-9B21');
      expect(order.status, ShopOrderStatus.isNew);
      expect(order.itemCount, 2);
      expect(order.items.first.lineTotal, 170000);
      expect(order.delivery?.address, 'Chilonzor 12');
      expect(order.timeline.single.status, ShopOrderStatus.isNew);
      expect(order.promisedBy?.toUtc().day, 15);
    });

    test('only a brand-new order may be called off from the app', () {
      // Past NEW the item is with a courier, and the server refuses too — an
      // offered button that always errors is worse than no button.
      expect(ShopOrder.fromJson(payload()).isCancelable, isTrue);
      for (final status in ['confirmed', 'delivering', 'delivered', 'canceled']) {
        expect(
          ShopOrder.fromJson(payload(status: status)).isCancelable,
          isFalse,
          reason: status,
        );
      }
    });

    test('delivered and canceled are the finished states', () {
      expect(ShopOrderStatus.delivered.isFinished, isTrue);
      expect(ShopOrderStatus.canceled.isFinished, isTrue);
      expect(ShopOrderStatus.delivering.isFinished, isFalse);
    });
  });

  group('CheckoutResult from a shop checkout', () {
    // The shop deliberately answers with the same envelope a booking does —
    // which is the whole reason the payment sheet, the OTP sheet and the
    // gateway webview are reused rather than rewritten. If this ever stops
    // parsing, that reuse is silently broken.
    test('carries the coin/cash split', () {
      final result = CheckoutResult.fromJson({
        'order_id': 'ord1',
        'total_amount': 170000,
        'wallet_amount': 30000,
        'payable_amount': 140000,
        'currency': 'UZS',
        'status': 'pending',
        'checkout_url': 'https://checkout.paycom.uz/abc',
        'cashback_estimate': 0,
      });

      expect(result.totalAmount, 170000);
      expect(result.walletAmount, 30000);
      // What the gateway is charged. The total here is the classic bug: it
      // bills the buyer again for the part the coins covered.
      expect(result.payableAmount, 140000);
      // Merch earns nothing back — there is no partner commission to fund it.
      expect(result.cashbackEstimate, 0);
    });

    test('a fully coin-funded order comes back paid, with no gateway', () {
      final result = CheckoutResult.fromJson({
        'order_id': 'ord1',
        'total_amount': 170000,
        'wallet_amount': 170000,
        'payable_amount': 0,
        'currency': 'UZS',
        'status': 'paid',
        'checkout_url': null,
      });

      expect(result.status, 'paid');
      expect(result.checkoutUrl, isEmpty);
      expect(result.payableAmount, 0);
      // Not a card flow either — there is nothing to confirm.
      expect(result.isCardOtpPending, isFalse);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/utils/checkout_target.dart';

/// Two 400s that both looked like client bugs and were really routing mistakes,
/// found the first time the card rail was switched on.
///
/// The booking sheet sells both classes and courses. While only redirect rails
/// could be picked, the two paths that carry a card were never exercised on a
/// course — and each was wrong in its own way. These tests pin the rules those
/// paths must follow, because the failures they cause are silent until a real
/// card is in front of a real buyer.
void main() {
  group('a course is not sold through the activity endpoint', () {
    test('a course goes to its own endpoint', () {
      expect(checkoutTargetFor(isCourse: true), CheckoutTarget.course);
    });

    test('a class goes to the activity endpoint', () {
      expect(checkoutTargetFor(isCourse: false), CheckoutTarget.activity);
    });

    // The regression itself. A course is priced as a package and builds no
    // `items[]`; the activity endpoint requires at least one. Sending a course
    // there fails with "items must contain at least 1 elements" — which reads
    // like an empty basket, not like the wrong endpoint, and cost real time.
    test('a course never resolves to the endpoint that demands items', () {
      expect(
        checkoutTargetFor(isCourse: true),
        isNot(CheckoutTarget.activity),
        reason: 'the activity endpoint rejects a course for having no items[]',
      );
    });
  });

  group('a card payment must carry the card', () {
    // The other half of the same outage: the course branch named the rail and
    // passed no card, so the gateway answered "Card number, expire date, and
    // amount are required for card checkout".
    test('the card rail alone is not payable', () {
      expect(
        cardCheckoutIsComplete(
          provider: 'card',
          cardNumber: null,
          expireDate: null,
          savedCardId: null,
        ),
        isFalse,
      );
    });

    test('a typed card is payable', () {
      expect(
        cardCheckoutIsComplete(
          provider: 'card',
          cardNumber: '8600123456789012',
          expireDate: '3009',
          savedCardId: null,
        ),
        isTrue,
      );
    });

    test('a saved card is payable without a number', () {
      // Saved cards send only their id — the server holds the number.
      expect(
        cardCheckoutIsComplete(
          provider: 'card',
          cardNumber: null,
          expireDate: null,
          savedCardId: '6a83233b31c1d6183bd997f4',
        ),
        isTrue,
      );
    });

    test('half a card is not a card', () {
      for (final (number, expiry) in [
        ('8600123456789012', null),
        (null, '3009'),
        ('', '3009'),
        ('8600123456789012', ''),
        ('   ', '   '),
      ]) {
        expect(
          cardCheckoutIsComplete(
            provider: 'card',
            cardNumber: number,
            expireDate: expiry,
            savedCardId: null,
          ),
          isFalse,
          reason: 'number=$number expiry=$expiry should not be payable',
        );
      }
    });

    test('a blank saved-card id does not stand in for a card', () {
      expect(
        cardCheckoutIsComplete(
          provider: 'card',
          cardNumber: null,
          expireDate: null,
          savedCardId: '   ',
        ),
        isFalse,
      );
    });

    test('the redirect rails carry no card and are always complete', () {
      for (final rail in ['payme', 'click', 'uzum', 'paylov', null]) {
        expect(
          cardCheckoutIsComplete(
            provider: rail,
            cardNumber: null,
            expireDate: null,
            savedCardId: null,
          ),
          isTrue,
          reason: '$rail redirects and never carries a card',
        );
      }
    });
  });
}

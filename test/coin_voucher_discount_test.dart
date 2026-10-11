import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';

/// The coin figure on the Pay button has to be the figure the server spends,
/// and the server computes it — the app only repeats the sum to show it early.
/// These are the same cases as `coinsAfterDiscount` in the backend's
/// `new-coins.rules.spec.ts`; a change to one side must fail here.
void main() {
  group('newCoinsAfterDiscount', () {
    test("takes the voucher's share of the price off the coins", () {
      expect(newCoinsAfterDiscount(20, 100000, 50000), 10);
    });

    test('rounds the discount down, never the price', () {
      expect(newCoinsAfterDiscount(7, 70000, 35000), 4);
    });

    test('a capped voucher takes only its capped share', () {
      expect(newCoinsAfterDiscount(80, 400000, 100000), 60);
    });

    test('never goes below zero or above the list price', () {
      expect(newCoinsAfterDiscount(10, 50000, 80000), 0);
      expect(newCoinsAfterDiscount(10, 50000, 0), 10);
      expect(newCoinsAfterDiscount(10, 0, 5000), 10);
    });
  });

  group('ReferralVoucher.discountOn', () {
    test('an uncapped voucher is its percent of any order', () {
      const v = ReferralVoucher(code: 'R-AAAAAA', percent: 50);
      expect(v.discountOn(30000), 15000);
      expect(v.discountOn(900000), 450000);
    });

    test('a voucher issued with a cap still honours it', () {
      const v =
          ReferralVoucher(code: 'R-AAAAAA', percent: 50, maxDiscount: 200000);
      expect(v.discountOn(900000), 200000);
    });
  });
}

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/utils/new_coins_summary.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_enums.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';

/// The "new coins" models are hand-parsed, and the backend they read from can
/// be older than the app, newer than it, or half-configured (it is live on
/// production before any pack exists). So what is tested here is mostly what
/// happens when a field is absent or a vocabulary grows.
void main() {
  group('enums fall back to unknown', () {
    test('pack kind', () {
      expect(NewCoinPackKind.fromKey('monthly'), NewCoinPackKind.monthly);
      expect(NewCoinPackKind.fromKey('extra'), NewCoinPackKind.extra);
      expect(NewCoinPackKind.fromKey('yearly'), NewCoinPackKind.unknown);
      expect(NewCoinPackKind.fromKey(null), NewCoinPackKind.unknown);
      // The fallback's own key must never match a real payload.
      expect(NewCoinPackKind.fromKey(''), NewCoinPackKind.unknown);
    });

    test('lot kind', () {
      for (final kind in NewCoinLotKind.values) {
        if (kind == NewCoinLotKind.unknown) continue;
        expect(NewCoinLotKind.fromKey(kind.key), kind);
      }
      expect(NewCoinLotKind.fromKey('gift'), NewCoinLotKind.unknown);
      expect(NewCoinLotKind.fromKey(null), NewCoinLotKind.unknown);
    });

    test('transaction kind', () {
      for (final kind in NewCoinTransactionKind.values) {
        if (kind == NewCoinTransactionKind.unknown) continue;
        expect(NewCoinTransactionKind.fromKey(kind.key), kind);
      }
      expect(
        NewCoinTransactionKind.fromKey('refund'),
        NewCoinTransactionKind.unknown,
      );
      expect(
          NewCoinTransactionKind.fromKey(null), NewCoinTransactionKind.unknown);
    });

    test('error code, read off a response body', () {
      expect(
        NewCoinErrorCode.fromResponse({'error_code': 'insufficient_new_coins'}),
        NewCoinErrorCode.insufficient,
      );
      expect(
        NewCoinErrorCode.fromResponse(
            {'error_code': 'new_coins_not_cancelable'}),
        NewCoinErrorCode.notCancelable,
      );
      expect(
        NewCoinErrorCode.fromResponse({'error_code': 'promo_max_order'}),
        NewCoinErrorCode.unknown,
      );
      // Not a map at all — a gateway HTML page, a bare string, nothing.
      expect(NewCoinErrorCode.fromResponse('Bad Gateway'),
          NewCoinErrorCode.unknown);
      expect(NewCoinErrorCode.fromResponse(null), NewCoinErrorCode.unknown);
      // `unknown` is not a coin refusal, so it carries no message of its own.
      expect(NewCoinErrorCode.unknown.messageKey, isNull);
    });
  });

  group('NewCoinCatalogue', () {
    test('parses the shelf', () {
      final c = NewCoinCatalogue.fromJson({
        'monthly': [
          {
            'id': 'p1',
            'kind': 'monthly',
            'name': 'Start',
            'description': null,
            'price': 450000,
            'coins': 100,
            'valid_days': 30,
            'price_per_coin': 4500,
            'currency': 'UZS',
          },
        ],
        'extra': [
          {
            'id': 'p2',
            'kind': 'extra',
            'name': 'Top-up',
            'description': 'Ten more',
            'price': 50000,
            'coins': 10,
            'valid_days': 7,
            'price_per_coin': 5000,
          },
        ],
        'single_coin_price': 6000,
        'activity_rate': 4500,
        'can_buy_extras': true,
        'first_pack_bonus': 5,
      });

      expect(c.isOnSale, isTrue);
      expect(c.monthly.single.kind, NewCoinPackKind.monthly);
      expect(c.monthly.single.coins, 100);
      expect(c.monthly.single.validDays, 30);
      expect(c.monthly.single.pricePerCoin, 4500);
      expect(c.monthly.single.description, isNull);
      expect(c.extra.single.kind, NewCoinPackKind.extra);
      expect(c.extra.single.description, 'Ten more');
      expect(c.singleCoinPrice, 6000);
      expect(c.activityRate, 4500);
      expect(c.canBuyExtras, isTrue);
      expect(c.firstPackBonus, 5);
    });

    test('an empty body is an empty shelf, not a crash', () {
      final c = NewCoinCatalogue.fromJson({});
      expect(c.isOnSale, isFalse);
      expect(c.monthly, isEmpty);
      expect(c.extra, isEmpty);
      expect(c.singleCoinPrice, 0);
      expect(c.canBuyExtras, isFalse);
      expect(c.firstPackBonus, 0);
    });

    test('a pack of an unmodelled kind still parses', () {
      final pack = NewCoinPack.fromJson({'id': 'x', 'kind': 'yearly'});
      expect(pack.kind, NewCoinPackKind.unknown);
      expect(pack.kindKey, 'yearly');
      expect(pack.name, '');
      expect(pack.price, 0);
      expect(pack.pricePerCoin, isNull);
    });
  });

  group('NewCoinBalance', () {
    test('parses lots and the nearest deadline', () {
      final b = NewCoinBalance.fromJson({
        'balance': 42,
        'has_active_monthly': true,
        'nearest_expiry': '2026-11-01T00:00:00.000Z',
        'nearest_expiry_coins': 12,
        'lots': [
          {
            'id': 'l1',
            'kind': 'monthly',
            'coins_total': 100,
            'coins_left': 12,
            'expires_at': '2026-11-01T00:00:00.000Z',
            'purchased_at': '2026-10-02T00:00:00.000Z',
            'status': 'active',
          },
          {
            'id': 'l2',
            'kind': 'single',
            'coins_total': 30,
            'coins_left': 30,
            'expires_at': null,
            'purchased_at': '2026-10-03T00:00:00.000Z',
            'status': 'active',
          },
          {'id': 'l3', 'kind': 'cashback', 'coins_left': 0},
        ],
      });

      expect(b.balance, 42);
      expect(b.hasActiveMonthly, isTrue);
      expect(b.nearestExpiry, DateTime.utc(2026, 11, 1));
      expect(b.nearestExpiryCoins, 12);
      expect(b.lots, hasLength(3));
      expect(b.lots[0].kind, NewCoinLotKind.monthly);
      expect(b.lots[1].kind, NewCoinLotKind.single);
      // Loose coins never expire.
      expect(b.lots[1].expiresAt, isNull);
      expect(b.lots[2].kind, NewCoinLotKind.unknown);
      expect(b.lots[2].coinsTotal, 0);
    });

    test('absent fields read as an empty balance', () {
      final b = NewCoinBalance.fromJson({});
      expect(b.balance, 0);
      expect(b.hasActiveMonthly, isFalse);
      expect(b.nearestExpiry, isNull);
      expect(b.nearestExpiryCoins, 0);
      expect(b.lots, isEmpty);
    });
  });

  group('NewCoinTransactionPage', () {
    test('reads data + meta side by side (this endpoint is not wrapped)', () {
      final page = NewCoinTransactionPage.fromJson({
        'data': [
          {
            'id': 't1',
            'kind': 'spend',
            'amount': -14,
            'balance_after': 86,
            'order_id': 'o1',
            'activity_id': 'a1',
            'note': null,
            'created_at': '2026-10-03T10:00:00.000Z',
          },
          {'id': 't2', 'kind': 'cashback', 'amount': 3},
        ],
        'meta': {'page': 1, 'limit': 20, 'total': 45},
      });

      expect(page.items, hasLength(2));
      expect(page.items[0].kind, NewCoinTransactionKind.spend);
      expect(page.items[0].amount, -14);
      expect(page.items[0].balanceAfter, 86);
      expect(page.items[0].orderId, 'o1');
      expect(page.items[0].note, isNull);
      expect(page.items[1].kind, NewCoinTransactionKind.unknown);
      expect(page.items[1].createdAt, isNull);
      expect(page.total, 45);
      expect(page.hasMore, isTrue);
    });

    test('no meta means one page', () {
      final page = NewCoinTransactionPage.fromJson({'data': []});
      expect(page.items, isEmpty);
      expect(page.page, 1);
      expect(page.hasMore, isFalse);
    });
  });

  group('NewCoinPurchaseResult', () {
    test('carries the ordinary checkout result plus what the order mints', () {
      final r = NewCoinPurchaseResult.fromJson({
        'order_id': 'o9',
        'kind': 'monthly',
        'coins': 100,
        'valid_days': 30,
        'total_amount': 450000,
        'payable_amount': 450000,
        'currency': 'UZS',
        'status': 'pending',
        'payment_provider': 'click',
        'checkout_url': 'https://pay.example/x',
      });

      expect(r.coins, 100);
      expect(r.validDays, 30);
      expect(r.kind, NewCoinLotKind.monthly);
      expect(r.checkout.orderId, 'o9');
      expect(r.checkout.totalAmount, 450000);
      expect(r.checkout.checkoutUrl, 'https://pay.example/x');
      expect(r.checkout.isCardOtpPending, isFalse);
      // Buying coins is a money order, not a coin-paid one.
      expect(r.checkout.paidWithNewCoins, isFalse);
    });

    test('a card purchase comes back as a transaction to confirm', () {
      final r = NewCoinPurchaseResult.fromJson({
        'order_id': 'o9',
        'kind': 'single',
        'coins': 3,
        'checkout_url': null,
        'transaction_id': 'tx',
        'cid': 'c',
      });
      expect(r.kind, NewCoinLotKind.single);
      expect(r.validDays, 0);
      expect(r.checkout.isCardOtpPending, isTrue);
    });
  });

  group('NewCoinShortfall', () {
    test('reads an insufficient_new_coins refusal', () {
      final s = NewCoinShortfall.fromResponse({
        'message': 'Not enough coins for this booking',
        'error_code': 'insufficient_new_coins',
        'required': 14,
        'available': 9,
        'missing': 5,
      });
      expect(s, isNotNull);
      expect(s!.required, 14);
      expect(s.available, 9);
      expect(s.missing, 5);
    });

    test('works `missing` out when the server left it off', () {
      final s = NewCoinShortfall.fromResponse({
        'error_code': 'insufficient_new_coins',
        'required': 14,
        'available': 9,
      });
      expect(s!.missing, 5);
    });

    test('any other refusal is not a shortfall', () {
      expect(
        NewCoinShortfall.fromResponse({'error_code': 'new_coins_exclusive'}),
        isNull,
      );
      expect(NewCoinShortfall.fromResponse(null), isNull);
    });

    test('a local shortfall never goes negative', () {
      expect(NewCoinShortfall.of(required: 5, available: 9).missing, 0);
      expect(NewCoinShortfall.of(required: 9, available: 5).missing, 4);
    });
  });

  group('newCoinPriceFor (display fallback)', () {
    test('rounds up, like the server', () {
      expect(newCoinPriceFor(45000, 4500), 10);
      expect(newCoinPriceFor(45001, 4500), 11);
      expect(newCoinPriceFor(100, 4500), 1);
    });

    test('has nothing to say without a rate or a price', () {
      expect(newCoinPriceFor(45000, null), isNull);
      expect(newCoinPriceFor(45000, 0), isNull);
      expect(newCoinPriceFor(0, 4500), isNull);
    });
  });

  group('coin fields on existing models', () {
    test('a coin-paid checkout result', () {
      final r = CheckoutResult.fromJson({
        'order_id': 'o1',
        'total_amount': 60000,
        'payable_amount': 0,
        'status': 'paid',
        'checkout_url': null,
        'paid_with': 'new_coins',
        'new_coin_amount': 14,
        'new_coin_balance': 86,
      });
      expect(r.paidWithNewCoins, isTrue);
      expect(r.newCoinAmount, 14);
      expect(r.newCoinBalance, 86);
      expect(r.checkoutUrl, '');
      expect(r.status, 'paid');
    });

    test('a money checkout result, and one from a server without coins', () {
      final money = CheckoutResult.fromJson({
        'order_id': 'o1',
        'total_amount': 60000,
        'paid_with': 'money',
        'new_coin_amount': null,
        'new_coin_balance': null,
      });
      expect(money.paidWithNewCoins, isFalse);
      expect(money.newCoinAmount, 0);
      expect(money.newCoinBalance, isNull);

      final old = CheckoutResult.fromJson({'order_id': 'o1'});
      expect(old.paidWithNewCoins, isFalse);
      expect(old.newCoinAmount, 0);
    });

    test('an order paid with coins, and one that was not', () {
      final coins = UserOrder.fromJson({
        '_id': 'o1',
        'status': 'paid',
        'total_amount': 60000,
        'paid_with_new_coins': true,
        'new_coin_amount': 14,
      });
      expect(coins.paidWithNewCoins, isTrue);
      expect(coins.newCoinAmount, 14);

      final money = UserOrder.fromJson({'_id': 'o2', 'status': 'paid'});
      expect(money.paidWithNewCoins, isFalse);
      expect(money.newCoinAmount, 0);
    });

    test('an activity with coin prices', () {
      final c = ClassFullModel.fromJson({
        '_id': 'a1',
        'price_min': 30000,
        'price_max': 60000,
        'new_coin_rate': 4500,
        'new_coin_price_min': 7,
        'new_coin_price_max': 14,
        'age_tiers': [
          {
            'age_from': 3,
            'age_to': 6,
            'durations': [
              {'duration': 60, 'price': 30000, 'new_coin_price': 7},
              // A row the server did not price in coins.
              {'duration': 120, 'price': 60000},
            ],
          },
        ],
      });
      expect(c.hasNewCoinPrices, isTrue);
      expect(c.newCoinPriceMin, 7);
      expect(c.newCoinPriceMax, 14);
      expect(c.ageTiers.single.durations[0].newCoinPrice, 7);
      expect(c.ageTiers.single.durations[1].newCoinPrice, isNull);
      // The flat summary derived from the tiers keeps the cheapest row's coins.
      expect(c.pricesSummary.single.newCoinPrice, 7);
    });

    test('legacy flat prices carry their coin price', () {
      final c = ClassFullModel.fromJson({
        'new_coin_rate': 4500,
        'prices_summary': [
          {'age_from': 3, 'age_to': 6, 'price': 45000, 'new_coin_price': 10},
        ],
      });
      expect(c.pricesSummary.single.newCoinPrice, 10);
    });

    test('old data has no coin prices at all', () {
      final c = ClassFullModel.fromJson({
        'prices_summary': [
          {'age_from': 3, 'age_to': 6, 'price': 45000},
        ],
      });
      expect(c.hasNewCoinPrices, isFalse);
      expect(c.newCoinRate, isNull);
      expect(c.newCoinPriceMin, isNull);
      expect(c.pricesSummary.single.newCoinPrice, isNull);
    });

    test('a course is never quoted in coins, whatever the payload says', () {
      final c = ClassFullModel.fromJson({
        'is_course': true,
        'new_coin_rate': 4500,
        'new_coin_price_min': 7,
      });
      expect(c.hasNewCoinPrices, isFalse);
    });
  });

  group('NewCoinsSummary', () {
    test('invisible until a monthly pack is on sale', () {
      expect(const NewCoinsSummary().isVisible, isFalse);
      final extrasOnly = const NewCoinsSummary().withCatalogue(
        NewCoinCatalogue.fromJson({
          'extra': [
            {'id': 'p', 'kind': 'extra'},
          ],
          'single_coin_price': 6000,
        }),
      );
      expect(extrasOnly.isVisible, isFalse);

      final onSale = const NewCoinsSummary().withCatalogue(
        NewCoinCatalogue.fromJson({
          'monthly': [
            {'id': 'p', 'kind': 'monthly'},
          ],
        }),
      );
      expect(onSale.isVisible, isTrue);
    });

    test('coins already held stay visible after the shelf empties', () {
      final held = const NewCoinsSummary()
          .withBalance(NewCoinBalance.fromJson({'balance': 3}));
      expect(held.onSale, isFalse);
      expect(held.isVisible, isTrue);
    });

    test('loose coins need a live monthly pack and a price', () {
      NewCoinsSummary of(Map<String, dynamic> json) => const NewCoinsSummary()
          .withCatalogue(NewCoinCatalogue.fromJson(json));

      expect(
        of({'can_buy_extras': true, 'single_coin_price': 6000}).canBuySingle,
        isTrue,
      );
      expect(
        of({'can_buy_extras': false, 'single_coin_price': 6000}).canBuySingle,
        isFalse,
      );
      expect(of({'can_buy_extras': true}).canBuySingle, isFalse);
    });

    test('signing out keeps the shelf and drops the coins', () {
      final signedIn = const NewCoinsSummary()
          .withCatalogue(NewCoinCatalogue.fromJson({
            'monthly': [
              {'id': 'p', 'kind': 'monthly'},
            ],
            'can_buy_extras': true,
            'activity_rate': 4500,
          }))
          .withBalance(NewCoinBalance.fromJson({
            'balance': 20,
            'has_active_monthly': true,
          }));
      final out = signedIn.signedOut();
      expect(out.onSale, isTrue);
      expect(out.activityRate, 4500);
      expect(out.balance, 0);
      expect(out.hasActiveMonthly, isFalse);
      expect(out.canBuyExtras, isFalse);
    });
  });

  // These keys are built from enums (`kind.labelKey`, `code.messageKey`), so a
  // grep for `'key'.tr()` misses them and a missing row would only be found by
  // a parent reading the raw key on screen.
  group('translations', () {
    late Map<String, List<String>> translations;

    setUpAll(() {
      final raw =
          File('assets/localization/translations.csv').readAsStringSync();
      final rows =
          const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
              .convert(raw);
      translations = {
        for (final row in rows)
          if (row.isNotEmpty)
            row.first.toString(): row.skip(1).map((c) => c.toString()).toList(),
      };
    });

    test('every enum-built key has ru, uz and en', () {
      final keys = <String>[
        for (final k in NewCoinLotKind.values) k.labelKey,
        for (final k in NewCoinTransactionKind.values) k.labelKey,
        for (final c in NewCoinErrorCode.values)
          if (c.messageKey != null) c.messageKey!,
      ];
      final problems = <String>[];
      for (final key in keys) {
        final row = translations[key];
        if (row == null || row.length < 3) {
          problems.add('$key — missing or short');
          continue;
        }
        if (row.take(3).any((c) => c.trim().isEmpty)) {
          problems.add('$key — blank column');
        }
      }
      expect(problems, isEmpty, reason: problems.join('\n'));
    });
  });
}

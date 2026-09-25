import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/utils/promo_pass_coverage.dart';
import 'package:lumi_pass/data/api_model/promo/promo_pass.dart';

/// The rule behind every hidden price in the app.
///
/// It mirrors `PromoService.assess` on the backend minus the date, which makes
/// it the one piece of promo logic that exists twice — so it is the one that
/// most needs pinning down. Every case here answers the same question: does
/// this show the buyer a price, or the included badge?
///
/// The bias is asserted as much as the rule: where the app cannot know, it must
/// show the PRICE. A wrongly-shown price is a moment of confusion; a wrongly
/// hidden one is a promise the checkout then breaks.
void main() {
  PromoPassCoverage pass({
    int left = 3,
    bool fullCoverage = true,
    Set<String> used = const {},
    Set<String> activityIds = const {},
    Set<String> categoryIds = const {},
    num? maxPrice,
    bool distinct = true,
    bool allowCourses = false,
  }) =>
      PromoPassCoverage(
        id: 'p1',
        title: 'Lumi Start',
        activitiesLeft: left,
        activitiesTotal: 3,
        daysLeft: 4,
        usedActivityIds: used,
        activityIds: activityIds,
        categoryIds: categoryIds,
        maxActivityPrice: maxPrice,
        distinctActivities: distinct,
        allowCourses: allowCourses,
        isFullCoverage: fullCoverage,
      );

  bool covers(
    PromoPassCoverage p, {
    String? id = 'a1',
    num price = 30000,
    bool isWholeCourse = false,
    Iterable<String> categories = const [],
  }) =>
      p.covers(
        activityId: id,
        price: price,
        isWholeCourse: isWholeCourse,
        categoryIds: categories,
      );

  group('what the packet hides', () {
    test('covers a one-time activity within scope and under the ceiling', () {
      expect(covers(pass()), isTrue);
    });

    test('covers a course TRIAL lesson but never the enrolment', () {
      // A visit buys one lesson, not a term — the line the backend's `assess`
      // and the coupon plan both draw.
      expect(covers(pass(), isWholeCourse: false), isTrue);
      expect(covers(pass(), isWholeCourse: true), isFalse);
      expect(covers(pass(allowCourses: true), isWholeCourse: true), isTrue);
    });

    test('brings the price back at a place already visited', () {
      // Three DIFFERENT activities: the second visit here is the buyer's, so
      // the price must reappear rather than read as free and fail at checkout.
      expect(covers(pass(used: {'a1'}), id: 'a1'), isFalse);
      expect(covers(pass(used: {'a1'}), id: 'a2'), isTrue);
    });

    test('ignores the repeat rule when the campaign allows repeats', () {
      expect(covers(pass(used: {'a1'}, distinct: false), id: 'a1'), isTrue);
    });

    test('brings every price back once the visits are spent', () {
      // The whole point of "till 3 bookings used".
      expect(covers(pass(left: 0)), isFalse);
      expect(pass(left: 0).isSpent, isTrue);
    });

    test('keeps the price on anything dearer than the packet covers', () {
      expect(covers(pass(maxPrice: 60000), price: 60000), isTrue);
      expect(covers(pass(maxPrice: 60000), price: 60001), isFalse);
    });

    test('an unknown price cannot be refused by the ceiling', () {
      // Callers that do not know the figure pass 0. Erring toward the label is
      // safe: checkout re-tests the ceiling and refuses with a message.
      expect(covers(pass(maxPrice: 1000), price: 0), isTrue);
    });
  });

  group('scope', () {
    test('an empty scope is the whole catalogue', () {
      expect(covers(pass()), isTrue);
    });

    test('a named activity is in, anything else is out', () {
      final p = pass(activityIds: {'a1'});
      expect(covers(p, id: 'a1'), isTrue);
      expect(covers(p, id: 'a2'), isFalse);
    });

    test('a category matches through the activity\'s own categories', () {
      final p = pass(categoryIds: {'kids'});
      expect(covers(p, categories: ['kids']), isTrue);
      expect(covers(p, categories: ['teens']), isFalse);
    });

    test('a card that cannot supply categories keeps its price', () {
      // List cards carry no category ids. Falling back to "covered" would
      // promise free bookings on a category-scoped campaign; the detail screen
      // has the ids and shows the label there instead.
      expect(covers(pass(categoryIds: {'kids'}), categories: const []), isFalse);
    });
  });

  group('safety rails', () {
    test('a percent packet keeps prices — there is still something to pay', () {
      expect(covers(pass(fullCoverage: false)), isFalse);
    });

    test('an activity with no id is never claimed as covered', () {
      expect(covers(pass(), id: null), isFalse);
    });
  });

  group('PromoPassCoverage.fromPass', () {
    test('is null for anything the server does not call usable', () {
      expect(PromoPassCoverage.fromPass(null), isNull);
      expect(
        PromoPassCoverage.fromPass(
          PromoPass.fromJson({'id': 'p', 'code': 'c', 'is_usable': false}),
        ),
        isNull,
      );
    });

    test('carries the scope and the places already visited', () {
      final c = PromoPassCoverage.fromPass(PromoPass.fromJson({
        'id': 'p1',
        'code': 'AKSIYA-A-B',
        'title': 'Lumi Start',
        'is_usable': true,
        'status': 'active',
        'activities_total': 3,
        'activities_used': 1,
        'activities_left': 2,
        'days_left': 4,
        'coverage': 'full',
        'distinct_activities': true,
        'activity_ids': ['a1', 'a2'],
        'category_ids': ['kids'],
        'max_activity_price': 60000,
        'allow_courses': false,
        'redemptions': [
          {'activity_id': 'a1', 'order_id': 'o1'},
        ],
      }))!;

      expect(c.title, 'Lumi Start');
      expect(c.activitiesLeft, 2);
      expect(c.activityIds, {'a1', 'a2'});
      expect(c.categoryIds, {'kids'});
      expect(c.maxActivityPrice, 60000);
      expect(c.usedActivityIds, {'a1'});
      // Already spent at a1, so a1's price is back while a2's is not.
      expect(covers(c, id: 'a1'), isFalse);
      expect(covers(c, id: 'a2'), isTrue);
    });

    test('an older backend that sends no scope covers everything', () {
      // Absent lists meant "the whole catalogue" before the fields existed.
      final c = PromoPassCoverage.fromPass(PromoPass.fromJson({
        'id': 'p1',
        'code': 'c',
        'is_usable': true,
        'activities_total': 3,
        'activities_left': 3,
        'coverage': 'full',
      }))!;
      expect(c.activityIds, isEmpty);
      expect(covers(c), isTrue);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/order/course_purchase.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';

/// Three products are sold through one checkout — a whole course, one trial
/// lesson off its ladder, and a plain activity booking — and they arrive on the
/// same order card. What the buyer sees has to say which one it was, and the
/// price shown has to be a price of something they recognise.
void main() {
  group('what an order bought', () {
    test('reads the kinds the backend sends today', () {
      expect(CoursePurchase.fromKey('trial'), CoursePurchase.trial);
      expect(CoursePurchase.fromKey('full'), CoursePurchase.full);
    });

    test('an absent value is a plain activity, not a missing answer', () {
      // The field is only written on course orders, so "not there" is the
      // third answer rather than a hole to null-check at every call site.
      expect(CoursePurchase.fromKey(null), CoursePurchase.none);
      expect(CoursePurchase.fromKey(''), CoursePurchase.none);
      expect(CoursePurchase.fromKey('   '), CoursePurchase.none);
      expect(CoursePurchase.none.isCourse, isFalse);
    });

    test('a kind this build has not heard of stays a course', () {
      // Only course orders carry the field at all, so the safe half of the
      // truth is "a course, kind unspecified" — never "a single activity".
      expect(CoursePurchase.fromKey('bundle_of_four'), CoursePurchase.unknown);
      expect(CoursePurchase.unknown.isCourse, isTrue);
    });

    test('names the kind off a real order payload', () {
      final order = UserOrder.fromJson(const {
        '_id': 'o1',
        'status': 'paid',
        'total_amount': 1200000,
        'course_purchase': 'full',
        'subcourse_name': 'Beginner',
        'starts_at': '2026-09-01T00:00:00.000Z',
        'wallet_amount': 50000,
      });
      expect(order.isWholeCourse, isTrue);
      expect(order.isTrialLesson, isFalse);
      expect(order.isCourseOrder, isTrue);
      expect(order.subcourseName, 'Beginner');
      // Date only — the enrolment starts on a day, not at a time.
      expect(order.startsAt, '2026-09-01');
      expect(order.hasWalletPayment, isTrue);
      expect(order.walletAmount, 50000);
    });

    test('an activity order claims none of it', () {
      final order = UserOrder.fromJson(const {
        '_id': 'o2',
        'status': 'paid',
        'total_amount': 70000,
      });
      expect(order.coursePurchase, CoursePurchase.none);
      expect(order.isCourseOrder, isFalse);
      expect(order.hasWalletPayment, isFalse);
    });
  });

  group('what a ticket cost', () {
    OrderTicket ticket(Map<String, dynamic> json) => OrderTicket.fromJson(json);

    test('carries the duration tier it was bought at', () {
      final t = ticket(const {'_id': 't1', 'price': 70000, 'duration': 60});
      expect(t.duration, 60);
      expect(t.hasDurationTier, isTrue);
      expect(t.isUnlimitedDuration, isFalse);
    });

    test('a null duration is the UNLIMITED tier, not a missing one', () {
      // The distinction is the whole point: unlimited is a tier a buyer chose
      // and paid more for, and it has to be sayable on the ticket.
      final t = ticket(const {'_id': 't2', 'price': 100000, 'duration': null});
      expect(t.hasDurationTier, isTrue);
      expect(t.isUnlimitedDuration, isTrue);
    });

    test('a booking written before durations existed knows it has none', () {
      final t = ticket(const {'_id': 't3', 'price': 70000});
      expect(t.hasDurationTier, isFalse);
      expect(t.isUnlimitedDuration, isFalse);
    });
  });

  group('when the order runs', () {
    UserOrder withTickets(List<String> dates, {String? startsAt}) =>
        UserOrder.fromJson({
          '_id': 'o3',
          'status': 'pending',
          'total_amount': 840000,
          'course_purchase': 'full',
          if (startsAt != null) 'starts_at': startsAt,
          'tickets': [
            for (final d in dates)
              {'ticket_date': d, 'start_time': '18:00', 'end_time': '19:00'},
          ],
        });

    test('spans from the first session booked to the last', () {
      // The real payload for a 13-lesson football course: no `starts_at` at
      // all, thirteen dated sessions. Its span is the only thing that can
      // answer "when does this run".
      final order = withTickets(const [
        '2026-08-04',
        '2026-08-06',
        '2026-09-01',
        '2026-08-29',
      ]);
      expect(order.startDate, '2026-08-04');
      expect(order.endDate, '2026-09-01');
      expect(order.spansDates, isTrue);
    });

    test('prefers the enrolment start the backend recorded', () {
      // An enrolment can start before its first lesson — that is the date the
      // buyer was sold, so it outranks the session list.
      final order = withTickets(
        const ['2026-09-08'],
        startsAt: '2026-09-01T00:00:00.000Z',
      );
      expect(order.startDate, '2026-09-01');
      expect(order.endDate, '2026-09-08');
    });

    test('a single session is a date, not a span', () {
      final order = withTickets(const ['2026-08-04']);
      expect(order.spansDates, isFalse);
    });

    test('an order with nothing dated yet claims no span', () {
      final order = withTickets(const []);
      expect(order.startDate, isNull);
      expect(order.endDate, isNull);
      expect(order.spansDates, isFalse);
    });
  });

  group('whether there is an age bracket to show', () {
    UserOrder withItems(List<Map<String, dynamic>> items) => UserOrder.fromJson({
          '_id': 'o4',
          'status': 'paid',
          'total_amount': 70000,
          'items': items,
        });

    test('a course order has none, so the row is left out', () {
      // The real payload: `items: []` on a whole-course order. The row used to
      // render with an empty label beside a seat count of zero.
      expect(withItems(const []).hasAgeBracket, isFalse);
    });

    test('0–99 is "whoever it admits", not a bracket anyone picked', () {
      expect(
        withItems(const [
          {'age_from': 0, 'age_to': 99, 'count': 1, 'unit_price': 70000},
        ]).hasAgeBracket,
        isFalse,
      );
    });

    test('a real tier is shown', () {
      expect(
        withItems(const [
          {'age_from': 3, 'age_to': 6, 'count': 2, 'unit_price': 70000},
        ]).hasAgeBracket,
        isTrue,
      );
    });
  });
}

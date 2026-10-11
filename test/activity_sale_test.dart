import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/activity_sale/activity_sale.dart';

void main() {
  // 20% off, October, Monday to Friday, 09:00–18:00.
  const weekdays = ActivitySale(
    percent: 20,
    startDate: '2026-10-01',
    endDate: '2026-10-31',
    days: [1, 2, 3, 4, 5],
    startTime: '09:00',
    endTime: '18:00',
  );
  final tuesday = DateTime(2026, 10, 13);
  final saturday = DateTime(2026, 10, 17);
  final sunday = DateTime(2026, 10, 18);

  group('ActivitySale.covers', () {
    test('a weekday lesson inside the hours is on sale', () {
      expect(weekdays.covers(tuesday, startTime: '11:00'), isTrue);
    });

    test('the weekend is not, whatever the hour', () {
      expect(weekdays.covers(saturday, startTime: '11:00'), isFalse);
      expect(weekdays.covers(sunday, startTime: '11:00'), isFalse);
    });

    test('Sunday is day 0, as the server counts it', () {
      const sundays = ActivitySale(
        percent: 10,
        startDate: '2026-10-01',
        endDate: '2026-10-31',
        days: [0],
      );
      expect(sundays.covers(sunday), isTrue);
      expect(sundays.covers(saturday), isFalse);
    });

    test('takes the start of the window and leaves out its end', () {
      expect(weekdays.covers(tuesday, startTime: '09:00'), isTrue);
      expect(weekdays.covers(tuesday, startTime: '17:59'), isTrue);
      expect(weekdays.covers(tuesday, startTime: '18:00'), isFalse);
      expect(weekdays.covers(tuesday, startTime: '08:59'), isFalse);
    });

    test('a lesson with no time is not on a sale that has hours', () {
      expect(weekdays.covers(tuesday), isFalse);
    });

    test('both ends of the date range are in, a day past either is out', () {
      const allDay = ActivitySale(
        percent: 10,
        startDate: '2026-10-05',
        endDate: '2026-10-07',
      );
      expect(allDay.covers(DateTime(2026, 10, 5)), isTrue);
      expect(allDay.covers(DateTime(2026, 10, 7)), isTrue);
      expect(allDay.covers(DateTime(2026, 10, 4)), isFalse);
      expect(allDay.covers(DateTime(2026, 10, 8)), isFalse);
    });
  });

  test('a day is marked whatever the hour, and only on the days it runs', () {
    expect(weekdays.coversDay(tuesday), isTrue);
    expect(weekdays.coversDay(saturday), isFalse);
    expect(weekdays.coversDay(DateTime(2026, 11, 3)), isFalse);
    expect(ActivitySale.bestPercentOnDay([weekdays], tuesday), 20);
    expect(ActivitySale.bestPercentOnDay([weekdays], sunday), 0);
  });

  test('best takes the biggest that covers the lesson, never the sum', () {
    const allDay = ActivitySale(
      percent: 10,
      startDate: '2026-10-01',
      endDate: '2026-10-31',
    );
    expect(
      ActivitySale.best([allDay, weekdays], tuesday, startTime: '11:00'),
      weekdays,
    );
    expect(ActivitySale.best([allDay, weekdays], saturday), allDay);
    expect(ActivitySale.best([weekdays], saturday), isNull);
  });

  test('priceAfter rounds to the nearest so\'m, as the server does', () {
    expect(weekdays.priceAfter(100000), 80000);
    expect(ActivitySale.discountedBy(33333, 15), 28333);
    expect(ActivitySale.discountedBy(0, 20), 0);
  });

  group('ActivitySale.tryParse', () {
    test('reads what the server sends', () {
      final sale = ActivitySale.tryParse({
        'percent': 20,
        'start_date': '2026-10-01',
        'end_date': '2026-10-31',
        'days': [1, 2, 3, 4, 5],
        'start_time': '09:00',
        'end_time': '18:00',
      })!;
      expect(sale.percent, 20);
      expect(sale.days, [1, 2, 3, 4, 5]);
      expect(sale.hasHours, isTrue);
      expect(sale.isConditional, isTrue);
    });

    test('an all-day, every-day sale carries no condition', () {
      final sale = ActivitySale.tryParse({
        'percent': 15,
        'start_date': '2026-10-01',
        'end_date': '2026-10-31',
        'days': [],
        'start_time': null,
        'end_time': null,
      })!;
      expect(sale.isConditional, isFalse);
    });

    test('nonsense is no sale rather than a crash', () {
      expect(ActivitySale.tryParse(null), isNull);
      expect(ActivitySale.tryParse('20%'), isNull);
      expect(ActivitySale.tryParse({'percent': 0}), isNull);
      expect(ActivitySale.tryParse({'percent': 20}), isNull);
      expect(ActivitySale.listFromJson([1, null, {}]), isEmpty);
    });
  });
}

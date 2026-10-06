import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/order/day_booking.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';

/// What the home shelf ("bugun borilishi kerak") is allowed to say.
///
/// The selection rules are the whole feature: a shelf that lists a cancelled
/// seat, a draft nobody paid for, or a lesson that finished at nine in the
/// morning is worse than no shelf, because it is read as a to-do list.
void main() {
  const today = '2026-10-05';
  const tomorrow = '2026-10-06';
  final now = DateTime(2026, 10, 5, 8, 30);

  Map<String, dynamic> order({
    String id = 'o1',
    String status = 'paid',
    String? activityId = 'a1',
    String name = 'Shaxmat',
    List<Map<String, dynamic>> tickets = const [],
    List<Map<String, dynamic>> schedule = const [],
  }) =>
      {
        '_id': id,
        'status': status,
        'activity_id': activityId == null
            ? null
            : {'_id': activityId, 'name': name, 'schedule': schedule},
        'tickets': tickets,
      };

  Map<String, dynamic> ticket({
    String date = today,
    String? start,
    String? end,
    String status = 'confirmed',
    String? attendance,
  }) =>
      {
        'ticket_date': date,
        if (start != null) 'start_time': start,
        if (end != null) 'end_time': end,
        'status': status,
        if (attendance != null) 'attendance_status': attendance,
      };

  List<DayBooking> dueToday(List<Map<String, dynamic>> orders) =>
      DayBooking.dueToday(orders.map(UserOrder.fromJson), now: now);

  test('lists only what is owed today, soonest first', () {
    final shelf = dueToday([
      order(id: 'late', name: 'Suzish', tickets: [
        ticket(start: '18:00', end: '19:00'),
      ]),
      order(id: 'early', name: 'Shaxmat', tickets: [
        ticket(start: '09:00', end: '10:00'),
      ]),
      order(id: 'not-today', name: 'Raqs', tickets: [
        ticket(date: tomorrow, start: '08:00', end: '09:00'),
      ]),
    ]);

    expect(shelf.map((b) => b.order.id), ['early', 'late']);
    expect(shelf.first.timeLabel, '09:00 - 10:00');
  });

  test('a seat with no time of its own takes the activity timetable for '
      "today's weekday", () {
    // 2026-10-05 is a Monday; the Friday slot must not be the one quoted.
    final shelf = dueToday([
      order(
        tickets: [ticket()],
        schedule: [
          {'day': 'friday', 'start_time': '16:00', 'end_time': '17:00'},
          {'day': 'monday', 'start_time': '11:30', 'end_time': '12:30'},
        ],
      ),
    ]);

    expect(shelf.single.timeLabel, '11:30 - 12:30');
  });

  test('a seat that knows its start does not borrow the timetable end', () {
    final shelf = dueToday([
      order(
        tickets: [ticket(start: '09:15')],
        schedule: [
          {'day': 'monday', 'start_time': '11:30', 'end_time': '12:30'},
        ],
      ),
    ]);

    expect(shelf.single.timeLabel, '09:15');
    expect(shelf.single.endMinutes, isNull);
  });

  test('drafts, cancellations and visits already made are left off', () {
    final shelf = dueToday([
      order(id: 'pending', status: 'pending', tickets: [
        ticket(start: '09:00', end: '10:00'),
      ]),
      order(id: 'cancelled-order', status: 'canceled', tickets: [
        ticket(start: '09:00', end: '10:00'),
      ]),
      order(id: 'cancelled-seat', tickets: [
        ticket(start: '09:00', end: '10:00', status: 'canceled'),
      ]),
      order(id: 'attended', tickets: [
        ticket(start: '09:00', end: '10:00', attendance: 'attended'),
      ]),
      order(id: 'pack', activityId: null, tickets: [
        ticket(start: '09:00', end: '10:00'),
      ]),
      order(id: 'due', tickets: [ticket(start: '09:00', end: '10:00')]),
    ]);

    expect(shelf.map((b) => b.order.id), ['due']);
  });

  test('two children on the same slot are one entry, two seats', () {
    final shelf = dueToday([
      order(tickets: [
        ticket(start: '09:00', end: '10:00'),
        ticket(start: '09:00', end: '10:00'),
        ticket(start: '15:00', end: '16:00'),
      ]),
    ]);

    expect(shelf.length, 2);
    expect(shelf.first.seats, 2);
    expect(shelf.last.seats, 1);
  });

  test('an entry with no clock at all sorts after every timed one', () {
    final shelf = dueToday([
      order(id: 'untimed', name: 'Raqs', tickets: [ticket()]),
      order(id: 'timed', name: 'Shaxmat', tickets: [
        ticket(start: '17:00', end: '18:00'),
      ]),
    ]);

    expect(shelf.map((b) => b.order.id), ['timed', 'untimed']);
    expect(shelf.last.timeLabel, isEmpty);
  });

  group('what is still to come', () {
    List<DayBooking> at(int hour, int minute) => DayBooking.stillToCome(
          dueToday([
            order(id: 'morning', name: 'A', tickets: [
              ticket(start: '09:00', end: '10:00'),
            ]),
            order(id: 'evening', name: 'B', tickets: [
              ticket(start: '18:00', end: '19:00'),
            ]),
            order(id: 'open-ended', name: 'C', tickets: [ticket(start: '07:00')]),
          ]),
          DateTime(2026, 10, 5, hour, minute),
        );

    test('a finished lesson drops off, an open-ended one does not', () {
      // 10:30 — the morning lesson is over; the 07:00 with no end time stays,
      // because nothing on it says it has finished.
      expect(at(10, 30).map((b) => b.order.id), ['open-ended', 'evening']);
    });

    test('a lesson under way is kept, and reads as happening now', () {
      final shelf = at(9, 30);
      final morning = shelf.firstWhere((b) => b.order.id == 'morning');
      expect(morning.isUnderwayAt(DateTime(2026, 10, 5, 9, 30)), isTrue);
      expect(morning.isUnderwayAt(DateTime(2026, 10, 5, 10, 0)), isFalse);
    });

    test('nothing is left by the end of the day', () {
      // Only the open-ended one, which no clock can retire.
      expect(at(23, 0).map((b) => b.order.id), ['open-ended']);
    });
  });

  test('a mangled wire time is treated as no time, not as midnight', () {
    final shelf = dueToday([
      order(id: 'bad', name: 'A', tickets: [ticket(start: '99:99')]),
      order(id: 'good', name: 'B', tickets: [ticket(start: '08:00')]),
    ]);

    // '99:99' must not sort to the front as 00:00 — it is simply unknown.
    expect(shelf.map((b) => b.order.id), ['good', 'bad']);
    expect(shelf.last.startMinutes, isNull);
  });

  test('minutes until start counts down and then goes negative', () {
    final shelf = dueToday([
      order(tickets: [ticket(start: '09:00', end: '10:00')]),
    ]);

    expect(shelf.single.minutesUntilStart(now), 30);
    expect(
      shelf.single.minutesUntilStart(DateTime(2026, 10, 5, 9, 15)),
      -15,
    );
  });
}

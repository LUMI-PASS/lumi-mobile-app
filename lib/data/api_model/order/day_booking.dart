import 'package:lumi_pass/data/api_model/order/user_order.dart';

/// One visit to make on one particular day, with the clock it happens at.
///
/// An [UserOrder] is a transaction and can hold seats across many dates; this
/// is the other way round — one day, and what is due on it. It exists so the
/// home shelf ("bugun borilishi kerak") can be ordered by time, which an order
/// cannot be: an order that booked a Monday and a Friday has no single clock.
///
/// Seats on the same order at the same time are ONE entry carrying a [seats]
/// count: a parent who booked two children onto the same morning has one place
/// to be, not two.
class DayBooking {
  const DayBooking({
    required this.order,
    required this.lessons,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  /// The order this visit was bought on. Carries the name, the branch, the
  /// picture and the id the detail screen is opened with.
  final UserOrder order;

  /// The seats this entry stands for — all on [date], all at the same time.
  final List<OrderTicketSummary> lessons;

  /// The day it falls on, `YYYY-MM-DD`.
  final String date;

  /// `HH:mm`, or null when neither the booking nor the activity's timetable
  /// names one. Such an entry still belongs on the shelf — it is a visit that
  /// has been paid for — it just sorts last and shows no clock.
  final String? startTime;
  final String? endTime;

  int get seats => lessons.length;

  /// The first seat, for anything that needs a single ticket (a ticket number,
  /// an attendance mark). They share a date and a time by construction.
  OrderTicketSummary get lesson => lessons.first;

  /// `09:00 - 10:00`, `09:00`, or empty when the time is unknown.
  String get timeLabel {
    final s = startTime;
    if (s == null) return '';
    final e = endTime;
    return e == null ? s : '$s - $e';
  }

  int? get startMinutes => _minutesOfClock(startTime);
  int? get endMinutes => _minutesOfClock(endTime);

  /// True once this visit is over.
  ///
  /// Only an end time can say that. A booking that recorded no end — the
  /// activity sent no timetable, or only a start — is NOT declared finished
  /// just because its start has passed: the shelf would drop a lesson at the
  /// very moment the parent is on their way to it. It stays up for the rest of
  /// the day instead.
  bool hasEndedBy(DateTime now) {
    final end = endMinutes;
    return end != null && end <= _minutesOfDay(now);
  }

  /// True while the lesson is happening — what the "now" pill is drawn from.
  /// Needs both ends of the slot to be known, for the same reason above.
  bool isUnderwayAt(DateTime now) {
    final start = startMinutes;
    final end = endMinutes;
    if (start == null || end == null) return false;
    final m = _minutesOfDay(now);
    return m >= start && m < end;
  }

  /// Whole minutes until it starts. Negative once it has, null when there is
  /// no start time to count to.
  int? minutesUntilStart(DateTime now) {
    final start = startMinutes;
    return start == null ? null : start - _minutesOfDay(now);
  }

  /// Every visit due on [day], soonest first.
  ///
  /// Narrowed to what is actually owed:
  ///  • a PAID activity order — a draft nobody paid for is not a commitment,
  ///    and a cancelled one is the opposite of one;
  ///  • a seat dated [day] that was not called off ([UserOrder.lessonsOn]);
  ///  • a seat nobody has marked attended — once the partner takes the
  ///    register, the visit has been made and has no business on the shelf.
  ///
  /// Time is deliberately NOT filtered here: that is [stillToCome], so the
  /// list can be fetched once and re-read against the clock on every build.
  static List<DayBooking> dueOn(Iterable<UserOrder> orders, DateTime day) {
    final iso = UserOrder.dayKey(day);
    final due = <DayBooking>[];
    for (final order in orders) {
      if (!order.isActivityOrder || !order.isPaid) continue;
      final lessons = order
          .lessonsOn(iso)
          .where((l) => l.attendanceStatus != 'attended')
          .toList();
      if (lessons.isEmpty) continue;

      // The activity's own timetable answers for a seat that recorded no time
      // of its own — a course lesson records none, and neither does a class
      // booked straight off its recurring schedule. Resolved for THIS date's
      // weekday, not the order's start date: a course enrolled in September
      // would otherwise quote September's weekday all year.
      final slot = order.scheduleSlotOn(iso);
      final byTime = <String, List<OrderTicketSummary>>{};
      for (final l in lessons) {
        byTime.putIfAbsent('${l.startTime ?? ''}|${l.endTime ?? ''}', () => [])
            .add(l);
      }
      for (final group in byTime.values) {
        final own = _clock(group.first.startTime);
        // Taken as a PAIR: a seat that knows its own start must not borrow the
        // timetable's end, which may belong to a different slot entirely.
        final start = own ?? _clock(slot?.startTime);
        final end =
            own != null ? _clock(group.first.endTime) : _clock(slot?.endTime);
        due.add(DayBooking(
          order: order,
          lessons: group,
          date: iso,
          startTime: start,
          endTime: end,
        ));
      }
    }
    due.sort(_byClock);
    return due;
  }

  /// Today's visits, soonest first.
  static List<DayBooking> dueToday(Iterable<UserOrder> orders, {DateTime? now}) =>
      dueOn(orders, now ?? DateTime.now());

  /// [bookings] with the ones already over left out — the shelf as it should
  /// read at [now]. Empty by the end of the day, which is what collapses the
  /// section.
  static List<DayBooking> stillToCome(
    Iterable<DayBooking> bookings,
    DateTime now,
  ) =>
      bookings.where((b) => !b.hasEndedBy(now)).toList();

  /// Earliest first; an entry with no clock sorts after every timed one, and
  /// ties break on the activity name so the order never wobbles between
  /// builds.
  static int _byClock(DayBooking a, DayBooking b) {
    final sa = a.startMinutes;
    final sb = b.startMinutes;
    if (sa != sb) {
      if (sa == null) return 1;
      if (sb == null) return -1;
      return sa.compareTo(sb);
    }
    return (a.order.activityName ?? '').compareTo(b.order.activityName ?? '');
  }

  /// A wire time normalised to `HH:mm`, or null when it isn't one.
  ///
  /// The backend writes these as plain clock strings (`9:00`, `09:00`), so the
  /// match is anchored at the start and zero-padded — an unparseable or
  /// out-of-range value becomes "no time" rather than a row that sorts into
  /// the wrong place.
  static String? _clock(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value);
    if (match == null) return null;
    final h = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    if (h > 23 || m > 59) return null;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static int? _minutesOfClock(String? hhmm) {
    if (hhmm == null) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  static int _minutesOfDay(DateTime now) => now.hour * 60 + now.minute;
}

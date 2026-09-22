import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart'
    show ScheduleSlot;
import 'package:lumi_pass/data/api_model/order/course_purchase.dart';
import 'package:lumi_pass/common/utils/image_url.dart';

/// Plain Dart models for the user-facing orders API.
///
/// An [UserOrder] = one transaction (one Paycom checkout) that may contain
/// multiple seats. An [OrderTicket] = one seat inside that order (what the
/// backend calls a Booking). Tickets only carry a `ticketNo` once the order
/// flips to PAID.

class UserOrder {
  final String id;
  final String status; // pending | paid | canceled

  /// Which rail the buyer paid on: payme | click | uzum | paylov | card, or
  /// `paycom` for the direct Payme flow. Null on an order that was never
  /// charged (free) or predates the field.
  final String? paymentProvider;
  final num totalAmount;
  final num paidAmount;
  /// Original subtotal before any coupon/promocode discount. Equals
  /// [totalAmount] when no discount was applied.
  final num subtotalAmount;
  /// Amount saved via coupon or promocode. 0 when no discount was applied.
  final num discountAmount;
  final String? activityId;
  final String? activityName;
  final String? activityImage;
  final num? activityPrice;
  final List<OrderLineItem> items;
  /// Lightweight ticket summary returned by the orders list endpoint —
  /// enough to render times / ticket numbers on the card without a
  /// follow-up detail fetch.
  final List<OrderTicketSummary> ticketSummaries;
  final String? createdAt;
  final String? updatedAt;

  /// The promocode applied to this order, if any. Null when the discount came
  /// from a coupon plan (or when there was no discount).
  final String? promocodeCode;

  /// What this order bought: a trial lesson, a whole course, or (the common
  /// case) a normal activity booking.
  ///
  /// The detail endpoint returns the whole order document, so this has always
  /// been on the wire — the app simply never read it, and a course booking was
  /// indistinguishable from a class one on screen.
  final CoursePurchase coursePurchase;

  /// Which sub-course, when the course is sold as sub-courses.
  final String? subcourseName;

  /// When the enrolment starts (YYYY-MM-DD), for a whole-course purchase.
  final String? startsAt;

  /// Part of [totalAmount] settled from the cashback wallet, if any. A payment
  /// METHOD rather than a discount — the order still cost [totalAmount].
  final num walletAmount;

  /// Where it was booked — the activity's branch title. Null when the payload
  /// didn't populate one, which is every order fetched from a server older
  /// than the branch populate on the list endpoint.
  final String? branchName;

  /// The activity's recurring weekly schedule, carried only so a booking that
  /// recorded no time of its own can still show one. See [displayTimeRange].
  final List<ScheduleSlot> activitySchedule;

  bool get isCourseOrder => coursePurchase.isCourse;
  bool get isWholeCourse => coursePurchase == CoursePurchase.full;
  bool get isTrialLesson => coursePurchase == CoursePurchase.trial;

  /// True when part of this order was paid out of the wallet.
  bool get hasWalletPayment => walletAmount > 0;

  /// Every session this order booked, earliest first.
  ///
  /// Sorted here rather than trusted: the dates are ISO `YYYY-MM-DD`, which
  /// sorts correctly as text, and the endpoints make no promise about order.
  List<String> get _sessionDates {
    final dates = ticketSummaries
        .map((t) => t.ticketDate ?? '')
        .where((d) => d.isNotEmpty)
        .toList()
      ..sort();
    return dates;
  }

  /// When what was bought begins.
  ///
  /// The enrolment's own start date when the backend recorded one — it may
  /// precede the first lesson — otherwise the first session booked, which is
  /// the only answer an order written before that field has.
  String? get startDate {
    if (startsAt?.isNotEmpty ?? false) return startsAt;
    final dates = _sessionDates;
    return dates.isEmpty ? null : dates.first;
  }

  /// When it ends: the last session booked. Null when nothing is dated yet.
  String? get endDate {
    final dates = _sessionDates;
    return dates.isEmpty ? null : dates.last;
  }

  /// True when this order runs over more than one day — a course, or a class
  /// booked for several sessions. Such an order has a span to state; a
  /// single-session one just has a date and a time.
  bool get spansDates {
    final start = startDate;
    final end = endDate;
    return start != null && end != null && start != end;
  }

  /// `DateTime.weekday` (1 = Monday) indexed onto the wire's day names. The
  /// backend has been written both ways — the console writes `monday`, older
  /// seeds wrote `mon` — so the match is on the first three letters.
  static const _weekdayKeys = [
    'mon',
    'tue',
    'wed',
    'thu',
    'fri',
    'sat',
    'sun',
  ];

  /// The time the buyer actually picked, from the first ticket that carries
  /// one. Null when no ticket recorded a time.
  String? get _bookedTimeRange {
    for (final t in ticketSummaries) {
      final s = t.startTime ?? '';
      if (s.isEmpty) continue;
      final e = t.endTime ?? '';
      return e.isEmpty ? s : '$s - $e';
    }
    return null;
  }

  /// The activity's own scheduled time for the weekday this booking falls on,
  /// falling back to its first entry — a schedule that names one time for the
  /// week answers correctly either way, and a date we cannot parse should not
  /// cost the row entirely.
  String? get _scheduledTimeRange {
    if (activitySchedule.isEmpty) return null;
    ScheduleSlot? match;
    final iso = startDate;
    if (iso != null && iso.isNotEmpty) {
      try {
        final key = _weekdayKeys[DateTime.parse(iso).weekday - 1];
        for (final slot in activitySchedule) {
          final day = slot.day.trim().toLowerCase();
          if (day.length >= 3 && day.substring(0, 3) == key) {
            match = slot;
            break;
          }
        }
      } catch (_) {
        // Unparseable date — fall through to the first entry.
      }
    }
    final slot = match ?? activitySchedule.first;
    if (slot.startTime.isEmpty) return null;
    return slot.endTime.isEmpty
        ? slot.startTime
        : '${slot.startTime} - ${slot.endTime}';
  }

  /// The clock to put on this booking.
  ///
  /// What the buyer picked wins. A course enrolment picks nothing — and
  /// neither does a class booked off its recurring schedule — so rather than
  /// show a date with no time beside it, the activity's own timetable answers.
  /// Null only when neither knows, and the row is then left out.
  String? get displayTimeRange => _bookedTimeRange ?? _scheduledTimeRange;

  /// Today as `YYYY-MM-DD`, the shape every ticket date arrives in — string
  /// comparison is then the same thing as date comparison, with no parsing.
  static String get _todayKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}'
        '-${now.day.toString().padLeft(2, '0')}';
  }

  /// The lessons this order actually bought — dated, and not called off.
  Iterable<OrderTicketSummary> get _lessons => ticketSummaries.where((t) {
        final d = t.ticketDate;
        if (d == null || d.isEmpty) return false;
        return t.status.toLowerCase() != 'canceled';
      });

  /// How many lessons this order bought. Every seat on a course enrolment is
  /// one dated lesson, so the lesson count IS the ticket count.
  int get totalLessons => _lessons.length;

  /// Lessons already behind the buyer: attended, or simply dated before today.
  ///
  /// A lesson nobody marked attendance on still happened — counting only
  /// `attended` would stall the progress of any course whose partner does not
  /// take the register, which is most of them.
  int get lessonsDone {
    final today = _todayKey;
    return _lessons.where((t) {
      if (t.attendanceStatus == 'attended') return true;
      return t.ticketDate!.compareTo(today) < 0;
    }).length;
  }

  /// Whether "lesson 8 of 24" is a true and useful thing to say about this
  /// order.
  ///
  /// Only a live, whole-course enrolment running to more than one lesson has
  /// progress to report. A trial is a single visit — "1 / 1" under a full bar
  /// reads as a finished course — and a cancelled order has no progress at
  /// all, however many of its dates have since passed.
  bool get hasLessonProgress =>
      isWholeCourse && !isCanceled && totalLessons > 1;

  /// The soonest lesson still to come — today counts, it has not happened yet.
  /// Null once the course has run out of dated lessons.
  OrderTicketSummary? get nextLesson {
    final today = _todayKey;
    OrderTicketSummary? soonest;
    for (final t in ticketSummaries) {
      final d = t.ticketDate;
      if (d == null || d.isEmpty || d.compareTo(today) < 0) continue;
      final best = soonest?.ticketDate;
      if (best == null || d.compareTo(best) < 0) soonest = t;
    }
    return soonest;
  }

  /// Whole days from today until the last lesson. Negative once it is past,
  /// null when nothing is dated.
  int? get daysUntilEnd {
    final end = endDate;
    if (end == null || end.isEmpty) return null;
    try {
      final last = DateTime.parse(end);
      final now = DateTime.now();
      return DateTime(last.year, last.month, last.day)
          .difference(DateTime(now.year, now.month, now.day))
          .inDays;
    } catch (_) {
      return null;
    }
  }

  /// True when a paid course enrolment is within [days] of its last lesson —
  /// the window in which the buyer has to decide whether to carry on, and the
  /// only moment a renewal prompt is worth showing.
  bool endsWithin(int days) {
    if (!isWholeCourse || !isPaid || isCanceled) return false;
    final left = daysUntilEnd;
    return left != null && left >= 0 && left <= days;
  }

  /// Whether the seats on this order name an age bracket someone chose.
  ///
  /// A course order carries none (its items are empty, and its bookings are
  /// stamped 0–99 for "whoever the course admits"), so there is nothing to
  /// show and the row is left out rather than printed blank.
  bool get hasAgeBracket {
    if (items.isEmpty) return false;
    final it = items.first;
    return !(it.ageFrom == 0 && it.ageTo >= 99);
  }

  const UserOrder({
    required this.id,
    required this.status,
    this.paymentProvider,
    required this.totalAmount,
    required this.paidAmount,
    required this.subtotalAmount,
    required this.discountAmount,
    required this.activityId,
    required this.activityName,
    required this.activityImage,
    required this.activityPrice,
    required this.items,
    required this.ticketSummaries,
    required this.createdAt,
    required this.updatedAt,
    this.promocodeCode,
    this.coursePurchase = CoursePurchase.none,
    this.subcourseName,
    this.startsAt,
    this.walletAmount = 0,
    this.branchName,
    this.activitySchedule = const [],
  });

  /// True when a coupon or promocode discount was applied to this order.
  bool get hasDiscount => discountAmount > 0;

  /// True when the discount came from a promocode (vs an auto coupon plan).
  bool get isPromocodeDiscount =>
      promocodeCode != null && promocodeCode!.isNotEmpty;

  int get totalSeats => items.fold<int>(0, (sum, it) => sum + it.count);
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isCanceled => status.toLowerCase() == 'canceled';
  /// True when this order is for an activity booking (not a subscription
  /// purchase). Subscription orders have a null activityId and must not
  /// appear in the bookings list.
  bool get isActivityOrder => activityId != null && activityId!.isNotEmpty;

  /// Semantic display status: 'active' | 'visited' | 'missed' | 'cancelled' | 'pending'
  String get effectiveDisplayStatus {
    if (isCanceled) return 'cancelled';
    if (isPending) return 'pending';
    if (ticketSummaries.isEmpty) return 'active';
    final anyAttended =
        ticketSummaries.any((t) => t.attendanceStatus == 'attended');
    if (anyAttended) return 'visited';
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final allPast = ticketSummaries.every((t) {
      final d = t.ticketDate;
      if (d == null || d.isEmpty) return false;
      return d.compareTo(todayKey) < 0;
    });
    return allPast ? 'missed' : 'active';
  }

  /// True when any ticket date is today or in the future.
  bool get hasFutureTicket {
    if (ticketSummaries.isEmpty) return isPaid;
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return ticketSummaries.any((t) {
      final d = t.ticketDate;
      if (d == null || d.isEmpty) return false;
      return d.compareTo(todayKey) >= 0;
    });
  }

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    final activity = json['activity_id'];
    Map<String, dynamic>? activityMap;
    String? activityId;
    if (activity is Map) {
      activityMap = Map<String, dynamic>.from(activity);
      activityId = activityMap['_id']?.toString() ?? activityMap['id']?.toString();
    } else if (activity != null) {
      activityId = activity.toString();
    }

    final itemsRaw = (json['items'] as List?) ?? const [];
    final ticketsRaw = (json['tickets'] as List?) ?? const [];
    final totalAmt = (json['total_amount'] as num?) ?? 0;
    final subtotalAmt = (json['subtotal_amount'] as num?) ?? totalAmt;
    return UserOrder(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      paymentProvider: (json['paylov_provider'] ??
              (json['paycom_transaction_id'] != null ? 'paycom' : null))
          ?.toString(),
      totalAmount: totalAmt,
      paidAmount: (json['paid_amount'] as num?) ?? 0,
      subtotalAmount: subtotalAmt,
      discountAmount: (json['discount_amount'] as num?) ?? 0,
      promocodeCode: (json['promocode_code']?.toString().isNotEmpty ?? false)
          ? json['promocode_code'].toString()
          : null,
      coursePurchase: CoursePurchase.fromKey(json['course_purchase']?.toString()),
      subcourseName: (json['subcourse_name']?.toString().isNotEmpty ?? false)
          ? json['subcourse_name'].toString()
          : null,
      startsAt: json['starts_at']?.toString().split('T').first,
      walletAmount: (json['wallet_amount'] as num?) ?? 0,
      activityId: activityId,
      activityName: _readLocalized(activityMap?['name']),
      activityImage: sanitizeImageUrl(activityMap?['image']?.toString()),
      activityPrice: activityMap?['price'] as num?,
      branchName: _readBranchTitle(activityMap?['branch_id']),
      activitySchedule: ((activityMap?['schedule'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => ScheduleSlot.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      items: itemsRaw
          .whereType<Map>()
          .map((e) => OrderLineItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      ticketSummaries: ticketsRaw
          .whereType<Map>()
          .map((e) =>
              OrderTicketSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

/// The branch title out of a populated `branch_id`. An unpopulated one is a
/// bare id string, which names nothing — treat it as absent.
String? _readBranchTitle(dynamic branch) {
  if (branch is! Map) return null;
  final title = branch['title']?.toString();
  return (title == null || title.isEmpty) ? null : title;
}

/// Slim per-ticket payload included on the orders list endpoint so the card
/// can render booked times / ticket numbers inline.
class OrderTicketSummary {
  final String? ticketNo;
  final String? ticketDate;
  final String? startTime;
  final String? endTime;
  final String status;
  final String? attendanceStatus; // 'attended' | 'not_attended' | null

  const OrderTicketSummary({
    required this.ticketNo,
    required this.ticketDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.attendanceStatus,
  });

  factory OrderTicketSummary.fromJson(Map<String, dynamic> json) {
    return OrderTicketSummary(
      ticketNo: json['ticket_no']?.toString(),
      ticketDate: json['ticket_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      attendanceStatus: json['attendance_status']?.toString(),
    );
  }
}

class OrderLineItem {
  final int ageFrom;
  final int ageTo;
  final num unitPrice;
  final int count;

  const OrderLineItem({
    required this.ageFrom,
    required this.ageTo,
    required this.unitPrice,
    required this.count,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      ageFrom: (json['age_from'] as num?)?.toInt() ?? 0,
      ageTo: (json['age_to'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?) ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderTicket {
  final String id;
  final String? ticketNo;
  final String ticketDate;
  final String? startTime;
  final String? endTime;
  final int ageFrom;
  final int ageTo;
  final num price;

  /// The duration tier this seat was bought at, in minutes.
  ///
  /// Null means either the UNLIMITED tier or a booking written before the
  /// backend recorded it — [hasDurationTier] separates the two. It is what
  /// explains a price: the same bracket at 60 minutes and "as long as you
  /// like" are two different amounts, and without this the ticket showed the
  /// amount and not the reason.
  final int? duration;

  /// Whether this booking knows which duration tier it bought at all.
  final bool hasDurationTier;

  final String status; // pending | confirmed | canceled
  final String? createdAt;

  const OrderTicket({
    required this.id,
    required this.ticketNo,
    required this.ticketDate,
    required this.startTime,
    required this.endTime,
    required this.ageFrom,
    required this.ageTo,
    required this.price,
    required this.status,
    required this.createdAt,
    this.duration,
    this.hasDurationTier = false,
  });

  bool get isConfirmed => status.toLowerCase() == 'confirmed';

  /// True when this seat was bought on the unlimited tier.
  bool get isUnlimitedDuration => hasDurationTier && duration == null;

  factory OrderTicket.fromJson(Map<String, dynamic> json) {
    return OrderTicket(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      ticketNo: json['ticket_no']?.toString(),
      ticketDate: json['ticket_date']?.toString() ?? '',
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      ageFrom: (json['age_from'] as num?)?.toInt() ?? 0,
      ageTo: (json['age_to'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?) ?? 0,
      // `duration: null` is a REAL tier (unlimited), so the key being present
      // is what says the tier is known — not the value being non-null.
      duration: (json['duration'] as num?)?.toInt(),
      hasDurationTier: json.containsKey('duration'),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class OrderDetail {
  final UserOrder order;
  final List<OrderTicket> tickets;
  final String? checkoutUrl;
  /// OFD/Soliq fiscal receipt URL for a PAID order — the `fiscal_data.qr_code_url`
  /// Payme returns once the payment is fiscalized (e.g. `https://ofd.soliq.uz/check?...`).
  /// Null while the order is unpaid or the backend hasn't fiscalized it yet.
  final String? receiptUrl;

  /// Hours before the activity start time during which this order can still be
  /// cancelled (with automatic refund). Backend-configured; defaults to 12.
  final int cancellationWindowHours;

  const OrderDetail({
    required this.order,
    required this.tickets,
    required this.checkoutUrl,
    this.receiptUrl,
    this.cancellationWindowHours = 12,
  });

  /// True when a fiscal receipt is available to show for this (paid) order.
  bool get hasReceipt =>
      order.isPaid && receiptUrl != null && receiptUrl!.isNotEmpty;

  String? get earliestTicketDate {
    if (tickets.isEmpty) return null;
    final dates = tickets
        .map((t) => t.ticketDate)
        .where((d) => d.isNotEmpty)
        .toList()
      ..sort();
    return dates.firstOrNull;
  }

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final orderRaw = json['order'] is Map
        ? Map<String, dynamic>.from(json['order'] as Map)
        : <String, dynamic>{};
    final bookingsRaw = (json['bookings'] as List?) ?? const [];

    // The detail endpoint hangs the seats off the payload root as `bookings`,
    // not off the order itself, so the order arrives with no `tickets` — and
    // everything derived from them falls back to its no-ticket default:
    // [UserOrder.effectiveDisplayStatus] returns 'active'. A past, unattended
    // booking therefore read "active" on the detail screen while the list card
    // (whose endpoint does put `tickets` on the order) correctly said "missed".
    // Same wire shape either way, so feed them in.
    final orderRawWithTickets =
        (orderRaw['tickets'] as List?)?.isNotEmpty == true || bookingsRaw.isEmpty
            ? orderRaw
            : {...orderRaw, 'tickets': bookingsRaw};

    return OrderDetail(
      order: UserOrder.fromJson(orderRawWithTickets),
      tickets: bookingsRaw
          .whereType<Map>()
          .map((e) => OrderTicket.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      checkoutUrl: json['checkout_url']?.toString(),
      receiptUrl: _readReceiptUrl(json, orderRaw),
      cancellationWindowHours:
          (json['cancellation_window_hours'] as num?)?.toInt() ?? 12,
    );
  }
}

/// Pulls the OFD/Soliq fiscal receipt URL out of the order-detail payload.
/// The backend may attach it at the detail root or on the order object, under
/// any of a few field names — read defensively so the feature lights up
/// whichever shape the backend ships.
String? _readReceiptUrl(Map<String, dynamic> detail, Map<String, dynamic> order) {
  const keys = ['receipt_url', 'ofd_url', 'fiscal_url', 'qr_code_url', 'check_url'];
  for (final source in [detail, order]) {
    for (final key in keys) {
      final v = source[key];
      if (v is String && v.isNotEmpty) return v;
    }
  }
  return null;
}

String? _readLocalized(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    final lang = currentLang;
    // Current lang first, then fallback chain
    for (final key in [lang, 'ru', 'en', 'uz']) {
      final v = value[key];
      if (v is String && v.isNotEmpty) return v;
    }
    final first = value.values
        .whereType<String>()
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    return first.isEmpty ? null : first;
  }
  return value.toString();
}

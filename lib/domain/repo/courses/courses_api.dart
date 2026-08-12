import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:lumi_pass/data/api_model/order/order_model.dart';

/// What a user holds on one course (or one level of it).
enum CourseEnrollmentStatus {
  none('none'),
  trial('trial'),
  full('full'),
  unknown('unknown');

  const CourseEnrollmentStatus(this.key);

  final String key;

  static CourseEnrollmentStatus fromKey(String? key) {
    for (final v in values) {
      if (v.key == key) return v;
    }
    return unknown;
  }

  bool get isEnrolled => this == CourseEnrollmentStatus.full;
  bool get hasTrial => this == CourseEnrollmentStatus.trial;
}

/// What is being bought: the trial lessons, or the whole thing.
enum CoursePurchaseOption {
  trial('trial'),
  full('full');

  const CoursePurchaseOption(this.key);

  final String key;
}

/// Why the server refuses a purchase. The server decides — the app only
/// explains, so a button can never offer something checkout will reject.
enum CourseBlockedReason {
  /// The admin hasn't finished setting this course up (no price, no dates).
  notConfigured('not_configured'),

  /// Every lesson is in the past.
  ended('ended'),

  /// The cohort is full.
  soldOut('sold_out'),

  /// The trial has already been bought.
  alreadyTrial('already_trial'),

  /// Already enrolled in this course/level.
  alreadyEnrolled('already_enrolled'),

  /// This course only takes children who have sat the trial lessons.
  trialRequired('trial_required'),

  /// The trial is bought, but the first lesson hasn't come round yet.
  trialPending('trial_pending'),

  /// A trial lesson is already bought and hasn't happened yet — the next
  /// trial lesson can't be bought until it does. Trials are sold one at a
  /// time on purpose: this is what enforces that.
  trialInProgress('trial_in_progress'),

  /// A reason this build doesn't know about — show a generic message.
  unknown('unknown');

  const CourseBlockedReason(this.key);

  final String key;

  /// `null` in means "not blocked", so `null` out. Anything unrecognised
  /// degrades to [unknown] rather than throwing.
  static CourseBlockedReason? fromKey(String? key) {
    if (key == null) return null;
    for (final v in values) {
      if (v.key == key) return v;
    }
    return unknown;
  }

  /// Translation key for the message shown under a disabled buy button.
  String get messageKey {
    switch (this) {
      case CourseBlockedReason.notConfigured:
        return 'course_blocked_not_configured';
      case CourseBlockedReason.ended:
        return 'course_blocked_ended';
      case CourseBlockedReason.soldOut:
        return 'course_full_no_seats';
      case CourseBlockedReason.alreadyTrial:
        return 'course_trial_bought';
      case CourseBlockedReason.alreadyEnrolled:
        return 'course_already_enrolled_short';
      case CourseBlockedReason.trialRequired:
        return 'course_blocked_trial_required';
      case CourseBlockedReason.trialPending:
        return 'course_blocked_trial_pending';
      case CourseBlockedReason.trialInProgress:
        return 'course_blocked_trial_in_progress';
      case CourseBlockedReason.unknown:
        return 'course_blocked_unavailable';
    }
  }
}

/// One dated lesson of a course.
class CourseLesson {
  const CourseLesson({
    required this.lessonNo,
    required this.date,
    this.startTime,
    this.endTime,
    this.isTrial = false,
    this.price,
    this.purchased = false,
    this.isMandatory = false,
  });

  final int lessonNo;
  final String date; // YYYY-MM-DD
  final String? startTime;
  final String? endTime;
  final bool isTrial;

  /// Trial lessons only: each is priced separately, and the screen shows what
  /// each one costs. Null on the course's own lessons — those are sold as one
  /// package, so an individual lesson has no price of its own.
  final num? price;

  /// Trial lessons only: the user already bought this one. Trials are sold
  /// individually, so this is per lesson rather than per course.
  final bool purchased;

  /// Trial lessons only: this one must be bought, and must have taken place,
  /// before the whole course can be bought. Any of them may be marked.
  final bool isMandatory;

  /// Still on sale to this user: ahead of them, and not already theirs.
  bool get isAvailable => !purchased && !hasPassed;

  /// True once the lesson is in the past. Trials that have already run are
  /// still listed (so the dates read as a set) but are not on sale.
  bool get hasPassed {
    final d = DateTime.tryParse(date);
    if (d == null) return false;
    final now = DateTime.now();
    return d.isBefore(DateTime(now.year, now.month, now.day));
  }

  factory CourseLesson.fromJson(Map<String, dynamic> j, {num? price}) =>
      CourseLesson(
        lessonNo: (j['lesson_no'] as num?)?.toInt() ?? 0,
        date: j['date'] as String? ?? '',
        startTime: j['start_time'] as String?,
        endTime: j['end_time'] as String?,
        isTrial: j['is_trial'] as bool? ?? false,
        // The server prices each trial lesson on the lesson itself; the
        // separate `prices` list is the fallback for older responses.
        price: (j['price'] as num?) ?? price,
        purchased: j['purchased'] as bool? ?? false,
        isMandatory: j['is_mandatory'] as bool? ?? false,
      );
}

/// What the user currently holds.
class CourseEnrollment {
  const CourseEnrollment({
    required this.status,
    required this.trialLessonsBooked,
    required this.upcomingLessons,
    required this.trialStarted,
    this.trialFirstDate,
    this.trialLastDate,
  });

  final CourseEnrollmentStatus status;
  final int trialLessonsBooked;
  final int upcomingLessons;

  /// The user's own first trial lesson (YYYY-MM-DD), null if they hold none.
  /// Their first, not the course's — someone who buys the trial late only gets
  /// the lessons that were still ahead.
  final String? trialFirstDate;

  /// The user's own LAST (most recently booked) trial lesson, null if they
  /// hold none. Trials are sold one at a time — this is what "buy the next
  /// trial only after this one" is checked against, as opposed to
  /// [trialFirstDate].
  final String? trialLastDate;

  /// True once that lesson has come round. What a mandatory trial is measured
  /// against: the centre has to have seen the child, and paying isn't that.
  final bool trialStarted;

  bool get isEnrolled => status.isEnrolled;
  bool get hasTrial => status.hasTrial;

  factory CourseEnrollment.fromJson(Map<String, dynamic> j) => CourseEnrollment(
        status: CourseEnrollmentStatus.fromKey(j['status'] as String?),
        trialLessonsBooked: (j['trial_lessons_booked'] as num?)?.toInt() ?? 0,
        upcomingLessons: (j['upcoming_lessons'] as num?)?.toInt() ?? 0,
        trialFirstDate: j['trial_first_date'] as String?,
        trialLastDate: j['trial_last_date'] as String?,
        trialStarted: j['trial_started'] as bool? ?? false,
      );
}

/// One age bracket a FLAT course (no levels) can be bought at.
///
/// Only meaningful on the flat side: a level has its own single price, not
/// tiers — the server sends an empty list there. The server also sorts these
/// cheapest-first, which is what checkout defaults to when no tier is named.
class CourseAgeTier {
  const CourseAgeTier({
    required this.ageFrom,
    required this.ageTo,
    required this.price,
  });

  final int ageFrom;

  /// null = open-ended ("Adults").
  final int? ageTo;
  final num price;

  String get rangeLabel => ageTo == null ? '$ageFrom+' : '$ageFrom-$ageTo';

  factory CourseAgeTier.fromJson(Map<String, dynamic> j) => CourseAgeTier(
        ageFrom: (j['age_from'] as num?)?.toInt() ?? 0,
        ageTo: (j['age_to'] as num?)?.toInt(),
        price: (j['price'] as num?) ?? 0,
      );
}

/// One purchasable thing: a LEVEL of a course ("Beginner"), or — when [id] is
/// null — a course that isn't sold as levels.
///
/// Both shapes come off the wire with identical fields, so the same widget
/// renders either one. Two independent calendars, which is the shape of the
/// product:
///   [trialLessons]  the lessons you can try, each priced separately.
///   [courseLessons] the whole thing.
class CourseLevel {
  const CourseLevel({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.trialLessons,
    required this.trialPrice,
    required this.trialLessonsLeft,
    required this.courseLessons,
    required this.lessonsLeft,
    required this.coursePrice,
    required this.canBuyTrial,
    required this.canBuyFull,
    this.trialBlockedReason,
    this.blockedReason,
    this.seats,
    this.seatsLeft,
    this.enrollment,
    this.upsellRecommended = false,
    this.priceMax,
    this.hasMultiplePriceTiers = false,
    this.ageTiers = const [],
    this.trialNextDates = const [],
    this.trialNextPrice,
    this.trialNextMandatory = false,
  });

  /// null for a course that isn't sold as levels.
  final String? id;
  final String? name;
  final String? description;
  final int order;

  /// The dated trial lessons, each carrying its own [CourseLesson.price].
  final List<CourseLesson> trialLessons;

  /// What the whole trial set costs — the sum of the lesson prices.
  final num trialPrice;

  /// Trials still ahead. Fewer than [trialLessons] once some have run.
  final int trialLessonsLeft;

  /// Candidate dates (YYYY-MM-DD) for the NEXT trial lesson — a broad range
  /// straight off the class's own schedule, not the narrow one-date-per-slot
  /// list [trialLessons] carries. This is what the date picker offers; every
  /// date here fills the same ladder slot, so they all share [trialNextPrice]
  /// / [trialNextMandatory]. Empty once nothing is left to sell, or while
  /// [trialBlockedReason] blocks a purchase (e.g. a held trial hasn't come
  /// round yet).
  final List<String> trialNextDates;

  /// Price of the slot [trialNextDates] would fill. Null once none is left.
  final num? trialNextPrice;

  /// Whether that slot must be taken before the course can be bought.
  final bool trialNextMandatory;

  /// The trial lessons that must be taken before the course can be bought.
  /// Stated on the page rather than sprung at checkout — it changes what a
  /// parent has to buy first.
  List<CourseLesson> get mandatoryTrialLessons =>
      trialLessons.where((l) => l.isMandatory).toList();

  bool get hasMandatoryTrial => mandatoryTrialLessons.isNotEmpty;

  final List<CourseLesson> courseLessons;

  /// Lessons still ahead. Enrolling mid-course buys only these — at full price.
  final int lessonsLeft;

  /// The default/cheapest price — what checkout charges when no age tier is
  /// named. See [ageTiers] for the full picker when [hasMultiplePriceTiers].
  final num coursePrice;

  /// The most expensive tier's price. Only set when [hasMultiplePriceTiers].
  final num? priceMax;

  /// True on a flat course priced by more than one age tier — [coursePrice]
  /// should then read "from X", and the age-tier picker should show.
  final bool hasMultiplePriceTiers;

  /// The age brackets a FLAT course can be bought at, cheapest first. Empty
  /// for a level (a level has its own single price, not tiers).
  final List<CourseAgeTier> ageTiers;

  /// Cohort size. null = unlimited.
  final int? seats;
  final int? seatsLeft;

  /// Null when the caller is not signed in.
  final CourseEnrollment? enrollment;

  /// "After the trial, always advise the whole course."
  final bool upsellRecommended;

  /// Decided by the server, so the buttons and the checkout can never disagree.
  final bool canBuyTrial;
  final bool canBuyFull;
  final CourseBlockedReason? trialBlockedReason;
  final CourseBlockedReason? blockedReason;

  bool get isFull => seatsLeft != null && seatsLeft! <= 0;

  /// The trial lessons still on sale to this user — upcoming, not already
  /// bought. Trials are sold individually, so this is what the picker offers.
  List<CourseLesson> get availableTrialLessons =>
      trialLessons.where((l) => l.isAvailable).toList();

  /// True once every lesson has passed.
  bool get hasEnded => blockedReason == CourseBlockedReason.ended;

  factory CourseLevel.fromJson(Map<String, dynamic> j) {
    final trial = Map<String, dynamic>.from(j['trial'] as Map? ?? {});
    final course = Map<String, dynamic>.from(j['course'] as Map? ?? {});
    final enrol = j['enrollment'];
    final upsell = j['upsell'];
    // Each trial lesson carries its own price and its own mandatory flag —
    // the server stamps both onto the lesson.
    final trialLessons = ((trial['lessons'] as List?) ?? [])
        .map((e) => CourseLesson.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return CourseLevel(
      id: j['id'] as String?,
      name: j['name'] as String?,
      description: j['description'] as String?,
      order: (j['order'] as num?)?.toInt() ?? 0,
      trialLessons: trialLessons,
      trialPrice: (trial['total_price'] as num?) ?? 0,
      trialLessonsLeft:
          (trial['lessons_left'] as num?)?.toInt() ?? trialLessons.length,
      trialNextDates:
          ((trial['next_dates'] as List?) ?? []).whereType<String>().toList(),
      trialNextPrice: trial['next_price'] as num?,
      trialNextMandatory: trial['next_mandatory'] as bool? ?? false,
      courseLessons: ((course['lessons'] as List?) ?? [])
          .map(
              (e) => CourseLesson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      lessonsLeft: (course['lessons_left'] as num?)?.toInt() ??
          ((course['lessons'] as List?) ?? []).length,
      coursePrice: (course['price'] as num?) ?? 0,
      priceMax: course['price_max'] as num?,
      hasMultiplePriceTiers:
          course['has_multiple_price_tiers'] as bool? ?? false,
      ageTiers: ((course['age_tiers'] as List?) ?? [])
          .map((e) =>
              CourseAgeTier.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      seats: (course['seats'] as num?)?.toInt(),
      seatsLeft: (course['seats_left'] as num?)?.toInt(),
      enrollment: enrol is Map
          ? CourseEnrollment.fromJson(Map<String, dynamic>.from(enrol))
          : null,
      upsellRecommended:
          upsell is Map ? (upsell['recommended'] as bool? ?? false) : false,
      canBuyTrial: j['can_buy_trial'] as bool? ?? false,
      canBuyFull: j['can_buy_full'] as bool? ?? false,
      trialBlockedReason:
          CourseBlockedReason.fromKey(j['trial_blocked_reason'] as String?),
      blockedReason:
          CourseBlockedReason.fromKey(j['blocked_reason'] as String?),
    );
  }
}

/// A course, as the detail screen needs it.
///
/// Two shapes, and [hasLevels] decides which the screen renders:
///   LEVELS — "English" is a container; Beginner / Elementary / … are what you
///            buy, each with its own prices, calendars and cohort.
///   FLAT   — one set of prices, exposed as [flat].
///
/// [flat] is always present: for a levelled course the server mirrors the level
/// a level-less client would buy into it, so nothing here can be null.
class CourseDetail {
  const CourseDetail({
    required this.activityId,
    required this.hasLevels,
    required this.levels,
    required this.flat,
    this.defaultLevelId,
  });

  final String activityId;
  final bool hasLevels;
  final List<CourseLevel> levels;
  final CourseLevel flat;

  /// The level a client that cannot choose one would buy.
  final String? defaultLevelId;

  factory CourseDetail.fromJson(Map<String, dynamic> j) {
    final levels = ((j['subcourses'] as List?) ?? [])
        .map((e) => CourseLevel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return CourseDetail(
      activityId: j['activity_id'] as String? ?? '',
      // Trust the server's flag rather than `levels.isNotEmpty`: a course whose
      // every level is retired reports false and falls back to the flat block.
      hasLevels: (j['has_subcourses'] as bool? ?? false) && levels.isNotEmpty,
      levels: levels,
      flat: CourseLevel.fromJson(j),
      defaultLevelId: j['default_subcourse_id'] as String?,
    );
  }
}

/// Courses.
///
/// A course is bought as a package — the trial lessons, or the whole course —
/// so it does NOT go through `orders/checkout` (which is per-session, priced by
/// age tier, on a single date). The payment result is the same [CheckoutResult]
/// though, so the existing Paycom / Paylov / saved-card flow is reused as-is.
@injectable
class CoursesApi {
  CoursesApi(this._dio);

  final Dio _dio;

  Future<CourseDetail> detail(String activityId, {String? lang}) async {
    final res = await _dio.get(
      'courses/$activityId',
      queryParameters: {if (lang != null) 'lang': lang},
    );
    return CourseDetail.fromJson(_unwrap(res.data));
  }

  /// [subcourseId] picks the level on a levelled course. Omitting it lets the
  /// server fall back to the cheapest level with seats left.
  ///
  /// [ageFrom]/[ageTo] pick which age tier to buy the WHOLE course at, for a
  /// flat course priced by more than one tier (`CourseLevel.ageTiers`).
  /// Omitting them buys the cheapest tier — same fallback [subcourseId] gets
  /// when omitted on a levelled course. Ignored for a trial purchase.
  ///
  /// [trialDates] picks which trial sessions to buy — they are sold one at a
  /// time, and by date rather than position because the offered set rolls
  /// forward. Omitting it buys every upcoming session not already held.
  ///
  /// [startsAt] (YYYY-MM-DD) is when a full enrolment is considered to
  /// start. Purely descriptive — nothing on the server selects lessons or
  /// prices by it yet. Omit and the server defaults it to the first lesson
  /// actually booked. No UI sets this today; the parameter exists so a
  /// future picker has somewhere to plug in without another server round of
  /// changes. Ignored for a trial purchase.
  Future<CheckoutResult> checkout({
    required String activityId,
    required CoursePurchaseOption option,
    String? subcourseId,
    int? ageFrom,
    int? ageTo,
    String? startsAt,
    List<String>? trialDates,
    /// How many places to buy, one per child. Full enrolments only — a trial
    /// is one child trying one lesson.
    int? quantity,
    /// Validated and capped server-side; the client never computes a discount.
    String? promocode,
    String? lang,
    String? returnUrl,
    String? paymentProvider,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
  }) async {
    final body = {
      'option': option.key,
      if (subcourseId != null && subcourseId.isNotEmpty)
        'subcourse_id': subcourseId,
      if (option == CoursePurchaseOption.full && ageFrom != null)
        'age_from': ageFrom,
      if (option == CoursePurchaseOption.full &&
          ageFrom != null &&
          ageTo != null)
        'age_to': ageTo,
      if (option == CoursePurchaseOption.full &&
          startsAt != null &&
          startsAt.isNotEmpty)
        'starts_at': startsAt,
      if (option == CoursePurchaseOption.trial &&
          trialDates != null &&
          trialDates.isNotEmpty)
        'trial_dates': trialDates,
      if (option == CoursePurchaseOption.full &&
          quantity != null &&
          quantity > 1)
        'quantity': quantity,
      if (promocode != null && promocode.trim().isNotEmpty)
        'promocode': promocode.trim(),
      if (lang != null) 'lang': lang,
      if (returnUrl != null) 'return_url': returnUrl,
      if (paymentProvider != null) 'payment_provider': paymentProvider,
      if (cardNumber != null && cardNumber.trim().isNotEmpty)
        'card_number': cardNumber.replaceAll(RegExp(r'\s'), ''),
      if (expireDate != null && expireDate.trim().isNotEmpty)
        'expire_date': expireDate.replaceAll(RegExp(r'[^0-9]'), ''),
      if (savedCardId != null && savedCardId.trim().isNotEmpty)
        'saved_card_id': savedCardId.trim(),
    };
    final res = await _dio.post('courses/$activityId/checkout', data: body);
    return CheckoutResult.fromJson(_unwrap(res.data));
  }

  Map<String, dynamic> _unwrap(dynamic raw) => raw is Map && raw['data'] is Map
      ? Map<String, dynamic>.from(raw['data'] as Map)
      : Map<String, dynamic>.from(raw as Map);
}

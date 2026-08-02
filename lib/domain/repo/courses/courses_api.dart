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
  });

  final int lessonNo;
  final String date; // YYYY-MM-DD
  final String? startTime;
  final String? endTime;
  final bool isTrial;

  factory CourseLesson.fromJson(Map<String, dynamic> j) => CourseLesson(
        lessonNo: (j['lesson_no'] as num?)?.toInt() ?? 0,
        date: j['date'] as String? ?? '',
        startTime: j['start_time'] as String?,
        endTime: j['end_time'] as String?,
        isTrial: j['is_trial'] as bool? ?? false,
      );
}

/// What the user currently holds.
class CourseEnrollment {
  const CourseEnrollment({
    required this.status,
    required this.trialLessonsBooked,
    required this.upcomingLessons,
  });

  final CourseEnrollmentStatus status;
  final int trialLessonsBooked;
  final int upcomingLessons;

  bool get isEnrolled => status.isEnrolled;
  bool get hasTrial => status.hasTrial;

  factory CourseEnrollment.fromJson(Map<String, dynamic> j) => CourseEnrollment(
        status: CourseEnrollmentStatus.fromKey(j['status'] as String?),
        trialLessonsBooked: (j['trial_lessons_booked'] as num?)?.toInt() ?? 0,
        upcomingLessons: (j['upcoming_lessons'] as num?)?.toInt() ?? 0,
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
  });

  /// null for a course that isn't sold as levels.
  final String? id;
  final String? name;
  final String? description;
  final int order;

  final List<CourseLesson> trialLessons;
  final num trialPrice;

  final List<CourseLesson> courseLessons;

  /// Lessons still ahead. Enrolling mid-course buys only these — at full price.
  final int lessonsLeft;
  final num coursePrice;

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

  /// True once every lesson has passed.
  bool get hasEnded => blockedReason == CourseBlockedReason.ended;

  factory CourseLevel.fromJson(Map<String, dynamic> j) {
    final trial = Map<String, dynamic>.from(j['trial'] as Map? ?? {});
    final course = Map<String, dynamic>.from(j['course'] as Map? ?? {});
    final enrol = j['enrollment'];
    final upsell = j['upsell'];
    return CourseLevel(
      id: j['id'] as String?,
      name: j['name'] as String?,
      description: j['description'] as String?,
      order: (j['order'] as num?)?.toInt() ?? 0,
      trialLessons: ((trial['lessons'] as List?) ?? [])
          .map((e) => CourseLesson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      trialPrice: (trial['total_price'] as num?) ?? 0,
      courseLessons: ((course['lessons'] as List?) ?? [])
          .map((e) => CourseLesson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      lessonsLeft: (course['lessons_left'] as num?)?.toInt() ??
          ((course['lessons'] as List?) ?? []).length,
      coursePrice: (course['price'] as num?) ?? 0,
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
      blockedReason: CourseBlockedReason.fromKey(j['blocked_reason'] as String?),
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
  Future<CheckoutResult> checkout({
    required String activityId,
    required CoursePurchaseOption option,
    String? subcourseId,
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

  Map<String, dynamic> _unwrap(dynamic raw) =>
      raw is Map && raw['data'] is Map
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : Map<String, dynamic>.from(raw as Map);
}

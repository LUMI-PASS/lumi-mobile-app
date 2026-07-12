import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:lumi_pass/data/api_model/order/order_model.dart';

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

/// What the user currently holds on this course.
class CourseEnrollment {
  const CourseEnrollment({
    required this.status, // none | trial | full
    required this.trialLessonsBooked,
    required this.upcomingLessons,
  });

  final String status;
  final int trialLessonsBooked;
  final int upcomingLessons;

  bool get isEnrolled => status == 'full';
  bool get hasTrial => status == 'trial';

  factory CourseEnrollment.fromJson(Map<String, dynamic> j) => CourseEnrollment(
        status: j['status'] as String? ?? 'none',
        trialLessonsBooked: (j['trial_lessons_booked'] as num?)?.toInt() ?? 0,
        upcomingLessons: (j['upcoming_lessons'] as num?)?.toInt() ?? 0,
      );
}

/// A course, as the detail screen needs it.
///
/// Two independent calendars — that is the shape of the product:
///   [trialLessons]  the 3 lessons you can try, each priced separately.
///   [courseLessons] the whole course.
class CourseDetail {
  const CourseDetail({
    required this.activityId,
    required this.trialLessons,
    required this.trialPrice,
    required this.courseLessons,
    required this.coursePrice,
    this.seats,
    this.seatsLeft,
    this.enrollment,
    this.upsellRecommended = false,
  });

  final String activityId;

  final List<CourseLesson> trialLessons;
  final num trialPrice;

  final List<CourseLesson> courseLessons;
  final num coursePrice;

  /// Cohort size for full enrolment. null = unlimited.
  final int? seats;
  final int? seatsLeft;

  /// Null when the caller is not signed in.
  final CourseEnrollment? enrollment;

  /// "After the trial, always advise the whole course."
  final bool upsellRecommended;

  bool get isFull => seatsLeft != null && seatsLeft! <= 0;

  factory CourseDetail.fromJson(Map<String, dynamic> j) {
    final trial = Map<String, dynamic>.from(j['trial'] as Map? ?? {});
    final course = Map<String, dynamic>.from(j['course'] as Map? ?? {});
    final enrol = j['enrollment'];
    final upsell = j['upsell'];
    return CourseDetail(
      activityId: j['activity_id'] as String? ?? '',
      trialLessons: ((trial['lessons'] as List?) ?? [])
          .map((e) => CourseLesson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      trialPrice: (trial['total_price'] as num?) ?? 0,
      courseLessons: ((course['lessons'] as List?) ?? [])
          .map((e) => CourseLesson.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      coursePrice: (course['price'] as num?) ?? 0,
      seats: (course['seats'] as num?)?.toInt(),
      seatsLeft: (course['seats_left'] as num?)?.toInt(),
      enrollment: enrol is Map
          ? CourseEnrollment.fromJson(Map<String, dynamic>.from(enrol))
          : null,
      upsellRecommended:
          upsell is Map ? (upsell['recommended'] as bool? ?? false) : false,
    );
  }
}

/// Courses.
///
/// A course is bought as a package — the 3 trial lessons, or the whole course —
/// so it does NOT go through `orders/checkout` (which is per-session, priced by
/// age tier, on a single date). The payment result is the same [CheckoutResult]
/// though, so the existing Paycom / Paylov / saved-card flow is reused as-is.
@injectable
class CoursesApi {
  CoursesApi(this._dio);

  final Dio _dio;

  Future<CourseDetail> detail(String activityId) async {
    final res = await _dio.get('courses/$activityId');
    return CourseDetail.fromJson(_unwrap(res.data));
  }

  /// [option] is 'trial' (the 3 trial lessons) or 'full' (the whole course).
  Future<CheckoutResult> checkout({
    required String activityId,
    required String option,
    String? lang,
    String? returnUrl,
    String? paymentProvider,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
  }) async {
    final body = {
      'option': option,
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

import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/payment_error.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';

/// How a course purchase attempt ended.
enum CoursePurchaseOutcome {
  /// The payment screen was opened and closed — the enrolment may have changed,
  /// so the caller must reload.
  completed,

  /// Nothing happened: not signed in, or the request failed. [message] says why.
  failed,
}

class CoursePurchaseResult {
  const CoursePurchaseResult(this.outcome, [this.message]);

  final CoursePurchaseOutcome outcome;
  final String? message;

  bool get needsReload => outcome == CoursePurchaseOutcome.completed;
}

/// Pull a machine-readable `error_code` out of whatever the API returned.
///
/// The backend answers course failures with `{message, error_code}`, sometimes
/// wrapped in `{data: …}`. Everything else — timeouts, HTML error pages, a
/// gateway hiccup — has no code and falls back to a generic message. What must
/// never happen is the old behaviour: printing `e.toString()`, i.e. a Dio stack
/// dump, at the user.
String? _errorCode(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  if (data is! Map) return null;
  final root = Map<String, dynamic>.from(data);
  final code = root['error_code'];
  if (code is String) return code;
  final nested = root['data'] ?? root['message'];
  if (nested is Map && nested['error_code'] is String) {
    return nested['error_code'] as String;
  }
  return null;
}

/// Shared by every course-checkout entry point (trial purchase here, and the
/// whole-course review screen) so a Dio stack dump is never what a buyer sees.
///
/// A course-specific refusal ("sold out", "already enrolled") is the most
/// useful thing we can say; then the shared payment-gateway mapping; then a
/// generic message.
String courseCheckoutErrorMessage(Object error) {
  final reason = CourseBlockedReason.fromKey(_errorCode(error));
  if (reason != null) return reason.messageKey.tr();
  return PaymentError.fromDio(error) ?? 'pay_generic_error'.tr();
}

bool get _isSignedIn => getIt<Storage>().tokens.call()?.access != null;

/// Buy a course — trial lessons, or the whole thing.
///
/// Shared by the flat course screen and the per-level screen: both need the same
/// sign-in check, the same payment hand-off and the same error mapping, and the
/// only thing that differs is which level [subcourseId] names.
///
/// [trialDates] is the parent's pick: trial sessions are sold one at a time,
/// so a purchase is for the dates they chose, not for the whole set.
Future<CoursePurchaseResult> runCoursePurchase(
  BuildContext context, {
  required String activityId,
  required CoursePurchaseOption option,
  String? subcourseId,
  List<String>? trialDates,
}) async {
  // A course detail page is public, so the buy button is the first place a
  // signed-out user can hit auth. Send them to login rather than letting the
  // request 401.
  if (!_isSignedIn) {
    await context.router.push(LoginRoute());
    return const CoursePurchaseResult(CoursePurchaseOutcome.failed);
  }

  try {
    final CheckoutResult result = await getIt<CoursesApi>().checkout(
      activityId: activityId,
      option: option,
      subcourseId: subcourseId,
      trialDates: trialDates,
      lang: context.locale.languageCode,
    );

    if (!context.mounted) {
      return const CoursePurchaseResult(CoursePurchaseOutcome.completed);
    }
    if (result.checkoutUrl.isEmpty) {
      return CoursePurchaseResult(
        CoursePurchaseOutcome.failed,
        'pay_generic_error'.tr(),
      );
    }

    // The same checkout screen the normal booking flow uses — no provider means
    // the default direct Payme (Paycom) redirect.
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaycomCheckoutPage(result: result)),
    );
    return const CoursePurchaseResult(CoursePurchaseOutcome.completed);
  } catch (e) {
    return CoursePurchaseResult(
      CoursePurchaseOutcome.failed,
      courseCheckoutErrorMessage(e),
    );
  }
}

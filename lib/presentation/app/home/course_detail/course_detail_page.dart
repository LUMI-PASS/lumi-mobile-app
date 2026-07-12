import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/paycom_checkout_page.dart';

/// A course.
///
/// Two things are on sale, and the screen makes the difference obvious:
///   • the 3 TRIAL lessons — try it out, priced per lesson
///   • the WHOLE course
///
/// The product rule is "after the trial, always advise the whole course", so the
/// upsell banner shows for anyone who is not already fully enrolled.
///
/// Note the price the user pays: buying the course after a trial is the FULL
/// course price — the trial fee is not credited. That is deliberate (see the
/// backend), and the screen states it rather than hiding it.
@RoutePage()
class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({required this.course, super.key});

  final HomClass course;

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final _api = getIt<CoursesApi>();

  CourseDetail? _detail;
  bool _loading = true;
  bool _buying = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await _api.detail(widget.course.id ?? '');
      if (!mounted) return;
      setState(() {
        _detail = d;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _buy(String option) async {
    if (_buying) return;
    setState(() {
      _buying = true;
      _error = null;
    });
    try {
      final CheckoutResult result = await _api.checkout(
        activityId: widget.course.id ?? '',
        option: option,
      );
      if (!mounted) return;
      setState(() => _buying = false);

      if (result.checkoutUrl.isNotEmpty) {
        // Same checkout screen the normal booking flow uses — no provider means
        // the default direct Payme (Paycom) redirect.
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaycomCheckoutPage(result: result),
          ),
        );
        if (mounted) _load(); // the enrolment may have changed
      } else {
        setState(() => _error = 'pay_generic_error'.tr());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _buying = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _detail;
    return Scaffold(
      appBar: AppBar(title: Text(widget.course.title ?? '')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : d == null
              ? _errorView()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                    children: [
                      if (_error != null) _errorBanner(_error!),

                      // "Always advise the whole course" once they've trialled.
                      if (d.enrollment?.hasTrial == true && d.upsellRecommended)
                        _upsellBanner(d),

                      if (d.enrollment?.isEnrolled == true) _enrolledBanner(),

                      _trialCard(d),
                      16.verticalSpace,
                      _courseCard(d),
                    ],
                  ),
                ),
    );
  }

  Widget _errorView() => Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error ?? 'error'.tr(), textAlign: TextAlign.center),
              12.verticalSpace,
              FilledButton(onPressed: _load, child: Text('retry'.tr())),
            ],
          ),
        ),
      );

  Widget _errorBanner(String msg) => Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(msg, style: const TextStyle(color: Colors.red)),
      );

  Widget _upsellBanner(CourseDetail d) => Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'course_upsell_title'.tr(),
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.sp),
            ),
            6.verticalSpace,
            Text(
              'course_upsell_body'.tr(
                namedArgs: {'price': _money(d.coursePrice)},
              ),
              style: TextStyle(fontSize: 13.sp),
            ),
          ],
        ),
      );

  Widget _enrolledBanner() => Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.10),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Text(
          'course_already_enrolled'.tr(),
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
      );

  /// The 3 trial lessons — dates come from the activity's schedule.
  Widget _trialCard(CourseDetail d) {
    final enrolled = d.enrollment?.isEnrolled == true;
    final hasTrial = d.enrollment?.hasTrial == true;
    final canBuy = d.trialLessons.isNotEmpty && !enrolled && !hasTrial;

    return _section(
      title: 'course_trial_title'.tr(
        namedArgs: {'count': '${d.trialLessons.length}'},
      ),
      subtitle: 'course_trial_subtitle'.tr(),
      children: [
        ...d.trialLessons.map(_lessonRow),
        12.verticalSpace,
        _priceRow('course_trial_total'.tr(), d.trialPrice),
        12.verticalSpace,
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: (canBuy && !_buying) ? () => _buy('trial') : null,
            child: Text(
              hasTrial
                  ? 'course_trial_bought'.tr()
                  : 'course_buy_trial'.tr(),
            ),
          ),
        ),
      ],
    );
  }

  /// The whole course — dates come from the course's own weekday pattern.
  Widget _courseCard(CourseDetail d) {
    final enrolled = d.enrollment?.isEnrolled == true;
    final full = d.isFull;
    final canBuy = d.courseLessons.isNotEmpty && !enrolled && !full && !_buying;

    return _section(
      title: 'course_full_title'.tr(),
      subtitle: 'course_lessons_count'.tr(
        namedArgs: {'count': '${d.courseLessons.length}'},
      ),
      children: [
        // Only the first few — the full list would bury the price and the button.
        ...d.courseLessons.take(4).map(_lessonRow),
        if (d.courseLessons.length > 4)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              'course_more_lessons'.tr(
                namedArgs: {'count': '${d.courseLessons.length - 4}'},
              ),
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ),
        12.verticalSpace,
        _priceRow('course_full_price'.tr(), d.coursePrice),
        if (d.seatsLeft != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              full
                  ? 'course_full_no_seats'.tr()
                  : 'course_seats_left'.tr(
                      namedArgs: {'count': '${d.seatsLeft}'},
                    ),
              style: TextStyle(
                fontSize: 12.sp,
                color: full ? Colors.red : Colors.grey,
              ),
            ),
          ),
        12.verticalSpace,
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canBuy ? () => _buy('full') : null,
            child: Text(
              enrolled
                  ? 'course_already_enrolled_short'.tr()
                  : full
                      ? 'course_full_no_seats'.tr()
                      : 'course_buy_full'.tr(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) =>
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
            ),
            4.verticalSpace,
            Text(
              subtitle,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
            12.verticalSpace,
            ...children,
          ],
        ),
      );

  Widget _lessonRow(CourseLesson l) => Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            SizedBox(
              width: 28.w,
              child: Text(
                '${l.lessonNo}.',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
            ),
            Expanded(child: Text(l.date, style: TextStyle(fontSize: 14.sp))),
            if (l.startTime != null)
              Text(
                '${l.startTime}${l.endTime != null ? ' – ${l.endTime}' : ''}',
                style: TextStyle(fontSize: 13.sp, color: Colors.grey),
              ),
          ],
        ),
      );

  Widget _priceRow(String label, num amount) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14.sp)),
          Text(
            _money(amount),
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
          ),
        ],
      );

  String _money(num v) =>
      '${NumberFormat('#,###', 'ru').format(v)} ${'sum'.tr()}';
}

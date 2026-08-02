import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';

/// Everything on sale for ONE thing — a level, or a course with no levels.
///
/// Two cards, because two things are on sale and the difference has to be
/// obvious:
///   • the TRIAL lessons — try it out, priced per lesson
///   • the WHOLE course/level
///
/// Note the price a trial holder pays for the full thing: the trial fee is NOT
/// credited (see the backend). This screen states that rather than hiding it.
///
/// Whether a button is live is decided by the server ([CourseLevel.canBuyTrial]
/// / [CourseLevel.canBuyFull]) so the UI can never offer a purchase checkout
/// would reject; [CourseBlockedReason] explains a disabled one.
class CoursePurchaseView extends StatelessWidget {
  const CoursePurchaseView({
    required this.level,
    required this.busy,
    required this.onBuy,
    super.key,
  });

  final CourseLevel level;
  final bool busy;
  final void Function(CoursePurchaseOption option) onBuy;

  @override
  Widget build(BuildContext context) {
    final enrolled = level.enrollment?.isEnrolled == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (enrolled) _EnrolledBanner(level: level),
        if (!enrolled &&
            level.enrollment?.hasTrial == true &&
            level.upsellRecommended)
          _UpsellBanner(price: level.coursePrice),
        if (level.trialLessons.isNotEmpty) ...[
          _TrialCard(level: level, busy: busy, onBuy: onBuy),
          16.verticalSpace,
        ],
        _FullCourseCard(level: level, busy: busy, onBuy: onBuy),
      ],
    );
  }
}

class _TrialCard extends StatelessWidget {
  const _TrialCard({
    required this.level,
    required this.busy,
    required this.onBuy,
  });

  final CourseLevel level;
  final bool busy;
  final void Function(CoursePurchaseOption option) onBuy;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'course_trial_title'.tr(
        namedArgs: {'count': '${level.trialLessons.length}'},
      ),
      subtitle: 'course_trial_subtitle'.tr(),
      children: [
        ...level.trialLessons.map((l) => _LessonRow(lesson: l)),
        12.verticalSpace,
        _PriceRow(label: 'course_trial_total'.tr(), amount: level.trialPrice),
        12.verticalSpace,
        _BuyButton(
          label: 'course_buy_trial'.tr(),
          enabled: level.canBuyTrial,
          busy: busy,
          blockedReason: level.trialBlockedReason,
          onPressed: () => onBuy(CoursePurchaseOption.trial),
        ),
      ],
    );
  }
}

class _FullCourseCard extends StatelessWidget {
  const _FullCourseCard({
    required this.level,
    required this.busy,
    required this.onBuy,
  });

  final CourseLevel level;
  final bool busy;
  final void Function(CoursePurchaseOption option) onBuy;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = level.courseLessons.length;
    // Enrolling mid-course buys only what is still ahead — at the full price.
    // Saying so is fairer than showing a lesson count the buyer won't get.
    final partial = level.lessonsLeft > 0 && level.lessonsLeft < total;

    return _Section(
      title: 'course_full_title'.tr(),
      subtitle: partial
          ? 'course_lessons_remaining'.tr(
              namedArgs: {'left': '${level.lessonsLeft}', 'total': '$total'},
            )
          : 'course_lessons_count'.tr(namedArgs: {'count': '$total'}),
      children: [
        // Only the first few — the full list would bury the price and the button.
        ...level.courseLessons.take(4).map((l) => _LessonRow(lesson: l)),
        if (total > 4)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              'course_more_lessons'.tr(namedArgs: {'count': '${total - 4}'}),
              style: AppText.regular12.copyWith(color: colors.textSecondary),
            ),
          ),
        12.verticalSpace,
        _PriceRow(label: 'course_full_price'.tr(), amount: level.coursePrice),
        if (level.seatsLeft != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              level.isFull
                  ? 'course_full_no_seats'.tr()
                  : 'course_seats_left'.tr(
                      namedArgs: {'count': '${level.seatsLeft}'},
                    ),
              style: AppText.regular12.copyWith(
                color: level.isFull ? colors.error : colors.textSecondary,
              ),
            ),
          ),
        12.verticalSpace,
        _BuyButton(
          label: 'course_buy_full'.tr(),
          enabled: level.canBuyFull,
          busy: busy,
          blockedReason: level.blockedReason,
          onPressed: () => onBuy(CoursePurchaseOption.full),
        ),
      ],
    );
  }
}

/// A buy button plus, when it is disabled, the reason in the user's language.
class _BuyButton extends StatelessWidget {
  const _BuyButton({
    required this.label,
    required this.enabled,
    required this.busy,
    required this.onPressed,
    this.blockedReason,
  });

  final String label;
  final bool enabled;
  final bool busy;
  final CourseBlockedReason? blockedReason;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final reason = blockedReason;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CommonButton.elevated(
          text: label,
          enabled: enabled && !busy,
          loading: busy,
          onPressed: enabled && !busy ? onPressed : null,
        ),
        if (!enabled && reason != null) ...[
          8.verticalSpace,
          Text(
            reason.messageKey.tr(),
            textAlign: TextAlign.center,
            style: AppText.regular12
                .copyWith(color: context.colors.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _EnrolledBanner extends StatelessWidget {
  const _EnrolledBanner({required this.level});

  final CourseLevel level;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'course_already_enrolled'.tr(),
            style: AppText.semibold14.copyWith(color: colors.textPrimary),
          ),
          if ((level.enrollment?.upcomingLessons ?? 0) > 0) ...[
            4.verticalSpace,
            Text(
              'course_upcoming_lessons'.tr(
                namedArgs: {'count': '${level.enrollment!.upcomingLessons}'},
              ),
              style: AppText.regular12.copyWith(color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _UpsellBanner extends StatelessWidget {
  const _UpsellBanner({required this.price});

  final num price;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'course_upsell_title'.tr(),
            style: AppText.semibold14.copyWith(color: colors.textPrimary),
          ),
          6.verticalSpace,
          Text(
            'course_upsell_body'.tr(namedArgs: {'price': formatUzs(price)}),
            style: AppText.regular13.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.semibold16.copyWith(color: colors.textPrimary)),
          4.verticalSpace,
          Text(
            subtitle,
            style: AppText.regular12.copyWith(color: colors.textSecondary),
          ),
          12.verticalSpace,
          ...children,
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson});

  final CourseLesson lesson;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          SizedBox(
            width: 28.w,
            child: Text(
              '${lesson.lessonNo}.',
              style: AppText.regular13.copyWith(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              formatLessonDate(context, lesson.date),
              style: AppText.regular14.copyWith(color: colors.textPrimary),
            ),
          ),
          if (lesson.startTime != null)
            Text(
              '${lesson.startTime}'
              '${lesson.endTime != null ? ' – ${lesson.endTime}' : ''}',
              style: AppText.regular13.copyWith(color: colors.textSecondary),
            ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.amount});

  final String label;
  final num amount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppText.regular14.copyWith(color: colors.textPrimary)),
        Text(
          formatUzs(amount),
          style: AppText.semibold16.copyWith(color: colors.textPrimary),
        ),
      ],
    );
  }
}

/// `1 200 000 so'm` — the same money formatting the rest of the app uses.
String formatUzs(num value) => value.toRawUzsPrice();

/// `2026-09-14` → `14 сент.`, in the app's language.
///
/// Falls back to the raw ISO string for anything unparseable — a lesson row must
/// still render if the backend ever sends something unexpected.
String formatLessonDate(BuildContext context, String iso) {
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return iso;
  return DateFormat('d MMM', context.locale.languageCode).format(parsed);
}

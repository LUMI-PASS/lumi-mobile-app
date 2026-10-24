import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/course_timetable.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';

/// One group on the "Sinov darsi" card: the server's trial-request verdict
/// for it, plus the course group it names, for the age range and the date of
/// the next lesson. [level] is null when the two did not match up.
class TrialGroupItem {
  const TrialGroupItem({required this.group, this.level});

  final CourseTrialRequestGroup group;
  final CourseLevel? level;

  /// What the centre charges for the trial lesson, as the partner entered it:
  /// the next lesson still ahead, else the slot the server would fill next.
  /// Shown only — the app does not sell it; the parent pays at the centre.
  /// 0 means the centre made it free; null means no price is known.
  num? get price {
    final lessons = level?.trialLessons ?? const <CourseLesson>[];
    for (final lesson in lessons) {
      if (lesson.isAvailable && lesson.price != null) return lesson.price;
    }
    return level?.trialNextPrice ??
        lessons.map((l) => l.price).whereType<num>().firstOrNull;
  }
}

/// The groups of a running course that take a FREE trial request, each with
/// its own "Yozilish" button. Tapping one goes straight to choosing the child
/// — the group is already chosen by the row.
///
/// A group that has already been asked for stays on the card as a quiet
/// "request sent" chip, so the parent sees what they did; a group the server
/// will not take a request for is not listed at all.
class TrialGroupsCard extends StatelessWidget {
  const TrialGroupsCard({
    super.key,
    required this.c,
    required this.items,
    required this.onRequest,
  });

  final AppColorScheme c;
  final List<TrialGroupItem> items;
  final ValueChanged<TrialGroupItem> onRequest;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DetailCardHeader(
            c: c,
            icon: Assets.icons.detail.icCalendar,
            iconGradient: AppGradients.brand,
            title: 'trial_request_title'.tr(),
          ),
          14.verticalSpace,
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) 8.verticalSpace,
            _TrialGroupRow(
              c: c,
              item: items[i],
              onRequest: () => onRequest(items[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrialGroupRow extends StatelessWidget {
  const _TrialGroupRow({
    required this.c,
    required this.item,
    required this.onRequest,
  });

  final AppColorScheme c;
  final TrialGroupItem item;
  final VoidCallback onRequest;

  /// "5–12 yosh", the widest span across the group's age tiers.
  String? get _ages {
    final tiers = item.level?.ageTiers ?? const <CourseAgeTier>[];
    if (tiers.isEmpty) return null;
    final from = tiers.map((t) => t.ageFrom).reduce((a, b) => a < b ? a : b);
    final suffix = 'age_years_suffix'.tr();
    if (tiers.any((t) => t.ageTo == null)) return '$from+ $suffix';
    final to = tiers.map((t) => t.ageTo!).reduce((a, b) => a > b ? a : b);
    return '$from–$to $suffix';
  }

  /// When the group meets — "Du, Cho, Ju 16:00 – 17:00" — worded by the same
  /// helper the purchase sheet uses.
  String? get _timetable {
    final lessons = item.level?.courseLessons ?? const <CourseLesson>[];
    final summary = courseTimetableSummary(
      lessons.isNotEmpty ? lessons : item.level?.trialLessons ?? const [],
    );
    return summary.isEmpty ? null : summary;
  }

  /// The next lesson a trial could fall on — "27 Okt". The centre agrees the
  /// actual date on the phone; this only says how soon the group meets.
  String? get _nextLesson {
    final lessons = item.level?.trialLessons ?? const <CourseLesson>[];
    for (final lesson in lessons) {
      if (!lesson.isAvailable) continue;
      final date = DateTime.tryParse(lesson.date);
      if (date == null) continue;
      return 'trial_request_next_lesson'
          .tr(args: ['${date.day} ${'month_short_${date.month}'.tr()}']);
    }
    return null;
  }

  String? get _seats {
    final left = item.level?.seatsLeft;
    if (left == null) return null;
    return 'course_seats_left'.tr(namedArgs: {'count': '$left'});
  }

  @override
  Widget build(BuildContext context) {
    final group = item.group;
    final name = group.name?.trim();
    final title = (name == null || name.isEmpty)
        ? 'trial_request_group_unnamed'.tr()
        : name;
    final ages = _ages;
    final price = item.price;
    final details = <(SvgGenImage, String)>[
      if (price != null && price > 0)
        (
          Assets.icons.home.money,
          'trial_request_price'.tr(args: [price.toRawUzsPrice()]),
        ),
      if (_timetable != null) (Assets.icons.home.calendar, _timetable!),
      if (_nextLesson != null) (Assets.icons.home.clock, _nextLesson!),
      if (_seats != null) (Assets.icons.home.users, _seats!),
    ];

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Same lead-in as a price row: icon in a white circle, the name,
          // and the one fact that tells two groups apart under it.
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration:
                    BoxDecoration(color: c.surface, shape: BoxShape.circle),
                child: HomeIcon(Assets.icons.home.profile2user,
                    size: 20, color: c.textPrimary),
              ),
              8.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.semibold14.copyWith(color: c.textPrimary),
                    ),
                    if (ages != null) ...[
                      4.verticalSpace,
                      Text(
                        ages,
                        style:
                            AppText.regular12.copyWith(color: c.textPrimary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            8.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < details.length; i++) ...[
                    if (i > 0) 8.verticalSpace,
                    _Detail(c: c, icon: details[i].$1, text: details[i].$2),
                  ],
                ],
              ),
            ),
          ],
          8.verticalSpace,
          // Lower than the page's main CTA: one of several on the card, not
          // THE action of the page.
          group.requested
              ? _SentButton(c: c)
              : GradientButton(
                  text: 'trial_request_book'.tr(),
                  height: 40.h,
                  onPressed: onRequest,
                ),
        ],
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.c, required this.icon, required this.text});

  final AppColorScheme c;
  final SvgGenImage icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeIcon(icon, size: 16, color: c.textSecondary),
        8.horizontalSpace,
        Expanded(
          child: Text(
            text,
            style: AppText.medium13.copyWith(color: c.textPrimary),
          ),
        ),
      ],
    );
  }
}

/// The inert "already asked" state, in the button's own shape so the row
/// does not jump when it flips.
class _SentButton extends StatelessWidget {
  const _SentButton({required this.c});

  final AppColorScheme c;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(44.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_rounded, size: 18.sp, color: AppColors.green),
          6.horizontalSpace,
          Text(
            'trial_request_sent_short'.tr(),
            style: AppText.medium16.copyWith(color: AppColors.green),
          ),
        ],
      ),
    );
  }
}

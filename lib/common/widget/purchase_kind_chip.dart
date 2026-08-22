import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/order/course_purchase.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';

/// What an order bought, said in one line: a whole course, one trial lesson,
/// or a single activity booking.
///
/// Three products are sold through one checkout and arrived on the same card,
/// where a term-long enrolment and a one-off visit were told apart only by
/// their price. The kind is the first thing a buyer checks against their own
/// memory of the purchase, so it is stated rather than implied — including for
/// a plain activity, since "no badge" is not something a reader can notice.
///
/// [subcourseName] rides along when the course is sold as sub-courses: the
/// group is part of what was bought ("Whole course · Beginner").
class PurchaseKindChip extends StatelessWidget {
  const PurchaseKindChip({
    super.key,
    required this.kind,
    this.subcourseName,
    this.compact = false,
  });

  final CoursePurchase kind;
  final String? subcourseName;

  /// Drops the icon and tightens the padding, for a card that is already busy.
  final bool compact;

  /// The colour that carries the meaning. A course is the brand purple — it is
  /// the bigger commitment and the thing the app is really selling; a trial
  /// takes the brand pink, near it but plainly not it; a single visit stays
  /// neutral, because it is the ordinary case and colouring it would make
  /// every card shout.
  Color _accent(AppColorScheme c) => switch (kind) {
        CoursePurchase.full => AppColors.brandPurple,
        CoursePurchase.trial => AppColors.brandPink,
        CoursePurchase.unknown => AppColors.brandPurple,
        CoursePurchase.none => c.textSecondary,
      };

  SvgGenImage get _icon => switch (kind) {
        CoursePurchase.full ||
        CoursePurchase.unknown =>
          Assets.icons.detail.iconsaxAiCalendar,
        CoursePurchase.trial => Assets.icons.detail.iconsaxTicketDiscount,
        CoursePurchase.none => Assets.icons.detail.iconsaxTicketDiscount,
      };

  String get _label => switch (kind) {
        CoursePurchase.full => 'course_full_title'.tr(),
        CoursePurchase.trial => 'course_trial_lesson_one'.tr(),
        // A kind this build doesn't know is still a course — say the true half
        // rather than mislabelling it as a single visit.
        CoursePurchase.unknown => 'order_kind_course'.tr(),
        CoursePurchase.none => 'order_kind_activity'.tr(),
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = _accent(c);
    final group = subcourseName?.trim() ?? '';
    final text = group.isEmpty ? _label : '$_label · $group';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8.w : 10.w,
        vertical: compact ? 3.h : 5.h,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            HomeIcon(_icon, size: 14, color: accent),
            4.horizontalSpace,
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.semibold12.copyWith(color: accent),
            ),
          ),
        ],
      ),
    );
  }
}

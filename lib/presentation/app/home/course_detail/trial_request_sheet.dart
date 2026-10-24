import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';

/// "Request a trial lesson" for one group of a course that is already running.
///
/// The group was chosen on the course page — each group on the "Sinov darsi"
/// card has its own button — so this sheet only asks who the lesson is for.
/// Nothing here is a purchase: nothing is charged or reserved. The partner's
/// trial price is quoted so the parent knows it before asking — they pay it at
/// the centre. The centre is told and calls the parent to agree the date.
class TrialRequestSheet extends StatefulWidget {
  const TrialRequestSheet({
    super.key,
    required this.activityId,
    required this.group,
    this.courseTitle,
    this.price,
  });

  final String activityId;
  final CourseTrialRequestGroup group;
  final String? courseTitle;

  /// The trial lesson's price as the partner entered it — see
  /// `TrialGroupItem.price`. 0 is free; null is not known.
  final num? price;

  /// Opens the sheet. Resolves to `true` once a request has been sent (or the
  /// server says one is already open), so the caller can reload the course.
  static Future<bool> show(
    BuildContext context, {
    required String activityId,
    required CourseTrialRequestGroup group,
    String? courseTitle,
    num? price,
  }) async {
    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => TrialRequestSheet(
        activityId: activityId,
        group: group,
        courseTitle: courseTitle,
        price: price,
      ),
    );
    return sent ?? false;
  }

  @override
  State<TrialRequestSheet> createState() => _TrialRequestSheetState();
}

class _TrialRequestSheetState extends State<TrialRequestSheet> {
  List<ChildModel> _children = const [];
  String? _childId;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  /// Non-fatal: the request works without a child — the centre calls the
  /// parent either way. One child is picked for them.
  Future<void> _loadChildren() async {
    try {
      final children = await getIt<HomeRepository>().getChildren();
      if (!mounted) return;
      setState(() {
        _children = children;
        if (children.length == 1) _childId = children.first.id;
      });
    } catch (_) {
      // Leave the list empty; requesting does not depend on it.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    try {
      await getIt<CoursesApi>().requestTrial(
        activityId: widget.activityId,
        subcourseId: widget.group.subcourseId,
        childId: _childId,
      );
      messenger?.showSnackBar(
        SnackBar(content: Text('trial_request_sent_toast'.tr())),
      );
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      // Already open for this child and group: what they wanted is already
      // true, so close and let the page show "request sent".
      final code = e is DioException && e.response?.data is Map
          ? (e.response!.data as Map)['error_code']
          : null;
      if (code == 'already_requested') {
        messenger?.showSnackBar(
          SnackBar(content: Text('trial_request_already'.tr())),
        );
        navigator.pop(true);
        return;
      }
      setState(() => _sending = false);
      messenger?.showSnackBar(
        SnackBar(content: Text('trial_request_failed'.tr())),
      );
    }
  }

  /// "It's free" only when the centre set the price to 0. A priced trial
  /// quotes the price; with no price known, the note claims neither.
  String get _hint {
    final price = widget.price;
    if (price == null) return 'trial_request_hint_unpriced'.tr();
    if (price <= 0) return 'trial_request_hint'.tr();
    return 'trial_request_hint_paid'.tr(args: [price.toRawUzsPrice()]);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final groupName = widget.group.name?.trim();
    final subject = [widget.courseTitle?.trim(), groupName]
        .where((v) => v != null && v.isNotEmpty)
        .join(' · ');
    // With children on the account one has to be picked; with none the
    // request still goes, and the centre asks on the phone.
    final canSend =
        !_sending && !_loading && (_children.isEmpty || _childId != null);

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 10.h,
        bottom: 16.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: c.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'trial_request_who'.tr(),
            style: AppText.heading20.copyWith(color: c.textPrimary),
          ),
          if (subject.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              subject,
              style: AppText.medium14.copyWith(color: c.textSecondary),
            ),
          ],
          SizedBox(height: 16.h),
          if (_loading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (_children.isEmpty)
            _InfoTile(c: c, text: 'trial_request_no_children'.tr())
          else
            for (final child in _children) ...[
              _ChildTile(
                c: c,
                child: child,
                selected: _childId == child.id,
                onTap: () => setState(() => _childId = child.id),
              ),
              SizedBox(height: 8.h),
            ],
          SizedBox(height: 8.h),
          _InfoTile(c: c, text: _hint, free: widget.price == 0),
          SizedBox(height: 16.h),
          GradientButton(
            text: 'trial_request_send'.tr(),
            enabled: canSend,
            loading: _sending,
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}

/// A child as one full-width, tappable row: initial, name, age, radio.
class _ChildTile extends StatelessWidget {
  const _ChildTile({
    required this.c,
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final AppColorScheme c;
  final ChildModel child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = child.firstName?.trim();
    final label =
        (name == null || name.isEmpty) ? 'intake_child_unnamed'.tr() : name;
    final age = child.age;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.brandPurple.withValues(alpha: 0.08)
              : c.control,
          borderRadius: BorderRadius.circular(40.r),
          border: Border.all(
            color: selected ? AppColors.brandPurple : c.controlBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: AppGradients.brand,
                shape: BoxShape.circle,
              ),
              child: Text(
                label.characters.first.toUpperCase(),
                style: AppText.bold16.copyWith(color: AppColors.onBrand),
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  if (age != null) ...[
                    4.verticalSpace,
                    Text(
                      '$age ${'age_years_suffix'.tr()}',
                      style: AppText.regular12.copyWith(color: c.textPrimary),
                    ),
                  ],
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22.w,
              height: 22.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected ? AppGradients.brand : null,
                border: selected
                    ? null
                    : Border.all(color: c.border, width: 1.5),
              ),
              child: selected
                  ? Icon(Icons.check_rounded,
                      size: 14.sp, color: AppColors.onBrand)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// A quiet note row — what happens next, or why no child is listed.
class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.c, required this.text, this.free = false});

  final AppColorScheme c;
  final String text;

  /// The "it's free" note gets the green tint; anything else stays neutral.
  final bool free;

  @override
  Widget build(BuildContext context) {
    final accent = free ? AppColors.green : c.textSecondary;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: free ? AppColors.green.withValues(alpha: 0.1) : c.control,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            free ? Icons.phone_in_talk_rounded : Icons.info_outline_rounded,
            size: 18.sp,
            color: accent,
          ),
          8.horizontalSpace,
          Expanded(
            child: Text(
              text,
              style: AppText.regular13.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

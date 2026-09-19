import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';

/// "Join the waitlist" for an INTAKE — a course that is still recruiting.
///
/// Nothing here is a purchase: no price is shown, nothing is reserved, and the
/// sheet asks only for what the centre needs in order to ring back. The child
/// is optional on purpose — a parent may ask about a course before adding one
/// to their account, and a phone number is already a usable lead.
class IntakeWaitlistSheet extends StatefulWidget {
  const IntakeWaitlistSheet({
    super.key,
    required this.activityId,
    this.subcourseId,
    this.groupName,
    this.courseTitle,
  });

  final String activityId;

  /// The group they are signing up for; absent when the intake has none.
  final String? subcourseId;
  final String? groupName;
  final String? courseTitle;

  /// Opens the sheet. Resolves to `true` once a place has been taken, so the
  /// caller can reload the course and flip its CTA.
  static Future<bool> show(
    BuildContext context, {
    required String activityId,
    String? subcourseId,
    String? groupName,
    String? courseTitle,
  }) async {
    final joined = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.surface,
      barrierColor: AppColors.ink.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => IntakeWaitlistSheet(
        activityId: activityId,
        subcourseId: subcourseId,
        groupName: groupName,
        courseTitle: courseTitle,
      ),
    );
    return joined ?? false;
  }

  @override
  State<IntakeWaitlistSheet> createState() => _IntakeWaitlistSheetState();
}

class _IntakeWaitlistSheetState extends State<IntakeWaitlistSheet> {
  List<ChildModel> _children = const [];
  String? _childId;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  /// Non-fatal: the sheet still works without a child — the centre calls the
  /// parent either way.
  Future<void> _loadChildren() async {
    try {
      final children = await getIt<HomeRepository>().getChildren();
      if (!mounted) return;
      setState(() => _children = children);
    } catch (_) {
      // Leave the list empty; joining does not depend on it.
    }
  }

  Future<void> _join() async {
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    try {
      await getIt<CoursesApi>().joinWaitlist(
        activityId: widget.activityId,
        subcourseId: widget.subcourseId,
        childId: _childId,
      );
      messenger?.showSnackBar(
        SnackBar(content: Text('intake_joined_toast'.tr())),
      );
      navigator.pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      messenger?.showSnackBar(
        SnackBar(content: Text('intake_join_failed'.tr())),
      );
    }
  }

  String _childLabel(ChildModel child) {
    final name = child.firstName?.trim();
    final label = (name == null || name.isEmpty)
        ? 'intake_child_unnamed'.tr()
        : name;
    return child.age != null ? '$label · ${child.age}' : label;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final subject = [widget.courseTitle, widget.groupName]
        .where((v) => v != null && v.trim().isNotEmpty)
        .join(' · ');

    return Padding(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 12.h,
        bottom: 16.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'intake_join_title'.tr(),
              style: AppText.heading20.copyWith(color: c.textPrimary),
            ),
          ),
          SizedBox(height: 6.h),
          Center(
            child: Text(
              'intake_join_hint'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular13.copyWith(color: c.textSecondary),
            ),
          ),
          if (subject.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Center(
              child: Text(
                subject,
                textAlign: TextAlign.center,
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
            ),
          ],
          if (_children.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              'intake_join_child'.tr(),
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _children.map((child) {
                final selected = _childId != null && _childId == child.id;
                return GestureDetector(
                  // Tapping the chosen one again clears it: naming a child is
                  // optional, so it has to be possible to un-name them.
                  onTap: () => setState(
                    () => _childId = selected ? null : child.id,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40.r),
                      border: Border.all(
                        color: selected ? AppColors.brandPurple : c.border,
                      ),
                      color: selected
                          ? AppColors.brandPurple.withValues(alpha: 0.1)
                          : c.control,
                    ),
                    child: Text(
                      _childLabel(child),
                      style: AppText.medium14.copyWith(
                        color: selected ? c.textPrimary : c.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          SizedBox(height: 20.h),
          GradientButton(
            text: 'intake_join_cta'.tr(),
            enabled: !_sending,
            loading: _sending,
            onPressed: _join,
          ),
        ],
      ),
    );
  }
}

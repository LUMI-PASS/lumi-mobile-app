import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/course_purchase.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/widgets/course_purchase_view.dart';

/// One LEVEL of a course — "Beginner", "Elementary", …
///
/// Reloads the course itself rather than taking the level it was handed as
/// gospel: enrolment and seats change while the user is standing here (their own
/// payment, or somebody else taking the last seat), and this screen is where
/// that matters most.
class CourseLevelPage extends StatefulWidget {
  const CourseLevelPage({
    required this.activityId,
    required this.levelId,
    required this.initial,
    super.key,
  });

  final String activityId;
  final String levelId;

  /// Rendered immediately so the screen never opens on a spinner; replaced by
  /// the reload.
  final CourseLevel initial;

  @override
  State<CourseLevelPage> createState() => _CourseLevelPageState();
}

class _CourseLevelPageState extends State<CourseLevelPage> {
  final _api = getIt<CoursesApi>();

  late CourseLevel _level = widget.initial;
  bool _busy = false;
  String? _error;

  Future<void> _load() async {
    try {
      final detail = await _api.detail(
        widget.activityId,
        lang: context.locale.languageCode,
      );
      if (!mounted) return;
      final match = detail.levels.where((l) => l.id == widget.levelId);
      setState(() {
        // A level retired while the screen was open drops out of the list; keep
        // showing the last known state rather than blanking the screen.
        if (match.isNotEmpty) _level = match.first;
      });
    } catch (_) {
      // A failed refresh is not worth an error screen — the level already on
      // screen is still the best information we have.
    }
  }

  Future<void> _buy(CoursePurchaseOption option) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await runCoursePurchase(
      context,
      activityId: widget.activityId,
      option: option,
      subcourseId: widget.levelId,
    );

    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = result.message;
    });
    if (result.needsReload) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      appBar: BaseAppBar(title: _level.name ?? 'course_full_title'.tr()),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
          children: [
            if ((_level.description ?? '').isNotEmpty) ...[
              Text(
                _level.description!,
                style: AppText.regular14.copyWith(color: colors.textSecondary),
              ),
              16.verticalSpace,
            ],
            if (_error != null) ...[
              CourseErrorBanner(message: _error!),
              12.verticalSpace,
            ],
            CoursePurchaseView(level: _level, busy: _busy, onBuy: _buy),
          ],
        ),
      ),
    );
  }
}

/// Inline failure notice — a purchase that didn't happen must not look like one
/// that did, but it also must not throw away the screen behind it.
class CourseErrorBanner extends StatelessWidget {
  const CourseErrorBanner({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        message,
        style: AppText.regular13.copyWith(color: colors.error),
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/common_button.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/course_level_page.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/course_purchase.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/widgets/course_purchase_view.dart';

/// A course.
///
/// It comes in two shapes and this screen renders whichever it is:
///
///   LEVELS — "English" is only a container; Beginner / Elementary / … are what
///            a parent buys, each with its own prices, dates and seats. The
///            screen lists them and hands off to [CourseLevelPage].
///   FLAT   — one set of prices, bought right here.
///
/// In both shapes two things are on sale — the trial lessons and the whole
/// thing — and buying the whole thing after a trial costs the FULL price; the
/// trial fee is not credited. That is deliberate (see the backend), and the
/// screen states it rather than hiding it.
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
  bool _busy = false;
  String? _loadError;
  String? _purchaseError;

  String get _activityId => widget.course.id ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = _detail == null;
      _loadError = null;
    });
    try {
      final d = await _api.detail(
        _activityId,
        lang: context.locale.languageCode,
      );
      if (!mounted) return;
      setState(() {
        _detail = d;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadError = 'something_went_wrong'.tr();
      });
    }
  }

  /// Only reachable for a course with no levels — a levelled one always buys
  /// through [CourseLevelPage], so the purchase names its level explicitly.
  Future<void> _buyFlat(CoursePurchaseOption option) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _purchaseError = null;
    });

    final result = await runCoursePurchase(
      context,
      activityId: _activityId,
      option: option,
    );

    if (!mounted) return;
    setState(() {
      _busy = false;
      _purchaseError = result.message;
    });
    if (result.needsReload) await _load();
  }

  Future<void> _openLevel(CourseLevel level) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CourseLevelPage(
          activityId: _activityId,
          levelId: level.id!,
          initial: level,
        ),
      ),
    );
    // Enrolment may have changed behind the level screen.
    if (mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final detail = _detail;

    return Scaffold(
      backgroundColor: colors.scaffoldBg,
      appBar: BaseAppBar(title: widget.course.title ?? ''),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : detail == null
              ? _ErrorView(message: _loadError ?? 'something_went_wrong'.tr(), onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                    children: [
                      if (_purchaseError != null) ...[
                        CourseErrorBanner(message: _purchaseError!),
                        12.verticalSpace,
                      ],
                      if (detail.hasLevels)
                        _LevelList(
                          levels: detail.levels,
                          onTap: _openLevel,
                        )
                      else
                        CoursePurchaseView(
                          level: detail.flat,
                          busy: _busy,
                          onBuy: _buyFlat,
                        ),
                    ],
                  ),
                ),
    );
  }
}

/// The levels, as a chooser. Price, lesson count and seats are all a parent
/// needs to pick one; the purchase itself lives one screen deeper.
class _LevelList extends StatelessWidget {
  const _LevelList({required this.levels, required this.onTap});

  final List<CourseLevel> levels;
  final void Function(CourseLevel level) onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'course_levels_title'.tr(),
          style: AppText.semibold16.copyWith(color: colors.textPrimary),
        ),
        4.verticalSpace,
        Text(
          'course_levels_subtitle'.tr(),
          style: AppText.regular12.copyWith(color: colors.textSecondary),
        ),
        16.verticalSpace,
        ...levels.map(
          (level) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _LevelCard(level: level, onTap: () => onTap(level)),
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({required this.level, required this.onTap});

  final CourseLevel level;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final enrolled = level.enrollment?.isEnrolled == true;
    final hasTrial = level.enrollment?.hasTrial == true;
    // Sold out or over: still visible, but it must not look available.
    final unavailable = !level.canBuyFull && !level.canBuyTrial && !enrolled;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Opacity(
        opacity: unavailable ? 0.6 : 1,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      level.name ?? '',
                      style: AppText.semibold16
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  if (enrolled)
                    _Badge(
                      label: 'course_level_enrolled'.tr(),
                      color: colors.success,
                    )
                  else if (hasTrial)
                    _Badge(
                      label: 'course_level_trial'.tr(),
                      color: colors.primary,
                    ),
                ],
              ),
              if ((level.description ?? '').isNotEmpty) ...[
                4.verticalSpace,
                Text(
                  level.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppText.regular12.copyWith(color: colors.textSecondary),
                ),
              ],
              12.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatUzs(level.coursePrice),
                          style: AppText.semibold16
                              .copyWith(color: colors.textPrimary),
                        ),
                        2.verticalSpace,
                        Text(
                          'course_lessons_count'.tr(
                            namedArgs: {'count': '${level.courseLessons.length}'},
                          ),
                          style: AppText.regular12
                              .copyWith(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  if (level.seatsLeft != null)
                    Text(
                      level.isFull
                          ? 'course_full_no_seats'.tr()
                          : 'course_seats_left'.tr(
                              namedArgs: {'count': '${level.seatsLeft}'},
                            ),
                      style: AppText.regular12.copyWith(
                        color:
                            level.isFull ? colors.error : colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(label, style: AppText.medium10.copyWith(color: color)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: colors.textSecondary),
            ),
            16.verticalSpace,
            CommonButton.elevated(text: 'retry'.tr(), onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}

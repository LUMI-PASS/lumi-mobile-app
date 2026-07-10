import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class BranchDetailPage extends StatefulWidget {
  const BranchDetailPage({super.key, required this.branch});

  final HomBranch branch;

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
  List<HomClass> _classes = [];
  bool _isLoadingClasses = true;
  String? _classesError;
  int _classesPage = 1;
  int _classesTotalPages = 1;
  bool _isLoadingMore = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadClasses();
    final b = widget.branch;
    getIt<AnalyticsService>().logEvent(
      AnalyticsEvent.branchDetailViewed,
      params: {
        if (b.id != null) 'branch_id': b.id!,
        if (b.title != null) 'branch_title': b.title!,
        if (b.address != null) 'address': b.address!,
        if (b.distance != null) 'distance': b.distance!,
      },
    );
  }

  Future<void> _loadClasses({int page = 1, bool append = false}) async {
    final branchId = widget.branch.id;
    if (branchId == null) return;
    setState(() => append ? _isLoadingMore = true : _isLoadingClasses = true);
    try {
      final result = await getIt<HomeRepository>()
          .getBranchClasses(branchId, page: page, limit: 10);
      if (!mounted) return;
      setState(() {
        if (append) {
          _classes.addAll(result.classes);
        } else {
          _classes = result.classes;
        }
        _classesPage = page;
        _classesTotalPages = result.classesPages;
        _classesError = null;
        _isLoadingClasses = false;
        _isLoadingMore = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _classesError = 'branch_failed_classes'.tr();
          _isLoadingClasses = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _openGoogleMaps() async {
    final lat = widget.branch.latitude;
    final lng = widget.branch.longitude;
    if (lat == null || lng == null) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  List<HomClass> get _filtered {
    if (_query.trim().isEmpty) return _classes;
    final q = _query.toLowerCase();
    return _classes.where((c) {
      final t = (c.title ?? '').toLowerCase();
      final a = (c.branch?.address ?? '').toLowerCase();
      return t.contains(q) || a.contains(q);
    }).toList();
  }

  bool get _hasMap =>
      widget.branch.latitude != null && widget.branch.longitude != null;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final filtered = _filtered;

    return AnnotatedRegion(
      value: c.overlayStyle,
      child: Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header.
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                child: Row(
                  children: [
                    _ControlButton(
                      child: Icon(CupertinoIcons.back,
                          size: 18.sp, color: c.textPrimary),
                      onTap: () => context.router.pop(),
                    ),
                    Expanded(
                      child: Text(
                        widget.branch.title ?? '',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.bold18.copyWith(color: c.textPrimary),
                      ),
                    ),
                    SizedBox(width: 36.w),
                  ],
                ),
              ),
              // Search + filter + map.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44.h,
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            HomeIcon(HomeIcon.search,
                                size: 16, color: c.textSecondary),
                            8.horizontalSpace,
                            Expanded(
                              child: TextField(
                                onChanged: (v) => setState(() => _query = v),
                                style: AppText.regular14
                                    .copyWith(color: c.textPrimary),
                                cursorColor: AppColors.brandPurple,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: 'search_hint'.tr(),
                                  hintStyle: AppText.regular14
                                      .copyWith(color: c.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    8.horizontalSpace,
                    if (_hasMap)
                      _SquareButton(
                        icon: Icons.map_outlined,
                        onTap: _openGoogleMaps,
                      ),
                    if (_hasMap) 8.horizontalSpace,
                    _SquareButton(
                      icon: Icons.tune_rounded,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              14.verticalSpace,
              // Count.
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'all_count'.tr(args: ['${filtered.length}']),
                    style: AppText.regular14.copyWith(color: c.textSecondary),
                  ),
                ),
              ),
              12.verticalSpace,
              Expanded(child: _grid(c, filtered)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _grid(AppColors c, List<HomClass> items) {
    if (_isLoadingClasses) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.brandPurple));
    }
    if (_classesError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_classesError!,
                style: AppText.regular14.copyWith(color: c.textSecondary)),
            12.verticalSpace,
            TextButton(
              onPressed: () => _loadClasses(),
              child: Text('retry'.tr(),
                  style: AppText.medium14
                      .copyWith(color: AppColors.brandPurple)),
            ),
          ],
        ),
      );
    }
    if (items.isEmpty) {
      return Center(
        child: Text('branch_no_classes'.tr(),
            style: AppText.regular14.copyWith(color: c.textSecondary)),
      );
    }
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.axis == Axis.vertical &&
            n.metrics.pixels >= n.metrics.maxScrollExtent - 300 &&
            !_isLoadingMore &&
            _classesPage < _classesTotalPages &&
            _query.trim().isEmpty) {
          _loadClasses(page: _classesPage + 1, append: true);
        }
        return false;
      },
      child: GridView.builder(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 20.h,
          mainAxisExtent: 250.h,
        ),
        itemCount: items.length,
        itemBuilder: (_, i) => HomeCourseCard(
          key: ValueKey(items[i].id ?? i),
          homClass: items[i],
          width: double.infinity,
          margin: EdgeInsets.zero,
          imageHeight: 126.h,
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: c.control,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: c.controlBorder),
        ),
        child: child,
      ),
    );
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 44.h,
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, size: 20.sp, color: c.textPrimary),
      ),
    );
  }
}

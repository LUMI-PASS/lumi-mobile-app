import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_shadows.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/detail/detail_card.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/common/widget/map_route_sheet.dart';
import 'package:lumi_pass/common/widget/stretchy_hero.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:shimmer/shimmer.dart';

/// Hero carousel height — also the distance the top scrim fades in over.
const double _kHeroHeight = 300;

@RoutePage()
class BranchDetailPage extends StatefulWidget {
  const BranchDetailPage({super.key, required this.branch});

  final HomBranch branch;

  @override
  State<BranchDetailPage> createState() => _BranchDetailPageState();
}

class _BranchDetailPageState extends State<BranchDetailPage> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  Timer? _slideTimer;
  int _currentImageIndex = 0;

  /// 0 → hero fully visible, 1 → content scrolled under the top controls and
  /// the frosted scrim is fully on.
  double _topScrim = 0;

  /// Branch gallery — `images` when the backend sends a list, otherwise the
  /// single `image`. Derived from `widget.branch`, which never changes, so it
  /// is resolved once.
  late final List<String> _gallery = _resolveGallery();

  List<HomClass> _classes = [];
  bool _isLoadingClasses = true;
  String? _classesError;
  int _classesPage = 1;
  int _classesTotalPages = 1;
  bool _isLoadingMore = false;

  /// A "load more" request failed. Latches the paginate-on-scroll trigger off
  /// until the user retries — otherwise the failed page would be re-requested
  /// on every scroll tick, hammering the API.
  bool _loadMoreFailed = false;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _startAutoSlide();
    _scrollController.addListener(_onScroll);
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

  @override
  void dispose() {
    _slideTimer?.cancel();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> _resolveGallery() {
    final b = widget.branch;
    final list = b.images?.where((e) => e.trim().isNotEmpty).toList() ?? [];
    if (list.isNotEmpty) return list;
    final single = b.image;
    return (single != null && single.trim().isNotEmpty) ? [single] : const [];
  }

  bool get _hasMap =>
      widget.branch.latitude != null && widget.branch.longitude != null;

  /// Fade the top scrim in over the second half of the hero, so it is fully on
  /// by the time the first card slides under the back control. Doubles as the
  /// paginate-on-scroll trigger for the classes list.
  void _onScroll() {
    final start = _kHeroHeight.h * 0.45;
    final end = _kHeroHeight.h * 0.85;
    final t =
        ((_scrollController.offset - start) / (end - start)).clamp(0.0, 1.0);
    if ((t - _topScrim).abs() > 0.01 || t == 0 || t == 1) {
      if (t != _topScrim) setState(() => _topScrim = t);
    }

    // Paginate once the list is genuinely near its end. `maxScrollExtent > 0`
    // keeps a bouncing overscroll on a short page from tripping the trigger.
    final position = _scrollController.position;
    if (position.maxScrollExtent > 0 &&
        position.pixels >= position.maxScrollExtent - 300.h &&
        !_isLoadingMore &&
        !_isLoadingClasses &&
        !_loadMoreFailed &&
        _classesPage < _classesTotalPages) {
      _loadClasses(page: _classesPage + 1, append: true);
    }
  }

  void _startAutoSlide() {
    _slideTimer?.cancel();
    if (_gallery.length <= 1) return;
    _slideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_currentImageIndex + 1) % _gallery.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _loadClasses({int page = 1, bool append = false}) async {
    final branchId = widget.branch.id;
    if (branchId == null) {
      setState(() => _isLoadingClasses = false);
      return;
    }
    setState(() {
      if (append) {
        _isLoadingMore = true;
        _loadMoreFailed = false;
      } else {
        _isLoadingClasses = true;
      }
    });
    try {
      final result = await getIt<HomeRepository>()
          .getBranchClasses(branchId, page: page, limit: 10);
      if (!mounted) return;
      setState(() {
        if (append) {
          // The backend can repeat an item across pages when the ordering
          // shifts between requests; a duplicate id would collide on the list's
          // ValueKey and throw.
          final seen = _classes.map((e) => e.id).whereType<String>().toSet();
          _classes.addAll(
              result.classes.where((e) => e.id == null || seen.add(e.id!)));
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
      if (!mounted) return;
      setState(() {
        // A failed "load more" must not discard the pages already on screen —
        // it surfaces as a footer retry instead of replacing the whole list.
        if (append) {
          _loadMoreFailed = true;
        } else {
          _classesError = 'branch_failed_classes'.tr();
        }
        _isLoadingClasses = false;
        _isLoadingMore = false;
      });
    }
  }

  /// Lets the visitor pick their maps app rather than assuming Google — Yandex
  /// is what most people here navigate with.
  void _openRouteSheet() {
    final lat = widget.branch.latitude;
    final lng = widget.branch.longitude;
    if (lat == null || lng == null) return;
    MapRouteSheet.show(
      context,
      lat: lat,
      lng: lng,
      title: widget.branch.title,
      subtitle: widget.branch.address,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final b = widget.branch;
    final safeTop = MediaQuery.of(context).viewPadding.top;
    final safeBottom = MediaQuery.of(context).viewPadding.bottom;
    final description = (b.description ?? '').trim();

    // Over the hero the status bar sits on a photo (light icons); once the
    // scrim takes over on a light background the icons have to flip to dark.
    final darkIcons = !c.isDark && _topScrim > 0.5;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: darkIcons ? Brightness.dark : Brightness.light,
        statusBarBrightness: darkIcons ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(child: _hero(c, safeTop)),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _aboutCard(c, b, description),
                      20.verticalSpace,
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                    child: Text(
                      'branch_classes'.tr(),
                      style: AppText.heading20.copyWith(color: c.textPrimary),
                    ),
                  ),
                ),
                _classesSliver(c),
                SliverToBoxAdapter(
                  child: SizedBox(height: 24.h + safeBottom),
                ),
              ],
            ),
            // Frosted scrim under the top control — content blurs and fades out
            // as it scrolls beneath it.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: _topScrim,
                  child: DetailTopScrim(
                    color: c.scaffoldBg,
                    height: safeTop + 56.h,
                  ),
                ),
              ),
            ),
            Positioned(
              top: safeTop + 8.h,
              left: 16.w,
              child: DetailControlButton(
                onTap: () => context.router.pop(),
                child: HomeIcon(Assets.icons.home.arrow,
                    size: 16, color: AppColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Hero image carousel ────────────────────────────────────────────────────
  Widget _hero(AppColorScheme c, double safeTop) {
    final images = _gallery;
    return StretchyHero(
      controller: _scrollController,
      height: _kHeroHeight.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isNotEmpty)
            PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemBuilder: (_, i) => CachedNetworkImage(
                imageUrl: images[i],
                fit: BoxFit.cover,
                placeholder: (_, __) => _imgShimmer(c),
                errorWidget: (_, __, ___) => _imgShimmer(c),
              ),
            )
          else
            // The gallery comes from `widget.branch` and never fills in later,
            // so a branch with no photo gets a static placeholder — a shimmer
            // here would be a skeleton that loads forever.
            Container(
              color: c.control,
              alignment: Alignment.center,
              child: HomeIcon(Assets.icons.detail.icLocation,
                  size: 40, color: c.textPlaceholder),
            ),
          // Top scrim — a soft dark fade so the light control stays legible
          // over bright / near-white hero images.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: safeTop + 72.h,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.28),
                      Colors.black.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (images.length > 1)
            Positioned(
              bottom: 12.h,
              left: 0,
              right: 0,
              child: Center(
                child: FrostedCard(
                  hasBorder: false,
                  boxShadow: AppShadows.control,
                  borderRadius: BorderRadius.circular(32.r),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(images.length, (i) {
                      final active = i == _currentImageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 3.w),
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color:
                              active ? AppColors.ink : const Color(0xFFCECDD6),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imgShimmer(AppColorScheme c) => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
        child: Container(color: c.surface),
      );

  // ─── About card — title, description, location ─────────────────────────────
  Widget _aboutCard(AppColorScheme c, HomBranch b, String description) {
    final address = (b.address ?? '').trim();
    final landmark = (b.landmark ?? '').trim();

    return DetailCard(
      c: c,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(b.title ?? '',
              style: AppText.heading20.copyWith(color: c.textPrimary)),
          if (description.isNotEmpty) ...[
            16.verticalSpace,
            DetailCardHeader(
              c: c,
              icon: Assets.icons.detail.iconsaxQuestionMark,
              iconGradient: AppGradients.brand,
              title: 'branch_about'.tr(),
            ),
            16.verticalSpace,
            Text(
              description,
              textAlign: TextAlign.justify,
              style: AppText.regular14.copyWith(color: c.textPrimary),
            ),
          ],
          20.verticalSpace,
          _InfoPill(
            c: c,
            icon: Assets.icons.detail.icLocation,
            label: 'branch_address'.tr(),
            value: address.isEmpty ? 'branch_no_address'.tr() : address,
            subvalue: landmark.isEmpty ? null : landmark,
            // The whole pill opens the route; the chip is the visible
            // affordance. Both are inert without coordinates to navigate to.
            // Chip first, route icon on the outside edge — same arrangement as
            // the venue row on class detail. Everything in the row (pill, chip,
            // icon) opens the same app chooser.
            action: _hasMap ? 'branch_build_route'.tr() : null,
            onTap: _hasMap ? _openRouteSheet : null,
            trailing: _hasMap
                ? RouteIconButton(
                    lat: widget.branch.latitude!,
                    lng: widget.branch.longitude!,
                    title: widget.branch.title,
                    subtitle: widget.branch.address,
                  )
                : null,
          ),
        ],
      ),
    );
  }

  // ─── Classes at this branch ────────────────────────────────────────────────
  Widget _classesSliver(AppColorScheme c) {
    if (_isLoadingClasses) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.brandPurple),
          ),
        ),
      );
    }
    if (_classesError != null) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
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
        ),
      );
    }
    if (_classes.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Center(
            child: Text('branch_no_classes'.tr(),
                style: AppText.regular14.copyWith(color: c.textSecondary)),
          ),
        ),
      );
    }
    final hasFooter = _isLoadingMore || _loadMoreFailed;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverList.separated(
        itemCount: _classes.length + (hasFooter ? 1 : 0),
        separatorBuilder: (_, __) => 12.verticalSpace,
        itemBuilder: (_, i) {
          if (i == _classes.length) return _listFooter(c);
          return HomeCourseCard(
            key: ValueKey(_classes[i].id ?? i),
            homClass: _classes[i],
            width: double.infinity,
            margin: EdgeInsets.zero,
            imageHeight: 180.h,
          );
        },
      ),
    );
  }

  /// Spinner while the next page loads; a retry affordance if it failed — the
  /// pages already on screen stay put either way.
  Widget _listFooter(AppColorScheme c) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator(color: AppColors.brandPurple)
            : TextButton(
                onPressed: () =>
                    _loadClasses(page: _classesPage + 1, append: true),
                child: Text('retry'.tr(),
                    style: AppText.medium14
                        .copyWith(color: AppColors.brandPurple)),
              ),
      ),
    );
  }
}

/// Rounded pill row inside a detail card: a white circular icon tile, a muted
/// label with its value, and an optional trailing action chip (Figma 96:5531).
class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.c,
    required this.icon,
    required this.label,
    this.value,
    this.subvalue,
    this.action,
    this.onTap,
    this.trailing,
  });

  final AppColorScheme c;
  final SvgGenImage icon;
  final String label;
  final String? value;
  final String? subvalue;

  /// Trailing chip. Purely an affordance — the tap target is the whole pill.
  final String? action;
  final VoidCallback? onTap;

  /// Trailing widget with a tap target of its own (the route button), shown
  /// after [action].
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final v = value;
    final sub = subvalue;
    final act = action;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
        decoration: BoxDecoration(
          color: c.control,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: c.surface, shape: BoxShape.circle),
              child: HomeIcon(icon, size: 16, color: c.textPrimary),
            ),
            8.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style:
                          AppText.regular12.copyWith(color: c.textSecondary)),
                  if (v != null) ...[
                    4.verticalSpace,
                    Text(
                      v,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.semibold14.copyWith(color: c.textPrimary),
                    ),
                  ],
                  if (sub != null) ...[
                    2.verticalSpace,
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.regular12.copyWith(color: c.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            if (act != null) ...[
              8.horizontalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: detailChipFill(c),
                  borderRadius: BorderRadius.circular(40.r),
                ),
                child: Text(act,
                    style: AppText.regular12.copyWith(color: c.textSecondary)),
              ),
            ],
            if (trailing != null) ...[
              8.horizontalSpace,
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

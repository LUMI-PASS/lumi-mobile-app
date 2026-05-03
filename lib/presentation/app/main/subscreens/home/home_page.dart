import 'package:carousel_slider/carousel_slider.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';

import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/common/widget/language_bottom_sheet.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/shorts/shorts_feed.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/banner_lesson_widgets.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/class_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_skeletons.dart';

// Tab indices inside the main AutoTabsScaffold.
const int _kShortsTabIndex = 1;
const int _kSearchTabIndex = 3;

@RoutePage()
class HomePage extends BasePage<HomeCubit, HomeBuildable, HomeListenable> {
  const HomePage({super.key});

  @override
  void init(BuildContext context) {
    context.read<HomeCubit>().initWithLocation();
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    // Silent refresh so the premium badge picks up any change made off-screen
    // (e.g. after completing a subscription purchase) — without flashing the
    // shimmer over already-loaded content.
    context.read<HomeCubit>().refreshSilently();
    super.onFocusGained(context);
  }

  @override
  Widget builder(context, state) {
    final primary = context.colors.primary;
    return Scaffold(
      body: Stack(
        children: [
          // Subtle pattern wash using primary color — low opacity SVG motifs.
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFDFAF5),
                    Color(0xFFF8F5FF),
                    Color(0xFFEEE8FF),
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: -40,
            left: -60,
            child: Opacity(
              opacity: 0.08,
              child: Assets.icons.background.congratsMisc.svg(
                width: 280.w,
                height: 280.w,
                colorFilter:
                    ColorFilter.mode(primary, BlendMode.srcIn),
              ),
            ),
          ),
          Positioned(
            top: 220.h,
            right: -80,
            child: Opacity(
              opacity: 0.06,
              child: Assets.icons.background.premiumMisc.svg(
                width: 260.w,
                height: 260.w,
                colorFilter:
                    ColorFilter.mode(primary, BlendMode.srcIn),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -40,
            child: Opacity(
              opacity: 0.05,
              child: Assets.icons.background.misc2.svg(
                width: 240.w,
                height: 240.w,
                colorFilter:
                    ColorFilter.mode(primary, BlendMode.srcIn),
              ),
            ),
          ),
          Column(
            children: [
              // Fixed header
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).viewPadding.top + 8.h,
                  bottom: 8.h,
                ),
                child: _buildHeader(context, state),
              ),
              // Scrollable content
              Expanded(
                child: state.isLoading
                    ? const HomeShimmer()
                    : NotificationListener<ScrollNotification>(
                        onNotification: (scrollInfo) {
                          if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 200) {
                            context.read<HomeCubit>().loadMoreNearClasses();
                          }
                          return false;
                        },
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(top: 4.h, bottom: 20.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (state.homeModel?.data?.upcomingClass != null)
                                UpcomingClassWidget(
                                  upcomingClass:
                                      state.homeModel!.data!.upcomingClass!,
                                ),
                              if ((state.homeModel?.data?.banners ?? [])
                                  .isNotEmpty) ...[
                                4.kh,
                                _buildBannerSlider(context, state),
                              ],
                              // _buildQuickFilters(context),
                              if ((state.homeModel?.data?.categories?.data ??
                                      [])
                                  .isNotEmpty)
                                _buildCategoriesSection(context, state),
                              if (state.newClassesList.isNotEmpty)
                                _buildNewClassesSection(context, state),
                              if (state.nearClassesList.isNotEmpty)
                                _buildNearYouSection(context, state),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeBuildable state) {
    final storage = getIt<Storage>();
    final firstName = state.homeModel?.data?.forUser?.firstName
        ?? storage.parentName.call()
        ?? 'User';
    final isPremium = storage.hasPremium() == true;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Container3d(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 14.w, 8.h),
              backgroundColor: Colors.white,
              borderColor: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(30.r),
              depth: 3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PremiumProfileIcon(isPremium: isPremium),
                  10.kw,
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hello'.tr().toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF91A2C3),
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          firstName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E3D5D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (!isPremium) ...[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.router.push(const PlansRoute()),
              child: SizedBox(
                width: 52.w,
                height: 52.w,
                child: Lottie.asset(
                  'assets/lotties/premium.json',
                  repeat: true,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            6.kw,
          ],
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => showLanguageBottomSheet(
              context,
              onChanged: () => context.read<HomeCubit>().getHome(),
            ),
            child: Container3d(
              padding: EdgeInsets.all(8.w),
              backgroundColor: Colors.white,
              borderColor: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(14.r),
              depth: 3,
              child: Icon(
                Icons.translate_rounded,
                size: 18.sp,
                color: const Color(0xFFFF7093),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider(BuildContext context, HomeBuildable state) {
    final banners = state.homeModel?.data?.banners ?? [];
    return _BannerSlider(banners: banners, resolveSrc: _resolveBannerSrc);
  }

  String _resolveBannerSrc(String? url, String? id) {
    final raw = (url ?? '').replaceAll(RegExp(r'\s+'), '').trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    if (raw.isNotEmpty) {
      return '${Constants.assetsUrl}$raw';
    }
    return '${Constants.assetsUrl}${id ?? ''}';
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Container(
            width: 3.w,
            height: 16.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.colors.primary, const Color(0xFFFF7093)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          8.kw,
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1535),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, HomeBuildable state) {
    final categories = state.homeModel?.data?.categories?.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        18.kh,
        _sectionHeader(context, 'all_categories'.tr()),
        12.kh,
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.37,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(bottom: 8.h, right: 16.w),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return CategoryItemWidget(
                homeCategoryModel: categories[index],
                onTap: () {
                  SearchCubit.pendingCategory = categories[index];
                  context.tabsRouter.setActiveIndex(_kSearchTabIndex);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openShorts(BuildContext context, List<HomClass> feed, int index) {
    ShortsFeed.set(feed, index);
    context.tabsRouter.setActiveIndex(_kShortsTabIndex);
  }

  Widget _buildNewClassesSection(BuildContext context, HomeBuildable state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        18.kh,
        _sectionHeader(context, 'newly_added_classes'.tr()),
        12.kh,
        NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 8) {
              context.read<HomeCubit>().loadMoreNewClasses();
            }
            return false;
          },
          child: Builder(
            builder: (context) {
              // Card width tracks the same clamp used inside ClassItemWidget
              // so the row height is in sync on every device.
              final cardW = (1.sw * 0.7).clamp(240.0, 320.0);
              // image is 4:3, plus card padding (8 + 8) and body block (~152)
              final rowH = (cardW * 3 / 4) + 16 + 168.h;
              return SizedBox(
                height: rowH,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(bottom: 8.h, right: 16.w),
                  itemCount: state.newClassesList.length +
                      (state.isLoadingNewClasses ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == state.newClassesList.length) {
                      return Padding(
                        padding: EdgeInsets.only(left: 16.w),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    }
                    return ClassItemWidget(
                      homClass: state.newClassesList[index],
                      wrapBranch: true,
                      onViewAsReels: () =>
                          _openShorts(context, state.newClassesList, index),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _buildQuickFilters(BuildContext context) {
    final filters = [
      ('Bugun', '☀️', const Color(0xFFFFD93D), const Color(0xFFFF6B6B)),
      ('Bu hafta', '📅', const Color(0xFFA8D8EA), const Color(0xFFAA96DA)),
      ('Yaqinda', '📍', const Color(0xFF95E1D3), const Color(0xFF38ADA9)),
      ('Bepul', '🎁', const Color(0xFFFFB4A2), const Color(0xFFE5989B)),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: filters.map((f) {
          return GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: (MediaQuery.of(context).size.width - 32.w - 24.w) / 4,
              child: Column(
                children: [
                  Container(
                    width: 54.w,
                    height: 54.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [f.$3, f.$4],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1A6C4EF2),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(f.$2, style: TextStyle(fontSize: 22.sp)),
                    ),
                  ),
                  6.kh,
                  Text(
                    f.$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1535),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNearYouSection(BuildContext context, HomeBuildable state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        18.kh,
        _sectionHeader(context, 'near_you'.tr()),
        12.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          child: Column(
            children: [
              ...state.nearClassesList.asMap().entries.map((entry) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: ClassItemWidget(
                      homClass: entry.value,
                      width: 1.sw - 32.w,
                      wrapBranch: false,
                      onViewAsReels: () => _openShorts(
                          context, state.nearClassesList, entry.key),
                    ),
                  )),
              if (state.isLoadingNearClasses)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumProfileIcon extends StatelessWidget {
  const _PremiumProfileIcon({required this.isPremium});

  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final circle = Container(
      width: 36.w,
      height: 36.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isPremium
              ? [const Color(0xFFFFD56A), const Color(0xFFFF8A65)]
              : [
                  primary.withOpacity(0.22),
                  const Color(0xFFFF7093).withOpacity(0.22),
                ],
        ),
        boxShadow: isPremium
            ? [
                BoxShadow(
                  color: const Color(0xFFFF8A65).withOpacity(0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.person_rounded,
        size: 20.sp,
        color: isPremium ? Colors.white : primary,
      ),
    );

    if (!isPremium) return circle;

    return SizedBox(
      width: 42.w,
      height: 42.w,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 3.w,
            child: circle,
          ),
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD56A), Color(0xFFFF8A65)],
                  ),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 9.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Banner slider with dot indicators ───────────────────────────────────────

class _BannerSlider extends StatefulWidget {
  const _BannerSlider({
    required this.banners,
    required this.resolveSrc,
  });

  final List<HomBanner> banners;
  final String Function(String?, String?) resolveSrc;

  @override
  State<_BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<_BannerSlider> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 180.h,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, _) =>
                  setState(() => _current = index),
            ),
            items: widget.banners.map((banner) {
              final src = widget.resolveSrc(banner.url, banner.id);
              return ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: CachedNetworkImage(
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: src,
                  placeholder: (_, __) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (_, __, ___) =>
                      Assets.images.defaultImage.image(fit: BoxFit.cover),
                ),
              );
            }).toList(),
          ),
          if (widget.banners.length > 1) ...[
            8.kh,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (i) {
                final active = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: active ? 20.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF6C4EF2)
                        : const Color(0xFFD1C4E9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

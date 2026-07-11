import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/display_name_notifier.dart';
import 'package:lumi_pass/common/widget/auth/gradient_button.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_banners.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_common.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_header.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_skeletons.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/shorts/shorts_feed.dart';

// Tab index of the Shorts tab inside the main AutoTabsScaffold.
const int _kShortsTabIndex = 1;

@RoutePage()
class HomePage extends BasePage<HomeCubit, HomeBuildable, HomeListenable> {
  const HomePage({super.key});

  @override
  void init(BuildContext context) {
    // Seed the header name from storage so it shows immediately before the API loads.
    final storage = getIt<Storage>();
    final stored = storage.parentName.call();
    if (stored != null && stored.isNotEmpty && displayNameNotifier.value == null) {
      displayNameNotifier.value = stored;
    }
    context.read<HomeCubit>().initWithLocation();
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    // Handles language changes AND post-coupon-purchase discount refresh.
    context.read<HomeCubit>().refreshOnFocusGained();
    super.onFocusGained(context);
  }

  @override
  Widget builder(BuildContext context, HomeBuildable state) {
    final c = context.appColors;
    final topInset = MediaQuery.of(context).viewPadding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: c.overlayStyle,
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: topInset + 8.h),
            ValueListenableBuilder<String?>(
              valueListenable: displayNameNotifier,
              builder: (_, nameOverride, __) {
                final storage = getIt<Storage>();
                final name = nameOverride ??
                    state.homeModel?.data?.forUser?.firstName ??
                    storage.parentName.call() ??
                    'User';
                return HomeHeader(
                  name: name,
                  onSearchTap: () =>
                      context.router.push(const SearchComingSoonRoute()),
                );
              },
            ),
            12.verticalSpace,
            Expanded(child: _buildContent(context, state)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeBuildable state) {
    if (state.isLoading) return const HomeShimmer();

    final isEmpty = state.homeModel == null &&
        state.newClassesList.isEmpty &&
        state.nearClassesList.isEmpty;
    if (isEmpty) return _ConnectionErrorView(context.read<HomeCubit>());

    return RefreshIndicator(
      color: AppColors.brandPurple,
      onRefresh: () => context.read<HomeCubit>().getHome(),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (scrollInfo.metrics.axis == Axis.vertical &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 300) {
            context.read<HomeCubit>().loadMoreNearClasses();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: 8.verticalSpace),
            SliverToBoxAdapter(
              child: HomeCouponBanner(
                onTap: () => context.router.push(const PlansRoute()),
              ),
            ),
            if ((state.homeModel?.data?.banners ?? []).isNotEmpty) ...[
              SliverToBoxAdapter(child: 12.verticalSpace),
              SliverToBoxAdapter(
                child: HomeBannerCarousel(
                  banners: state.homeModel!.data!.banners!,
                ),
              ),
            ],
            if (_categories(state).isNotEmpty)
              SliverToBoxAdapter(child: _buildCategories(context, state)),
            if (state.newClassesList.isNotEmpty)
              SliverToBoxAdapter(child: _buildCourses(context, state)),
            // Second "Курсы" row (Figma has two) — reuses the nearby feed.
            if (state.nearClassesList.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildCoursesRow(
                  context,
                  'courses'.tr(),
                  state.nearClassesList,
                ),
              ),
            if (state.nearClassesList.isNotEmpty)
              ..._buildNearYou(context, state),
            // "Реклама" ad card — reuses a real banner image.
            if ((state.homeModel?.data?.banners ?? []).isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: HomeAdCard(
                    imageUrl: _bannerSrc(state.homeModel!.data!.banners!.last),
                    onTap: () => context.router.push(const PlansRoute()),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 24.h +
                    64.0 +
                    MediaQuery.of(context).viewPadding.bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<HomCategory> _categories(HomeBuildable state) =>
      (state.categories?.isNotEmpty == true)
          ? state.categories!
          : (state.homeModel?.data?.categories?.data ?? []);

  Widget _buildCategories(BuildContext context, HomeBuildable state) {
    final categories = _categories(state);
    if (categories.isNotEmpty) SearchCubit.cachedCategories = categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.verticalSpace,
        HomeSectionHeader(
          title: 'all_categories'.tr(),
          onViewAll: () =>
              context.router.push(const SearchComingSoonRoute()),
        ),
        16.verticalSpace,
        SizedBox(
          height: 104.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(right: 16.w),
            itemCount: categories.length,
            itemBuilder: (context, index) => CategoryItemWidget(
              key: ValueKey(categories[index].id ?? index),
              homeCategoryModel: categories[index],
              onTap: () =>
                  context.router.push(const SearchComingSoonRoute()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCourses(BuildContext context, HomeBuildable state) {
    final rowH = 126.h + 14.h + 118.h;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.verticalSpace,
        HomeSectionHeader(title: 'popular_activities'.tr()),
        16.verticalSpace,
        NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.axis == Axis.horizontal &&
                scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 8) {
              context.read<HomeCubit>().loadMoreNewClasses();
            }
            return scrollInfo.metrics.axis == Axis.horizontal;
          },
          child: SizedBox(
            height: rowH,
            child: Stack(
              children: [
                ListView.builder(
                  key: const PageStorageKey('new-classes-list'),
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.only(right: 16.w),
                  itemCount: state.newClassesList.length,
                  itemBuilder: (context, index) => HomeCourseCard(
                    key: ValueKey(state.newClassesList[index].id ?? index),
                    homClass: state.newClassesList[index],
                    onViewAsReels: () =>
                        _openShorts(context, state.newClassesList, index),
                  ),
                ),
                if (state.isLoadingNewClasses)
                  Positioned(
                    right: 16.w,
                    top: 0,
                    bottom: 8.h,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// A generic horizontal "Курсы" row (Figma's second popular section),
  /// reusing whichever activity list is passed in.
  Widget _buildCoursesRow(
      BuildContext context, String title, List<HomClass> list) {
    final rowH = 126.h + 14.h + 118.h;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.verticalSpace,
        HomeSectionHeader(title: title),
        16.verticalSpace,
        SizedBox(
          height: rowH,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(right: 16.w),
            itemCount: list.length,
            itemBuilder: (context, index) => HomeCourseCard(
              key: ValueKey('c2-${list[index].id ?? index}'),
              homClass: list[index],
              onViewAsReels: () => _openShorts(context, list, index),
            ),
          ),
        ),
      ],
    );
  }

  String _bannerSrc(HomBanner banner) {
    final raw = (banner.url ?? '').replaceAll(RegExp(r'\s+'), '').trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.isNotEmpty) return '${Constants.assetsUrl}$raw';
    return '${Constants.assetsUrl}${banner.id ?? ''}';
  }

  List<Widget> _buildNearYou(BuildContext context, HomeBuildable state) {
    return [
      SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            24.verticalSpace,
            HomeSectionHeader(title: 'near_you'.tr()),
            16.verticalSpace,
          ],
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: HomeNearbyCard(
              key: ValueKey(state.nearClassesList[index].id ?? index),
              homClass: state.nearClassesList[index],
              onViewAsReels: () =>
                  _openShorts(context, state.nearClassesList, index),
            ),
          ),
          childCount: state.nearClassesList.length,
        ),
      ),
      if (state.isLoadingNearClasses)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        ),
    ];
  }

  void _openShorts(BuildContext context, List<HomClass> feed, int index) {
    ShortsFeed.set(feed, index);
    context.tabsRouter.setActiveIndex(_kShortsTabIndex);
  }
}

/// "No internet" state (Figma `Ошибка подключения к интернету`).
class _ConnectionErrorView extends StatelessWidget {
  const _ConnectionErrorView(this.cubit);

  final HomeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: c.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.wifi_slash,
                  size: 32.sp, color: c.textSecondary),
            ),
            20.verticalSpace,
            Text(
              'no_internet_title'.tr(),
              textAlign: TextAlign.center,
              style: AppText.bold18.copyWith(color: c.textPrimary),
            ),
            8.verticalSpace,
            Text(
              'no_internet_desc'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular14.copyWith(color: c.textSecondary),
            ),
            28.verticalSpace,
            SizedBox(
              width: 200.w,
              child: GradientButton(
                text: 'retry'.tr(),
                onPressed: () => cubit.getHome(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

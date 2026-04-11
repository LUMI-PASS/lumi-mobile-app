import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';

import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/common/widget/language_bottom_sheet.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/banner_lesson_widgets.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/class_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_skeletons.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class HomePage extends BasePage<HomeCubit, HomeBuildable, HomeListenable> {
  const HomePage({super.key});

  @override
  void init(BuildContext context) {
    context.read<HomeCubit>().initWithLocation();
    super.init(context);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -30,
            left: -50,
            child: Opacity(
              opacity: 0.15,
              child: Assets.icons.background.congratsMisc.svg(
                width: 260.w,
                height: 260.w,
                colorFilter: ColorFilter.mode(
                  context.colors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Column(
        children: [
          // Fixed header
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
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
                      padding: EdgeInsets.only(
                        top: 8.h,
                        bottom: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Upcoming class
                          if (state.homeModel?.data?.upcomingClass != null)
                            UpcomingClassWidget(
                              upcomingClass:
                                  state.homeModel!.data!.upcomingClass!,
                            ),

                          // Banner slider
                          if ((state.homeModel?.data?.banners ?? [])
                              .isNotEmpty) ...[
                            8.kh,
                            _buildBannerSlider(context, state),
                          ],

                          // Categories section
                          if ((state.homeModel?.data?.categories?.data ?? [])
                              .isNotEmpty)
                            _buildCategoriesSection(context, state),

                          // Newly Added Classes section
                          if (state.newClassesList.isNotEmpty)
                            _buildNewClassesSection(context, state),

                          // Near You section
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
    final firstName = state.homeModel?.data?.forUser?.firstName ?? 'User';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container3d(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        backgroundColor: Colors.white,
        borderColor: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.r),
        depth: 3,
        child: Row(
          children: [
            // Avatar with verified badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      colors: [
                        context.colors.primary.withOpacity(0.2),
                        const Color(0xFFFF7093).withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 28.sp,
                    color: context.colors.primary,
                  ),
                ),
                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    width: 18.w,
                    height: 18.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      size: 16.w,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                ),
              ],
            ),
            8.kw,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'hello'.tr().toUpperCase(),
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF91A2C3),
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  firstName,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E3D5D),
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Language button
            GestureDetector(
              onTap: () => showLanguageBottomSheet(
                context,
                onChanged: () => context.read<HomeCubit>().getHome(),
              ),
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7093).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.translate_rounded,
                  size: 20.sp,
                  color: const Color(0xFFFF7093),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlider(BuildContext context, HomeBuildable state) {
    final banners = state.homeModel?.data?.banners ?? [];

    return _BannerCarousel(
      banners: banners,
      resolveSrc: _resolveBannerSrc,
    );
  }

  String _resolveBannerSrc(String? url, String? id) {
    final raw = (url ?? '').trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    if (raw.isNotEmpty) {
      return '${Constants.assetsUrl}$raw';
    }
    return '${Constants.assetsUrl}${id ?? ''}';
  }

  Widget _buildCategoriesSection(BuildContext context, HomeBuildable state) {
    final categories = state.homeModel?.data?.categories?.data ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
          'all_categories'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E3D5D),
          ),
                    ),
        ),
        12.kh,
        SizedBox(
          height: 140.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(bottom: 8.h, right: 16.w),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return CategoryItemWidget(
                homeCategoryModel: categories[index],
                onTap: () {
                  // Set pending category, then switch to Search tab
                  SearchCubit.pendingCategory = categories[index];
                  context.tabsRouter.setActiveIndex(2);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewClassesSection(BuildContext context, HomeBuildable state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
          'newly_added_classes'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E3D5D),
          ),
                    ),
        ),
        12.kh,
        NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 8) {
              context.read<HomeCubit>().loadMoreNewClasses();
            }
            return false;
          },
          child: SizedBox(
            height: 310.h,
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
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNearYouSection(BuildContext context, HomeBuildable state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
          'near_you'.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2E3D5D),
          ),
                    ),
        ),
        12.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          child: Column(
            children: [
              ...state.nearClassesList.map((classItem) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: ClassItemWidget(
                      homClass: classItem,
                      width: 1.sw - 32.w,
                      wrapBranch: false,
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

class _BannerCarousel extends StatefulWidget {
  const _BannerCarousel({
    required this.banners,
    required this.resolveSrc,
  });

  final List<HomBanner> banners;
  final String Function(String?, String?) resolveSrc;

  @override
  State<_BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<_BannerCarousel> {
  int _currentIndex = 0;

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
              onPageChanged: (index, _) {
                setState(() => _currentIndex = index);
              },
            ),
            items: widget.banners.map((banner) {
              final src = widget.resolveSrc(banner.url, banner.id);
              return ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: SizedBox(
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: src,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                    errorWidget: (context, error, stackTrace) =>
                        Assets.images.defaultImage.image(fit: BoxFit.contain),
                  ),
                ),
              );
            }).toList(),
          ),
          if (widget.banners.length > 1) ...[
            10.kh,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: _currentIndex == index ? 20.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? context.colors.primary
                        : context.colors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

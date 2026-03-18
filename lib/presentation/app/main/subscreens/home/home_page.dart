import 'package:auto_route/annotations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/loading_view.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/banner_lesson_widgets.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/catgory_item_widget.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/class_item_widget.dart';

@RoutePage()
class HomePage extends BasePage<HomeCubit, HomeBuildable, HomeListenable> {
  const HomePage({super.key});

  @override
  void init(BuildContext context) {
    context.read<HomeCubit>().getHome();
    super.init(context);
  }

  @override
  Widget builder(context, state) {
    return Scaffold(
      body: state.isLoading
          ? const LoadingView()
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
                  top: MediaQuery.of(context).viewPadding.top + 16.h,
                  bottom: 20.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    _buildHeader(context, state),
                    16.kh,

                    // Upcoming class
                    if (state.homeModel?.data?.upcomingClass != null)
                      UpcomingClassWidget(
                        upcomingClass: state.homeModel!.data!.upcomingClass!,
                      ),

                    // Banner slider
                    if ((state.homeModel?.data?.banners ?? []).isNotEmpty) ...[
                      8.kh,
                      _buildBannerSlider(context, state),
                    ],

                    // Categories section
                    if ((state.homeModel?.data?.categories?.data ?? []).isNotEmpty)
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
    );
  }

  Widget _buildHeader(BuildContext context, HomeBuildable state) {
    final firstName =
        state.homeModel?.data?.forUser?.firstName ?? 'User';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
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
            8.kw,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HELLO',
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
            Container(
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
          ],
        ),
      ),
    );
  }

  Widget _buildBannerSlider(BuildContext context, HomeBuildable state) {
    final banners = state.homeModel?.data?.banners ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: CarouselSlider(
        options: CarouselOptions(
          height: 180.h,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 5),
          viewportFraction: 1.0,
          enlargeCenterPage: false,
        ),
        items: banners.map((banner) {
          final src = _resolveBannerSrc(banner.url, banner.id);
          return ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: CachedNetworkImage(
              width: double.infinity,
              fit: BoxFit.cover,
              imageUrl: src,
              placeholder: (context, url) => Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              errorWidget: (context, error, stackTrace) =>
                  Assets.images.defaultImage.image(fit: BoxFit.cover),
            ),
          );
        }).toList(),
      ),
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              'All Categories',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3D5D),
              ),
            ),
          ),
        ),
        12.kh,
        SizedBox(
          height: 130.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return CategoryItemWidget(
                homeCategoryModel: categories[index],
                onTap: () {
                  // Navigate to explore with category filter
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              'Newly Added Classes',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3D5D),
              ),
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
            height: 300.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              'Near You',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E3D5D),
              ),
            ),
          ),
        ),
        12.kh,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w),
          child: Column(
            children: [
              ...state.nearClassesList.map((classItem) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
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

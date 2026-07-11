import 'package:flutter/material.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Theme-aware shimmer palette for the home loading state.
Color _shimmerBase(BuildContext c) => c.colors.surface;
Color _shimmerHi(BuildContext c) =>
    c.colors.isDark ? const Color(0xFF2E2E35) : Colors.white;

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase(context),
      highlightColor: _shimmerHi(context),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Coupon banner skeleton
            _BannerSkeleton(),
            24.verticalSpace,
            // Categories skeleton
            _SectionTitleSkeleton(),
            12.verticalSpace,
            _CategoriesRowSkeleton(),
            24.verticalSpace,
            // New classes skeleton
            _SectionTitleSkeleton(),
            12.verticalSpace,
            _ClassCardsRowSkeleton(),
            24.verticalSpace,
            // Near you skeleton
            _SectionTitleSkeleton(),
            12.verticalSpace,
            _NearYouListSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _BannerSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: _shimmerBase(context),
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
    );
  }
}

class _SectionTitleSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: 140.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: _shimmerBase(context),
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

class _CategoriesRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return SizedBox(
      height: screenWidth * 0.37,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(left: 16.w),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          width: screenWidth * 0.285,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: _shimmerBase(context),
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      ),
    );
  }
}

class _ClassCardsRowSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.68;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(left: 16.w),
        itemCount: 3,
        itemBuilder: (_, __) => Container(
          width: cardWidth,
          margin: EdgeInsets.only(right: 12.w),
          decoration: BoxDecoration(
            color: _shimmerBase(context),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: _shimmerBase(context),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 160.w,
                        height: 14.h,
                        color: _shimmerBase(context)),
                    SizedBox(height: 8.h),
                    Container(
                        width: 100.w,
                        height: 12.h,
                        color: _shimmerBase(context)),
                    SizedBox(height: 8.h),
                    Container(
                        width: 180.w,
                        height: 12.h,
                        color: _shimmerBase(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearYouListSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: List.generate(
          2,
          (_) => Container(
            width: double.infinity,
            height: 220.h,
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: _shimmerBase(context),
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: _shimmerBase(context),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 200.w,
                          height: 14.h,
                          color: _shimmerBase(context)),
                      SizedBox(height: 8.h),
                      Container(
                          width: 140.w,
                          height: 12.h,
                          color: _shimmerBase(context)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for image loading inside cards
class ShimmerImagePlaceholder extends StatelessWidget {
  const ShimmerImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase(context),
      highlightColor: _shimmerHi(context),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: _shimmerBase(context),
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

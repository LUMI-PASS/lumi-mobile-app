import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner skeleton
            _BannerSkeleton(),
            16.verticalSpace,
            // Upcoming class skeleton
            _UpcomingClassSkeleton(),
            16.verticalSpace,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
      ),
    );
  }
}

class _UpcomingClassSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                    width: 80.w, height: 20.h, color: Colors.white),
                SizedBox(width: 8.w),
                Container(
                    width: 60.w, height: 20.h, color: Colors.white),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
                width: 200.w, height: 22.h, color: Colors.white),
            SizedBox(height: 12.h),
            Container(
                width: 140.w, height: 16.h, color: Colors.white),
            SizedBox(height: 16.h),
            Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ],
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
          color: Colors.white,
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
            color: Colors.white,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        color: Colors.white),
                    SizedBox(height: 8.h),
                    Container(
                        width: 100.w,
                        height: 12.h,
                        color: Colors.white),
                    SizedBox(height: 8.h),
                    Container(
                        width: 180.w,
                        height: 12.h,
                        color: Colors.white),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 160.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                          color: Colors.white),
                      SizedBox(height: 8.h),
                      Container(
                          width: 140.w,
                          height: 12.h,
                          color: Colors.white),
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
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Theme-aware shimmer palette for the home loading state.
Color _shimmerBase(BuildContext c) => c.colors.surface;
Color _shimmerHi(BuildContext c) =>
    c.colors.isDark ? const Color(0xFF2E2E35) : Colors.white;

/// The home feed while its first request is out, drawn in the feed's own
/// shapes — the banner carousel, the two rows of categories, a shelf of small
/// cards and the first full-width cards of "Near you" — so that when the real
/// thing lands nothing on screen moves, it only fills in.
///
/// The sizes are the ones `home_page.dart` lays those sections out with. They
/// are repeated here rather than shared because this is a picture of that
/// layout, not a part of it: a section resized there wants its outline here
/// looked at, not silently dragged along.
class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _shimmerBase(context),
      highlightColor: _shimmerHi(context),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 4.h, bottom: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _CarouselSkeleton(),
            16.verticalSpace,
            const _CategoriesSkeleton(),
            20.verticalSpace,
            const _TitleSkeleton(),
            12.verticalSpace,
            const _ShelfSkeleton(),
            20.verticalSpace,
            const _TitleSkeleton(),
            12.verticalSpace,
            const _FeedCardSkeleton(),
            16.verticalSpace,
            const _FeedCardSkeleton(),
          ],
        ),
      ),
    );
  }
}

/// One block of the skeleton. Every shape in it is this, so they all take the
/// shimmer's colour and none can drift to a paint of its own.
class _Bone extends StatelessWidget {
  const _Bone({this.width, this.height, this.radius = 8});

  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _shimmerBase(context),
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

/// The promo carousel: one banner on the page gutter and the edge of the next.
class _CarouselSkeleton extends StatelessWidget {
  const _CarouselSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 124.h,
      child: OverflowBox(
        alignment: Alignment.centerLeft,
        maxWidth: double.infinity,
        child: Row(
          children: [
            16.horizontalSpace,
            _Bone(width: 1.sw - 32.w, height: 124.h, radius: 12),
            8.horizontalSpace,
            _Bone(width: 1.sw - 32.w, height: 124.h, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// The categories: two rows of five, an icon over a short label.
class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  static const _columns = 5;

  @override
  Widget build(BuildContext context) {
    Widget row() => Row(
          children: [
            for (var i = 0; i < _columns; i++)
              Expanded(
                child: SizedBox(
                  height: 84.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Bone(width: 52.w, height: 52.w, radius: 16),
                      8.verticalSpace,
                      _Bone(width: 44.w, height: 10.h, radius: 5),
                    ],
                  ),
                ),
              ),
          ],
        );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(children: [row(), 4.verticalSpace, row()]),
    );
  }
}

/// A section header.
class _TitleSkeleton extends StatelessWidget {
  const _TitleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: _Bone(width: 180.w, height: 20.h, radius: 10),
    );
  }
}

/// A horizontal shelf of small cards: a photo with three lines under it.
class _ShelfSkeleton extends StatelessWidget {
  const _ShelfSkeleton();

  @override
  Widget build(BuildContext context) {
    final width = 150.w;
    return SizedBox(
      height: 126.h + 14.h + 62.h,
      child: OverflowBox(
        alignment: Alignment.topLeft,
        maxWidth: double.infinity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.horizontalSpace,
            for (var i = 0; i < 3; i++) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bone(width: width, height: 126.h, radius: 16),
                  14.verticalSpace,
                  _Bone(width: width * 0.9, height: 14.h, radius: 7),
                  8.verticalSpace,
                  _Bone(width: width * 0.6, height: 12.h, radius: 6),
                  8.verticalSpace,
                  _Bone(width: width * 0.45, height: 12.h, radius: 6),
                ],
              ),
              12.horizontalSpace,
            ],
          ],
        ),
      ),
    );
  }
}

/// A full-width "Near you" card: the photo, then a title and two lines.
class _FeedCardSkeleton extends StatelessWidget {
  const _FeedCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bone(width: double.infinity, height: 160.h, radius: 20),
          12.verticalSpace,
          _Bone(width: 220.w, height: 16.h, radius: 8),
          8.verticalSpace,
          _Bone(width: 150.w, height: 12.h, radius: 6),
          8.verticalSpace,
          _Bone(width: 100.w, height: 12.h, radius: 6),
        ],
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

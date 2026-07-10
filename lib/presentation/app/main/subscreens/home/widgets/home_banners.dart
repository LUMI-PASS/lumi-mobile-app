import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:shimmer/shimmer.dart';

/// "Скидочные купоны" call-to-action — a green promo card that opens the
/// coupon plans screen (Figma `Discount container`).
class HomeCouponBanner extends StatelessWidget {
  const HomeCouponBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: AppGradients.green,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Stack(
            children: [
              // Decorative circle wash on the right.
              Positioned(
                right: -30.w,
                top: -20.h,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.10),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'coupon_plans_title'.tr(),
                            style: AppText.bold18.copyWith(color: Colors.white),
                          ),
                          6.verticalSpace,
                          Text(
                            'coupon_plans_subtitle'.tr(),
                            style:
                                AppText.regular14.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    12.horizontalSpace,
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.ticket_fill,
                          color: Colors.white, size: 28.sp),
                    ),
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

/// Promo banner carousel driven by the API `banners` (Figma teacher / promo
/// card with dot indicators).
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key, required this.banners});

  final List<HomBanner> banners;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _current = 0;

  String _resolveSrc(String? url, String? id) {
    final raw = (url ?? '').replaceAll(RegExp(r'\s+'), '').trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.isNotEmpty) return '${Constants.assetsUrl}$raw';
    return '${Constants.assetsUrl}${id ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 160.h,
              autoPlay: widget.banners.length > 1,
              autoPlayInterval: const Duration(seconds: 5),
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, _) => setState(() => _current = index),
            ),
            items: widget.banners.map((banner) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  width: double.infinity,
                  fit: BoxFit.cover,
                  imageUrl: _resolveSrc(banner.url, banner.id),
                  placeholder: (_, __) => _placeholder(c),
                  errorWidget: (_, __, ___) => _placeholder(c),
                ),
              );
            }).toList(),
          ),
          if (widget.banners.length > 1) ...[
            10.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.banners.length, (i) {
                final active = i == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: active ? 20.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: active ? AppColors.brandPurple : c.surface,
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

  Widget _placeholder(AppColors c) => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
        child: Container(color: c.surface),
      );
}

/// Full-width advertisement/promo card (Figma home `Реклама`). Reuses a real
/// banner image with a "Реклама" badge overlay.
class HomeAdCard extends StatelessWidget {
  const HomeAdCard({super.key, required this.imageUrl, required this.onTap});

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 140.h,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 140.h,
                  color: context.appColors.surface,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 140.h,
                  color: context.appColors.surface,
                ),
              ),
              Positioned(
                left: 12.w,
                top: 12.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(40.r),
                  ),
                  child: Text('ad_label'.tr(),
                      style: AppText.medium10.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

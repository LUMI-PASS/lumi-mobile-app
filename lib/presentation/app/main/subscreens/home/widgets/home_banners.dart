import 'package:carousel_slider/carousel_slider.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:shimmer/shimmer.dart';

/// "Скидочные купоны" call-to-action — the frosted promo card that opens the
/// coupon plans screen (Figma `Discount container`). Rides as the first page of
/// [HomeBannerCarousel], so it sizes itself to whatever height the slide gives.
class HomeCouponBanner extends StatelessWidget {
  const HomeCouponBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      onTap: onTap,
      padding: EdgeInsets.all(16.w),
      borderWidth: 2,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Green wash behind the ticket, fading out before it reaches the copy.
          Positioned(
            top: -40.h,
            bottom: -40.h,
            right: -60.w,
            width: 240.w,
            child: const DecoratedBox(
              decoration: BoxDecoration(gradient: AppGradients.greenGlow),
            ),
          ),
          // The ticket artwork is already cropped in the asset — it runs off the
          // right edge of the PNG. So it is pushed past the card's right border
          // (`-16` alone would only cancel the padding) for that crop to read as
          // a bleed; inset even slightly, the cut edge floats mid-card and looks
          // broken. The extra width compensates for what the card clips away.
          Positioned(
            top: -12.h,
            bottom: -12.h,
            right: -32.w,
            child: SizedBox(
              width: 190.w,
              child: Assets.images.banner.bannerTicketPercentage.image(
                fit: BoxFit.contain,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: 207.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'coupon_plans_title'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bold18
                        .copyWith(color: context.colors.textPrimary),
                  ),
                  6.verticalSpace,
                  // Flexible: the longer locales must ellipsize, not overflow
                  // the fixed-height carousel slide.
                  Flexible(
                    child: Text(
                      'coupon_plans_subtitle'.tr(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: AppText.regular14
                          .copyWith(color: context.colors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Promo banner carousel — the coupon card first, then the API `banners`
/// (Figma teacher / promo card with dot indicators).
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    super.key,
    required this.banners,
    required this.onCouponTap,
  });

  final List<HomBanner> banners;

  /// Tapping the leading coupon page opens the coupon plans screen.
  final VoidCallback onCouponTap;

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
    final c = context.colors;
    final pages = <Widget>[
      HomeCouponBanner(onTap: widget.onCouponTap),
      ...widget.banners.map((banner) {
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
      }),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 144.h,
              // The banners advance only when the user swipes them.
              autoPlay: false,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              onPageChanged: (index, _) => setState(() => _current = index),
            ),
            items: pages,
          ),
          if (pages.length > 1) ...[
            10.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
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

  Widget _placeholder(AppColorScheme c) => Shimmer.fromColors(
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
                  color: context.colors.surface,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 140.h,
                  color: context.colors.surface,
                ),
              ),
              Positioned(
                left: 12.w,
                top: 12.h,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
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

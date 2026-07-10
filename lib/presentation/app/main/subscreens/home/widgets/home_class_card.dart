import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_common.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';
import 'package:shimmer/shimmer.dart';

/// Compact activity card used in the horizontal "Courses" / "Popular" rows.
/// Matches Figma `Popular item container` (image → provider → title → price).
class HomeCourseCard extends StatelessWidget {
  const HomeCourseCard({
    super.key,
    required this.homClass,
    this.width,
    this.margin,
    this.imageHeight,
    this.onViewAsReels,
  });

  final HomClass? homClass;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final double? imageHeight;
  final VoidCallback? onViewAsReels;

  @override
  Widget build(BuildContext context) {
    final hc = homClass;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.router
          .push(ClassDetailRoute(classModel: hc ?? const HomClass())),
      child: Container(
        width: width ?? 168.w,
        margin: margin ?? EdgeInsets.only(left: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ClassImage(
              imageUrl: sanitizeImageUrl(hc?.image),
              height: imageHeight ?? 126.h,
              category: hc?.category,
              discountPercentage: hc?.discountPercentage ?? 0,
              onViewAsReels: onViewAsReels,
            ),
            14.verticalSpace,
            _ClassInfo(hc: hc, crossAxis: CrossAxisAlignment.start),
          ],
        ),
      ),
    );
  }
}

/// Full-width activity card used in the "Near you" list.
/// Matches Figma `Nearby item container`.
class HomeNearbyCard extends StatelessWidget {
  const HomeNearbyCard({
    super.key,
    required this.homClass,
    this.onViewAsReels,
  });

  final HomClass? homClass;
  final VoidCallback? onViewAsReels;

  @override
  Widget build(BuildContext context) {
    final hc = homClass;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.router
          .push(ClassDetailRoute(classModel: hc ?? const HomClass())),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ClassImage(
              imageUrl: sanitizeImageUrl(hc?.image),
              height: 160.h,
              category: hc?.category,
              discountPercentage: hc?.discountPercentage ?? 0,
              onViewAsReels: onViewAsReels,
            ),
            14.verticalSpace,
            _ClassInfo(hc: hc, crossAxis: CrossAxisAlignment.start),
          ],
        ),
      ),
    );
  }
}

// ── Shared building blocks ───────────────────────────────────────────────────

class _ClassImage extends StatelessWidget {
  const _ClassImage({
    required this.imageUrl,
    required this.height,
    required this.category,
    required this.discountPercentage,
    required this.onViewAsReels,
  });

  final String? imageUrl;
  final double height;
  final String? category;
  final int discountPercentage;
  final VoidCallback? onViewAsReels;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final firstCategory = (category ?? '')
        .split(',')
        .map((s) => s.trim())
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Shimmer.fromColors(
              baseColor: c.surface,
              highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
              child: Container(color: c.surface),
            ),
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            // Category + promo badges, top-left.
            Positioned(
              left: 8.w,
              top: 8.h,
              right: 44.w,
              child: Wrap(
                spacing: 4.w,
                runSpacing: 4.h,
                children: [
                  if (firstCategory.isNotEmpty)
                    HomePillTag(
                      label: firstCategory,
                      leading: const HomeIcon(HomeIcon.book,
                          size: 12, color: Colors.white),
                      gradient: AppGradients.indigo,
                    ),
                  if (discountPercentage > 0)
                    HomePillTag(
                      label: 'sale'.tr(),
                      leading: const HomeIcon(HomeIcon.flash,
                          size: 12, color: Colors.white),
                      color: AppColors.error,
                    ),
                ],
              ),
            ),
            // Reels shortcut, top-right.
            if (onViewAsReels != null)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onViewAsReels,
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: const BoxDecoration(
                      gradient: AppGradients.brand,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 18.sp),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClassInfo extends StatelessWidget {
  const _ClassInfo({required this.hc, required this.crossAxis});

  final HomClass? hc;
  final CrossAxisAlignment crossAxis;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final provider = hc?.branch?.title;
    final address = hc?.branch?.address;

    return Column(
      crossAxisAlignment: crossAxis,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (provider != null && provider.isNotEmpty) ...[
          HomePillTag(label: provider, gradient: AppGradients.green),
          6.verticalSpace,
        ],
        Text(
          hc?.title ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.semibold16.copyWith(color: c.textPrimary),
        ),
        if (address != null && address.isNotEmpty) ...[
          6.verticalSpace,
          Text(
            address,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.regular12.copyWith(color: c.textSecondary),
          ),
        ],
        6.verticalSpace,
        _PriceText(hc: hc),
      ],
    );
  }
}

/// Price line — mirrors the effective-price + coupon-discount logic used
/// elsewhere, rendered in the redesigned typography.
class _PriceText extends StatelessWidget {
  const _PriceText({required this.hc});

  final HomClass? hc;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final snap = ClassPricingCache.get(hc?.id);
    final hasFreeAndPaid =
        snap != null && snap.priceMin == 0 && snap.priceMinPaid > 0;
    final effectivePrice = hasFreeAndPaid
        ? snap.priceMinPaid
        : (snap != null && snap.priceMin > 0)
            ? snap.priceMin
            : (hc?.price ?? 0);
    final showFrom = hasFreeAndPaid ||
        (snap != null && (snap.hasMultiplePrices || snap.rangeCount > 1));

    final baseStyle = AppText.semibold14.copyWith(color: c.textPrimary);

    if (effectivePrice < 100) {
      return Text('price_free'.tr(), style: baseStyle);
    }

    String label(num v) => showFrom
        ? 'price_from'.tr(args: [v.toRawUzsPrice()])
        : v.toRawUzsPrice();

    final storage = getIt<Storage>();
    final planPct = storage.planDiscountPercentage() ?? 0;
    final hasPremium = storage.hasPremium() == true;
    if (!hasPremium || planPct <= 0) {
      return Text(label(effectivePrice), style: baseStyle);
    }

    final discounted = effectivePrice * (1 - planPct / 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label(effectivePrice),
          style: AppText.regular12.copyWith(
            color: c.textMuted,
            decoration: TextDecoration.lineThrough,
            decorationColor: c.textMuted,
          ),
        ),
        Text(
          label(discounted),
          style: AppText.semibold14.copyWith(color: AppColors.badgeGreen),
        ),
      ],
    );
  }
}

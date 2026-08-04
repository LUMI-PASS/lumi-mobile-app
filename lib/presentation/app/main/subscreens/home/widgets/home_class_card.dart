import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/coupon_discount.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/cubit/app_cubit.dart';
import 'package:lumi_pass/presentation/app/cubit/app_state.dart';
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
      onTap: () {
        final c = hc ?? const HomClass();
        // Courses reuse the class detail screen + booking flow — no separate UI.
        context.router.push(ClassDetailRoute(classModel: c));
      },
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
      onTap: () {
        final c = hc ?? const HomClass();
        // Courses reuse the class detail screen + booking flow — no separate UI.
        context.router.push(ClassDetailRoute(classModel: c));
      },
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
              fit: BoxFit.cover,
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
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final double height;
  final String? category;
  final int discountPercentage;
  final VoidCallback? onViewAsReels;

  /// [BoxFit.cover] fills the frame but crops whatever doesn't fit.
  ///
  /// [BoxFit.contain] shows the whole photo instead — activity photos are not
  /// shot to a fixed ratio, and the wide "Near you" cards were cropping real
  /// content out of them. It would normally letterbox, so the gaps are filled
  /// with a blurred, zoomed copy of the same photo (see [_BlurredFill]): the
  /// frame still reads as full-bleed, and nothing is cut off.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
            // The frame the photo is laid into. It only shows through where the
            // photo doesn't reach, and under `contain` the blurred fill covers
            // that anyway — but it keeps the frame from flashing empty. The
            // shimmer that used to sit here would have pulsed forever in the
            // margins; it now runs as the loading placeholder only.
            ColoredBox(color: c.surface),
            if (imageUrl != null) ...[
              if (fit == BoxFit.contain)
                _BlurredFill(imageUrl: imageUrl!, isDark: c.isDark),
              CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: fit,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: c.surface,
                  highlightColor:
                      c.isDark ? const Color(0xFF2E2E35) : Colors.white,
                  child: Container(color: c.surface),
                ),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ],
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
                      leading: HomeIcon(Assets.icons.home.book,
                          size: 12, color: Colors.white),
                      gradient: AppGradients.indigo,
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

/// Fills the frame behind a `contain`-fitted photo with a blurred, zoomed copy
/// of that same photo, so the card reads as full-bleed instead of letterboxed.
///
/// It is decoration, not content: the sharp photo on top is the real subject,
/// so this decodes small (the blur destroys the detail anyway, and a full-res
/// second decode of every card would be pure waste) and is dimmed so it never
/// competes with the photo or with the badges sitting on top of it.
class _BlurredFill extends StatelessWidget {
  const _BlurredFill({required this.imageUrl, required this.isDark});

  final String imageUrl;
  final bool isDark;

  /// Decode width of the backdrop copy. Small on purpose — see above.
  static const _decodeWidth = 64;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          memCacheWidth: _decodeWidth,
          // Same URL as the sharp copy, but a different decode size — without
          // its own cache key the two would fight over one ImageCache entry and
          // each evict the other on every rebuild.
          cacheKey: '$imageUrl@blur',
          fadeInDuration: Duration.zero,
          // No placeholder: the surface underneath already covers the gap, and
          // a shimmer here would show through the blur as a pulsing smear.
          errorWidget: (_, __, ___) => const SizedBox.shrink(),
          color: (isDark ? AppColors.ink : Colors.white)
              .withValues(alpha: isDark ? 0.30 : 0.20),
          colorBlendMode: BlendMode.srcATop,
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
    final c = context.colors;
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
    final c = context.colors;
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

    final app = context.watch<AppCubit>().state.buildable ?? const AppBuildable();
    // The coupon can't cut deeper than Lumi's share of this class, so the
    // preview is capped the same way the charge will be.
    final planPct = effectiveCouponPercent(
      app.hasPremium ? app.planDiscountPercentage : 0,
      hc?.discountPercentage,
      isCourse: hc?.isCourse ?? false,
    );
    if (planPct <= 0) {
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
          style: AppText.semibold14.copyWith(color: AppColors.green),
        ),
      ],
    );
  }
}

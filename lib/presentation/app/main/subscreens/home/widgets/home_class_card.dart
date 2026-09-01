import 'package:auto_route/auto_route.dart';
import 'dart:ui';

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
import 'package:lumi_pass/common/styles/app_shadows.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/utils/coupon_discount.dart';
import 'package:lumi_pass/common/utils/image_url.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/common/widget/distance_label.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/home_model/course_price_kind.dart';
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
    this.showDistance = true,
  });

  final HomClass? homClass;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final double? imageHeight;
  final VoidCallback? onViewAsReels;

  /// Whether the card carries its "1.2 km from you" line.
  ///
  /// Off for the horizontal rows on home. Those cards are a browsing shelf —
  /// they answer "what is there", and the row is already ordered for the user;
  /// a distance on each one is a number to compare against nothing, since only
  /// three cards are on screen at a time. It earns its place where the user is
  /// CHOOSING between everything at once: the "Near you" list, the see-all
  /// grid, search results and a centre's own class list.
  final bool showDistance;

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
            _ClassInfo(
              hc: hc,
              crossAxis: CrossAxisAlignment.start,
              showDistance: showDistance,
            ),
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
    // Each entry is its own raised surface rather than a slice of the page.
    // These cards are full-bleed photo over text stacked straight down the
    // feed, so without an edge the next photo read as part of the previous
    // card's price line. The frosted fill plus [AppShadows.card] draws that
    // edge — which is what the hairline rule between entries used to do, and
    // why `_buildNearYou` no longer has one.
    return FrostedCard(
      onTap: () => context.router
          .push(ClassDetailRoute(classModel: hc ?? const HomClass())),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      // The photo runs full-bleed to the card's edges: no padding on top or
      // the sides, only the bottom strip that separates it from the text.
      padding: EdgeInsets.only(bottom: 8.h),
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: AppShadows.card,
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
            // Flush with the card, so the photo takes the card's own top
            // corners instead of leaving the fill showing through at 12.
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          12.verticalSpace,
          // The card no longer pads its sides, so the text carries the whole
          // inset itself — flush against the edge it read as crowded into the
          // corner.
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 4.h),
            child: _ClassInfo(
              hc: hc,
              crossAxis: CrossAxisAlignment.start,
              branchInline: true,
            ),
          ),
        ],
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
    this.borderRadius,
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

  /// Corner radius of the photo frame. Defaults to `BorderRadius.circular(12.r)`
  /// — the inset look; pass the card's own radius when the photo sits flush
  /// against its edges.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final firstCategory = (category ?? '')
        .split(',')
        .map((s) => s.trim())
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(12.r),
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
  const _ClassInfo({
    required this.hc,
    required this.crossAxis,
    this.branchInline = false,
    this.showDistance = true,
  });

  final HomClass? hc;
  final CrossAxisAlignment crossAxis;

  /// Put the centre's name and its address on ONE line, under the title.
  ///
  /// They answer the same question — *where is this* — so on the full-width
  /// card they read as one fact, and stacking them spent three lines on it
  /// while pushing the price further from the title. Off by default: the
  /// compact card in the horizontal rows is 168pt wide, where a chip and a
  /// street address on one line would leave a couple of characters of each.
  final bool branchInline;

  /// See [HomeCourseCard.showDistance].
  final bool showDistance;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final provider = hc?.branch?.title;
    final address = hc?.branch?.address;
    final hasProvider = provider != null && provider.isNotEmpty;
    final hasAddress = address != null && address.isNotEmpty;
    final lat = hc?.branch?.latitude;
    final lng = hc?.branch?.longitude;

    // Every card in the app runs through here, so the distance line lands on
    // all of them at once: the home rows, the "Near you" list, the see-all
    // grid, search results and the branch page. Watched rather than read: the
    // fix arrives after the first cards are already on screen (home asks for
    // the permission only once the feed has rendered), and without this they
    // would sit there distance-less until something else rebuilt them.
    return ValueListenableBuilder<UserLocation?>(
      valueListenable: currentUserLocation,
      builder: (context, _, __) {
        // Laid out around, not merely appended: the row has to know whether to
        // spend a gap on the distance — and how much width the address is left
        // with — before it can place either. Null when there is nothing honest
        // to show; see [DistanceLabel].
        final hasDistance =
            showDistance && DistanceLabel.labelFor(lat, lng) != null;

        final addressText = hasAddress
            ? Text(
                address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.regular12.copyWith(color: c.textSecondary),
              )
            : null;

        final distance =
            hasDistance ? DistanceLabel(latitude: lat, longitude: lng) : null;

        // WHERE the distance sits differs by card, because the two cards have
        // different amounts of room.
        //
        // The full-width "Near you" card puts it on the PRICE row. Its centre
        // pill and street address already fill that line, and a distance
        // crowded onto the end of them read as a third fragment of the same
        // sentence. On the price row it is the only other thing there, so it
        // reads as its own fact — and price and distance are the two figures
        // someone actually scans a card for, which makes them worth landing on
        // one line.
        //
        // The 168pt compact card keeps it on the address line: its price line
        // is the narrowest thing on the card and can already run to two lines
        // (a struck original over a couponed figure), so a distance beside it
        // would be squeezed against a moving target.
        final Widget? whereDistance = branchInline ? null : distance;
        final Widget? priceDistance = branchInline ? distance : null;

        final hasWhere = addressText != null || whereDistance != null;

        // Address and distance answer the same question — *where is this* — so
        // on the compact card they share one line, with the distance pinned to
        // the right edge. The address gives way when the two don't fit: how far
        // away a centre is decides whether the card is worth reading at all,
        // while the street name only confirms it.
        //
        // Whatever sits to the LEFT of the distance is the row's only flex
        // child, so it absorbs every spare pixel and the distance lands hard
        // against the edge. A [Spacer] stands in when there is no address at
        // all, or the distance would sit wherever the text left it.
        final Widget? whereLine = !hasWhere
            ? null
            : Row(
                children: [
                  if (addressText != null)
                    Expanded(child: addressText)
                  else
                    const Spacer(),
                  if (whereDistance != null) ...[
                    6.horizontalSpace,
                    whereDistance,
                  ],
                ],
              );

        // The price, with the distance pinned to the card's right edge beside
        // it. Centred rather than baseline-aligned: the price block is one
        // line most of the time but two when a coupon struck a figure out, or
        // when a course prints its per-lesson breakdown — and neither of those
        // second lines is the one the distance should pair with, so it sits
        // against the block as a whole.
        final Widget priceLine = priceDistance == null
            ? _PriceText(hc: hc)
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _PriceText(hc: hc)),
                  6.horizontalSpace,
                  priceDistance,
                ],
              );

        return Column(
          crossAxisAlignment: crossAxis,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasProvider && !branchInline) ...[
              HomePillTag(label: provider, gradient: AppGradients.green),
              6.verticalSpace,
            ],
            Text(
              hc?.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
            if (branchInline && (hasProvider || hasWhere)) ...[
              6.verticalSpace,
              // Measured, because the pill must take what its label needs and
              // NOT a fixed share.
              //
              // As two flex siblings the pill and the address split the row
              // evenly, so the address was cut off halfway across the card
              // however short the centre name was — half the width sat unused
              // between them. The pill is now an ordinary child sized to its
              // own text, which leaves the address as the only flex child and
              // hands it the entire remainder.
              LayoutBuilder(
                builder: (context, constraints) => Row(
                  children: [
                    if (hasProvider)
                      ConstrainedBox(
                        // The cap only matters for a centre name long enough
                        // to crowd the address out; under it the pill is at its
                        // natural width. [HomePillTag] ellipsizes its own label
                        // once bounded, so this can never overflow the row.
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth * 0.45,
                        ),
                        child: HomePillTag(
                          label: provider,
                          gradient: AppGradients.green,
                        ),
                      ),
                    if (hasProvider && addressText != null) 6.horizontalSpace,
                    if (addressText != null) Expanded(child: addressText),
                  ],
                ),
              ),
            ] else if (whereLine != null) ...[
              6.verticalSpace,
              whereLine,
            ],
            6.verticalSpace,
            priceLine,
          ],
        );
      },
    );
  }
}

/// Price line for a COURSE.
///
/// A course is not sold per session, so it gets its own line: the card offers
/// ONE lesson to try, and only falls back to the whole course price once there
/// is nothing left to try. Which of those it is — and at what price — is
/// decided by the server per user (see [CoursePriceKind]), because the same
/// rules govern what checkout will charge; the card only words the verdict.
///
/// A card shows ONE price, and it is the one being offered. A trial headline
/// stands alone; only the whole-course headline carries a second line, breaking
/// its own figure down per lesson.
///
/// A coupon plan discounts a TRIAL headline — a trial is one lesson bought one
/// at a time, the shape the plan is sold against — and never a whole-course
/// one. So the struck-through price appears here only while the card is still
/// offering a trial. See `effectiveCouponPercent`.
class _CoursePriceText extends StatelessWidget {
  const _CoursePriceText({required this.hc});

  final HomClass hc;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final kind = hc.coursePriceKind;
    final price = hc.cardPrice ?? hc.coursePrice ?? 0;

    /// The headline for a given figure. Taken as a parameter rather than closed
    /// over one, because a coupon has to word the SAME offer around a different
    /// number — "Try for 35 000" is the offer, 50 000 is only what it replaces.
    String labelFor(num value) {
      final money = value.toRawUzsPrice();
      if (hc.priceFrom == true && kind != CoursePriceKind.trialFree) {
        // A levelled course has no single card price. The server sends the
        // cheapest eligible level, so keep the existing "From" treatment rather
        // than presenting that floor as the price of every level.
        return 'price_from'.tr(args: [money]);
      }
      switch (kind) {
        case CoursePriceKind.trialFree:
          // "First lesson" only reads right for the first one — someone who
          // has already been to one is being offered their next.
          return (hc.trialLessonNo ?? 1) <= 1
              ? 'course_card_try_free'.tr()
              : 'course_card_try_next_free'.tr();
        case CoursePriceKind.trial:
          return 'course_card_try_for'.tr(namedArgs: {'price': money});
        case CoursePriceKind.trialNext:
          return 'course_card_next_lesson'.tr(namedArgs: {'price': money});
        case CoursePriceKind.full:
          // Nothing left to try, so there is no offer left to word — the course
          // price IS the price. A "Whole course —" prefix only competed with
          // the figure beside it for the same single line.
          return money;
        case CoursePriceKind.unknown:
          // A kind this build doesn't model yet: print the figure and nothing
          // around it. Wrong in emphasis, never wrong in money.
          return money;
      }
    }

    // Only a trial headline can carry one — `showsWholeCoursePrice` is what
    // keeps the whole-course price out of it, and the cap is Lumi's share of
    // this course, so the card previews what checkout will charge.
    final app =
        context.watch<AppCubit>().state.buildable ?? const AppBuildable();
    final couponPct = effectiveCouponPercent(
      app.hasPremium ? app.planDiscountPercentage : 0,
      hc.discountPercentage,
      isWholeCourse: hc.showsWholeCoursePrice,
    );
    // A free first lesson has nothing left to discount.
    final num? discounted = couponPct > 0 && price > 0
        ? (price * (100 - couponPct) / 100).round()
        : null;
    final label = labelFor(discounted ?? price);

    // The figure the headline ISN'T showing.
    //
    // Under a TRIAL headline that used to be the whole-course price. It is gone
    // on purpose: a card's job is to get someone to try the course, and pinning
    // the full commitment under a free or cheap first lesson argues against the
    // offer being made right above it. The whole price belongs on the detail
    // screen, where someone is actually deciding.
    //
    // Under a whole-course headline the per-lesson figure stays — there the
    // number IS the ask, and breaking it down makes it easier to judge.
    final String? context2 = kind.isTrial
        ? null
        : ((hc.perLessonPrice ?? 0) > 0
            ? 'course_card_per_lesson'
                .tr(namedArgs: {'price': hc.perLessonPrice!.toRawUzsPrice()})
            : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // What the coupon took off, above the offer it changed — the same
        // struck-original-then-green-figure shape a class card uses.
        if (discounted != null)
          Text(
            price.toRawUzsPrice(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.regular12.copyWith(
              color: c.textMuted,
              decoration: TextDecoration.lineThrough,
              decorationColor: c.textMuted,
            ),
          ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.semibold14.copyWith(
            // A free lesson is the one thing on this card worth a colour — and
            // so is a couponed one, for the same reason.
            color: kind == CoursePriceKind.trialFree || discounted != null
                ? AppColors.green
                : c.textPrimary,
          ),
        ),
        if (context2 != null) ...[
          2.verticalSpace,
          Text(
            context2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.regular12.copyWith(color: c.textSecondary),
          ),
        ],
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

    // A course isn't priced per session, so none of the per-session machinery
    // below applies to it — it has its own line. See [_CoursePriceText].
    if (hc?.isCourse == true) return _CoursePriceText(hc: hc!);

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

    final app =
        context.watch<AppCubit>().state.buildable ?? const AppBuildable();
    // The coupon can't cut deeper than Lumi's share of this class, so the
    // preview is capped the same way the charge will be.
    final planPct = effectiveCouponPercent(
      app.hasPremium ? app.planDiscountPercentage : 0,
      hc?.discountPercentage,
      isWholeCourse: hc?.showsWholeCoursePrice ?? false,
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

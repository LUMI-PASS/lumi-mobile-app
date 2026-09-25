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
import 'package:lumi_pass/common/router/app_link_opener.dart';
import 'package:lumi_pass/common/router/deep_link_log.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/interest_source.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';
import 'package:lumi_pass/domain/repo/promo/promo_repository.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/banners/banner_click_reporter.dart';
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

/// The **Lumi Start** call-to-action — the packet promo, on the home carousel.
///
/// Deliberately nothing like [HomeCouponBanner] beside it. That one is a frosted
/// white card with a ticket; two pale cards with a picture on the right and copy
/// on the left read as the same offer twice, and the reader swipes past both. So
/// this is a saturated purple slide with white type, its own mascot art and the
/// price as a pill — different at a glance, before a single word is read.
///
/// **Its layout cannot clip.** The first version stacked a badge, a two-line
/// title and a subtitle in a `Column` inside a slide fixed at 144dp; the title
/// wrapping was enough to push the subtitle to zero height, and the copy simply
/// vanished. Everything here is either a single ellipsized line or in a
/// `Flexible`, and the art is a fixed-width sibling rather than a `Positioned`
/// that the text has to dodge.
///
/// Loads the campaign itself. The price and the counts are server-driven — the
/// whole point of not hardcoding 99 000 — and the home feed does not carry
/// promo campaigns, so one small public GET is the honest way to get them. It
/// also lets the slide REMOVE itself when nothing is on sale, instead of
/// advertising a screen with an empty state on it.
class HomeAksiyaBanner extends StatelessWidget {
  const HomeAksiyaBanner({
    super.key,
    required this.campaign,
    required this.onTap,
  });

  /// The packet on sale. The carousel loads it and only builds this slide when
  /// there is one, so there is no absent case to render — an empty widget would
  /// still hold a slot and a dot in the carousel, which is a blank page the
  /// reader can swipe to.
  final PromoCampaign campaign;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final held = campaign.heldPass;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      // `ClipRect`, not `ClipRRect`: the slide now runs to both screen edges, and
      // a corner radius with no margin to round against reads as a rendering
      // fault rather than as a card. Clipping is still needed — the discs and
      // the mascot deliberately overflow.
      child: ClipRect(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.brand),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Two soft discs, bottom-right, under everything. Cheap depth that
              // needs no asset and cannot mis-scale on a narrow phone.
              Positioned(
                right: -30.w,
                bottom: -40.h,
                child: _Disc(size: 130.w, opacity: 0.14),
              ),
              Positioned(
                right: 46.w,
                top: -34.h,
                child: _Disc(size: 78.w, opacity: 0.10),
              ),
              // Copy and art as SIBLINGS in a Row, never as a `Positioned`
              // over a padded block.
              //
              // The art used to be positioned against the right edge with only
              // its height constrained, so `BoxFit.contain` sized its width from
              // the asset's aspect ratio — about as wide as the slide is tall,
              // which was wider than the inset reserved for it. The subtitle ran
              // underneath the mascot and was unreadable. Reserving "enough"
              // padding is a guess that has to be re-made every time the art,
              // the height or the asset changes; a Row cannot overlap at all.
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      // 16 on the left is the app's own gutter, so the copy
                      // lines up with the section headings below it now that
                      // the slide runs to the screen edge.
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 12.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: AppColors.onBrand.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(40.r),
                            ),
                            child: Text(
                              campaign.badge?.isNotEmpty == true
                                  ? campaign.badge!
                                  : 'aksiya_badge'.tr(),
                              maxLines: 1,
                              style: AppText.bold10
                                  .copyWith(color: AppColors.onBrand),
                            ),
                          ),
                          6.verticalSpace,
                          // The packet's NAME. One line, ellipsized — the reason the
                          // copy disappeared last time was a title allowed to wrap.
                          Text(
                            campaign.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.bold18
                                .copyWith(color: AppColors.onBrand),
                          ),
                          4.verticalSpace,
                          Flexible(
                            child: Text(
                              held != null
                                  // Already owns it: the slide stops selling and says
                                  // what is left, which is the only thing they want
                                  // from it.
                                  ? 'promo_included_left'.tr(
                                      namedArgs: {
                                        'count': '${held.activitiesLeft}'
                                      },
                                    )
                                  : 'aksiya_hero_visits'.tr(namedArgs: {
                                      'count': '${campaign.activitiesCount}',
                                    }),
                              // One line. The badge, the title, this and the
                              // price pill together come to within a point or
                              // two of the slide's fixed 144dp, so a second
                              // line here is what overflows it — and the full
                              // width gives this sentence more than enough
                              // room on one.
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.regular12.copyWith(
                                color: AppColors.onBrand.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                          if (held == null) ...[
                            6.verticalSpace,
                            // The price, as the one solid white element on the slide —
                            // it is what the offer is, and the figure comes off the
                            // campaign so it can never go stale against the server.
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: AppColors.onBrand,
                                borderRadius: BorderRadius.circular(40.r),
                              ),
                              child: Text(
                                campaign.price.toRawUzsPrice(),
                                maxLines: 1,
                                style: AppText.bold16
                                    .copyWith(color: AppColors.brandPurple),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // A fixed slot the mascot fills. Wide enough to read at a
                  // glance, and bounded so it can never grow into the copy.
                  SizedBox(
                    width: 128.w,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Assets.images.mascot.mascotHello.image(
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A translucent white circle. Decoration only.
class _Disc extends StatelessWidget {
  const _Disc({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.onBrand.withValues(alpha: opacity),
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
    required this.onAksiyaTap,
  });

  final List<HomBanner> banners;

  /// Tapping the leading coupon page opens the coupon plans screen.
  final VoidCallback onCouponTap;

  /// Tapping the "аксия" page opens the bundle screen.
  final VoidCallback onAksiyaTap;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _current = 0;

  /// The packet slide's content, or null while it loads and when nothing is on
  /// sale. Held HERE rather than in the slide because it decides whether the
  /// slide exists at all, and that is the carousel's business: a page that
  /// renders nothing still takes a swipe and a dot.
  PromoCampaign? _packet;

  @override
  void initState() {
    super.initState();
    _loadPacket();
  }

  Future<void> _loadPacket() async {
    try {
      final all = await getIt<PromoRepository>().getCampaigns();
      if (!mounted) return;
      setState(() => _packet = all.isEmpty ? null : all.first);
    } catch (_) {
      // Leave it out. Advertising a screen we could not read is worse than one
      // slide fewer, and the carousel has real banners either side of it.
    }
  }

  String _resolveSrc(String? url, String? id) {
    final raw = (url ?? '').replaceAll(RegExp(r'\s+'), '').trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.isNotEmpty) return '${Constants.assetsUrl}$raw';
    return '${Constants.assetsUrl}${id ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final packet = _packet;
    final pages = <Widget>[
      // The packet leads: it is the offer with a deadline on it, and the one a
      // first-time visitor is most likely to act on. Absent entirely until it
      // has loaded, so the carousel never holds a dot for a blank page.
      if (packet != null)
        HomeAksiyaBanner(campaign: packet, onTap: widget.onAksiyaTap),
      // Kept inset while its siblings are full-bleed, and deliberately: it is a
      // BORDERED card, and a 2px white border running into the screen edge
      // reads as a card that has been cut off rather than one that fills the
      // width. Its own padding, so the change stops at the one page that needs
      // it.
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: HomeCouponBanner(onTap: widget.onCouponTap),
      ),
      ...widget.banners.map((banner) {
        // No radius: these span the full width now, and `BoxFit.cover` already
        // fills the slide. Rounding an edge that touches the screen border only
        // exposes the background behind the corner.
        final image = CachedNetworkImage(
          width: double.infinity,
          fit: BoxFit.cover,
          imageUrl: _resolveSrc(banner.url, banner.id),
          placeholder: (_, __) => _placeholder(c),
          errorWidget: (_, __, ___) => _placeholder(c),
        );

        // A banner with no link configured stays exactly as it was: a picture.
        // Wrapping it in a tap target that does nothing would be worse than
        // not having one.
        if (!banner.hasLink) return image;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => openBanner(
            banner,
            placement: BannerPlacement.homeCarousel,
          ),
          child: image,
        );
      }),
    ];

    // No horizontal padding: the slides run the full width of the screen. Pages
    // that cannot take that (the bordered coupon card) pad themselves.
    return Column(
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
    );
  }

  Widget _placeholder(AppColorScheme c) => Shimmer.fromColors(
        baseColor: c.surface,
        highlightColor: c.isDark ? const Color(0xFF2E2E35) : Colors.white,
        child: Container(color: c.surface),
      );
}

/// Records the tap, then opens the banner's link.
///
/// The two run in PARALLEL, never in sequence: [BannerClickReporter.report]
/// returns immediately, so a slow or failed network call can neither delay
/// opening the link nor stop it. Tracking is the side effect; navigating is
/// the job.
void openBanner(HomBanner banner, {required String placement}) {
  dlog('=== BANNER TAP: id=${banner.id} placement=$placement '
      'link="${banner.link}"');
  getIt<BannerClickReporter>().report(banner.id, placement: placement);
  AppLinkOpener.open(banner.link!, source: InterestSource.banner);
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

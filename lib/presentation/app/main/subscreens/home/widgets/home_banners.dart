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
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/interest_source.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/banners/banner_click_reporter.dart';
import 'package:shimmer/shimmer.dart';

/// The **Lumi Start** call-to-action — the packet promo, on the home carousel.
///
/// Deliberately nothing like the picture banners beside it: a flat image reads
/// as stock art and the reader swipes past it. So this is a saturated purple
/// slide with white type, its own mascot art and the price as a pill —
/// different at a glance, before a single word is read.
///
/// **Its layout cannot clip.** The first version stacked a badge, a two-line
/// title and a subtitle in a `Column` inside a slide fixed at 144dp; the title
/// wrapping was enough to push the subtitle to zero height, and the copy simply
/// vanished. Everything here is either a single ellipsized line or in a
/// `Flexible`, and the art is a fixed-width sibling rather than a `Positioned`
/// that the text has to dodge.
///
/// Every figure is server-driven — the whole point of not hardcoding 99 000.
/// `HomeCubit` fetches the campaign (the home feed does not carry promo
/// campaigns, so it takes one small public GET of its own) and the slots that
/// advertise it simply don't render when nothing is on sale, rather than
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
      // Same radius as the picture banners beside it. They are pages of ONE
      // carousel, so anything that differs between them — a corner, an inset —
      // reads as a jump when you swipe from one to the other.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
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

/// Promo banner carousel — the packet slide first, then the API `banners`.
/// No dot indicators: the next banner peeking in at the edge marks the swipe.
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    super.key,
    required this.banners,
    required this.onAksiyaTap,
    this.packet,
  });

  final List<HomBanner> banners;

  /// The packet on sale, or null while it loads and when there is none. It
  /// decides whether the packet slide exists AT ALL, which is the carousel's
  /// business: a page that renders nothing still takes a swipe.
  final PromoCampaign? packet;

  /// Tapping the "аксия" page opens the bundle screen.
  final VoidCallback onAksiyaTap;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  String _resolveSrc(String? url, String? id) {
    final raw = (url ?? '').replaceAll(RegExp(r'\s+'), '').trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.isNotEmpty) return '${Constants.assetsUrl}$raw';
    return '${Constants.assetsUrl}${id ?? ''}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final packet = widget.packet;
    final pages = <Widget>[
      // The packet leads: it is the offer with a deadline on it, and the one a
      // first-time visitor is most likely to act on. Absent entirely until it
      // has loaded, so the carousel never holds a slot for a blank page.
      if (packet != null)
        HomeAksiyaBanner(campaign: packet, onTap: widget.onAksiyaTap),
      ...widget.banners.map((banner) {
        final image = ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: CachedNetworkImage(
            width: double.infinity,
            fit: BoxFit.cover,
            imageUrl: _resolveSrc(banner.url, banner.id),
            placeholder: (_, __) => _placeholder(c),
            errorWidget: (_, __, ___) => _placeholder(c),
          ),
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

    // Edge to edge, with the neighbouring banners showing at both sides — that
    // sliver is what says there is more to swipe to, which is the job the dots
    // under the carousel used to do.
    //
    // Each page's slot is the screen less 12 a side, and the banner is inset 4
    // inside its slot. So the banner in view still sits on the page's 16pt
    // gutter, with 8 between it and the next one and 8 of that one showing.
    return CarouselSlider(
      options: CarouselOptions(
        height: 124.h,
        // The banners advance only when the user swipes them.
        autoPlay: false,
        viewportFraction: (1.sw - 24.w) / 1.sw,
        enlargeCenterPage: false,
        // A lone banner has no neighbour to show; wrapping would put its own
        // edge on both sides of itself.
        enableInfiniteScroll: pages.length > 1,
      ),
      items: [
        for (final page in pages)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: page,
          ),
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

/// The feed's `Реклама` slot, filled by the packet on sale.
///
/// Deliberately the SAME card as the carousel's [HomeAksiyaBanner] rather than a
/// second design of the same offer: it is the same offer, and the slot otherwise
/// holds a flat picture whose price goes stale the day marketing changes it.
/// Here the name, the visit count and the price all come off the live campaign,
/// so the ad cannot quote a figure that no longer exists.
///
/// [HomeAdCard] still backs the slot when no packet is on sale — see the ad
/// sliver in `home_page.dart`.
class HomeAksiyaAdCard extends StatelessWidget {
  const HomeAksiyaAdCard({
    super.key,
    required this.campaign,
    required this.onTap,
  });

  final PromoCampaign campaign;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SizedBox(
        // The banner has no intrinsic height — its layout is built to fit a
        // stated one — so the slot states it, at the same 144 the carousel
        // gives the slide. Anything shorter is what clipped the copy before.
        height: 144.h,
        child: HomeAksiyaBanner(campaign: campaign, onTap: onTap),
      ),
    );
  }
}

/// Full-width advertisement/promo card (Figma home `Реклама`). Reuses a real
/// banner image with a "Реклама" badge overlay. The fallback for the ad slot
/// now that [HomeAksiyaAdCard] owns it whenever a packet is on sale.
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

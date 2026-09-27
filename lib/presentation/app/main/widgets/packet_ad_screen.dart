import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/promo/promo_repository.dart';

/// Shows the full-screen packet ad if every condition for it holds, and records
/// that it was shown.
///
/// The conditions, cheapest first — the network call is last so a device with
/// the ad switched off never makes it:
///
///   1. `promo_ad_enabled` in Remote Config. Ships OFF; see
///      [RemoteConfigService.isPacketAdEnabled].
///   2. `is_ad_seen` unset. An interstitial earns one showing, ever.
///   3. A campaign actually on sale. Advertising a screen with an empty state
///      on it is worse than advertising nothing.
///   4. The buyer does not already hold a pass, and the campaign still sells
///      one. Selling someone what they already own reads as a bug, and it is
///      the fastest way to make a full-screen ad feel like spam.
///
/// `is_ad_seen` is set when we DECIDE to show it, not when it is dismissed: an
/// app killed mid-ad must not bring it back next launch.
///
/// Returns whether the ad was shown, so the caller can avoid stacking it on top
/// of another popup.
Future<bool> maybeShowPacketAd(
  BuildContext context, {
  required VoidCallback onBuy,
}) async {
  if (!RemoteConfigService.instance.isPacketAdEnabled) return false;

  final storage = getIt<Storage>();
  if (storage.isAdSeen.call() == true) return false;

  final PromoCampaign campaign;
  try {
    // The list is ordered best-offer-first, so the first row is the one to
    // advertise. A failure here leaves `is_ad_seen` alone, so the ad gets
    // another chance on the next launch rather than being burnt by a flaky
    // connection.
    final all = await getIt<PromoRepository>().getCampaigns();
    if (all.isEmpty) return false;
    campaign = all.first;
  } catch (_) {
    return false;
  }
  if (campaign.heldPass != null || !campaign.canPurchase) return false;
  if (!context.mounted) return false;

  // Let the frame behind it settle before covering it: arriving over a painted
  // home screen reads as an ad, arriving over a blank one reads as the app
  // having failed to start. AFTER the gates, so a launch with the ad switched
  // off is never held up by it — and short, because the fetch above has already
  // taken its own time.
  await Future.delayed(const Duration(milliseconds: 350));
  if (!context.mounted) return false;

  await storage.isAdSeen.set(true);
  getIt<AnalyticsService>().logEvent(
    AnalyticsEvent.aksiyaAdShown,
    params: {'campaign_id': campaign.id, 'campaign_slug': campaign.slug},
  );
  if (!context.mounted) return false;

  await showGeneralDialog<void>(
    context: context,
    // There is no barrier to tap on a screen that covers the screen. The two
    // ways out are the ✕ and "Later", both of them visible without scrolling.
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    // showGeneralDialog does not wrap its child in a SafeArea (unlike
    // showDialog), which is what a full-bleed ad wants: it paints to the very
    // edges and handles the insets itself, below.
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, _, __) => _PacketAdScreen(
      campaign: campaign,
      onBuy: () {
        Navigator.of(ctx).pop();
        onBuy();
      },
    ),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    ),
  );
  return true;
}

/// The ad itself: the packet, full bleed, with one thing to do.
///
/// Every figure is read off the campaign — the flagship happens to be 3 visits
/// for 99 000 so'm, but nothing here hardcodes that, so marketing can run a
/// different packet without an app release.
///
/// Fixed light ink on a saturated brand ground, which is the documented
/// exception to reading colors off `context.colors`: this screen is the same
/// purple in both themes, so `AppColors.onBrand` is correct and a theme role
/// would be wrong.
class _PacketAdScreen extends StatelessWidget {
  const _PacketAdScreen({required this.campaign, required this.onBuy});

  final PromoCampaign campaign;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final saving = campaign.saving;
    // Light status-bar icons: the ground under them is saturated purple, and the
    // app's own dark-on-light style leaves them unreadable on top of it.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Material(
        color: AppColors.brandPurple,
        // SizedBox.expand, not a bare DecoratedBox: the route hands this child
        // full-screen constraints, but a Stack sizes itself to its non-positioned
        // children under a loose one. Stating the fill makes "full screen" a
        // property of this widget rather than of the constraints it happens to
        // be given.
        child: SizedBox.expand(
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: AppGradients.brand),
            child: Stack(
              children: [
                // Soft discs for depth — no asset, nothing that can mis-scale.
                Positioned(
                  right: -70.w,
                  top: -60.h,
                  child: _Disc(size: 240.w, opacity: 0.12),
                ),
                Positioned(
                  left: -90.w,
                  bottom: -40.h,
                  child: _Disc(size: 260.w, opacity: 0.10),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _TopBar(onClose: () => Navigator.of(context).maybePop()),
                      // Scrollable, so a long title on a short phone scrolls rather
                      // than overflowing — the failure this exact layout has hit
                      // before (see HomeAksiyaBanner's history).
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Column(
                            children: [
                              8.verticalSpace,
                              Assets.images.mascot.mascotHello.image(
                                height: 190.h,
                                fit: BoxFit.contain,
                              ),
                              16.verticalSpace,
                              _Badge(
                                text: campaign.badge?.isNotEmpty == true
                                    ? campaign.badge!
                                    : 'aksiya_badge'.tr(),
                              ),
                              12.verticalSpace,
                              Text(
                                campaign.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w900,
                                  height: 1.1,
                                  color: AppColors.onBrand,
                                ),
                              ),
                              10.verticalSpace,
                              _Line(
                                'aksiya_hero_visits'.tr(
                                  namedArgs: {
                                    'count': '${campaign.activitiesCount}'
                                  },
                                ),
                              ),
                              6.verticalSpace,
                              _Line(
                                'aksiya_hero_deadline'.tr(namedArgs: {
                                  'days': '${campaign.validDays}'
                                }),
                              ),
                              20.verticalSpace,
                              _Price(campaign: campaign, saving: saving),
                              16.verticalSpace,
                            ],
                          ),
                        ),
                      ),
                      _Actions(onBuy: onBuy),
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

/// The "Реклама" marker and the way out. Both at the top, because an ad that
/// hides its close button is the thing people uninstall apps over.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.onBrand.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Text(
              'ad_label'.tr(),
              style: AppText.medium10.copyWith(color: AppColors.onBrand),
            ),
          ),
          const Spacer(),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.onBrand.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close_rounded,
                size: 18.sp,
                color: AppColors.onBrand,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.onBrand.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text(
        text,
        maxLines: 1,
        style: AppText.bold10.copyWith(
          color: AppColors.onBrand,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppText.regular14.copyWith(
        color: AppColors.onBrand.withValues(alpha: 0.92),
      ),
    );
  }
}

/// The price as the one solid white element on the screen — it is what the
/// offer IS. The old price is struck through beside it only when the campaign
/// configures one that is genuinely higher (see [PromoCampaign.saving]).
class _Price extends StatelessWidget {
  const _Price({required this.campaign, required this.saving});

  final PromoCampaign campaign;
  final num? saving;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.onBrand,
            borderRadius: BorderRadius.circular(40.r),
          ),
          child: Text(
            campaign.price.toRawUzsPrice(),
            maxLines: 1,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.brandPurple,
            ),
          ),
        ),
        if (saving != null) ...[
          8.verticalSpace,
          Text(
            campaign.oldPrice!.toRawUzsPrice(),
            style: AppText.regular13.copyWith(
              color: AppColors.onBrand.withValues(alpha: 0.75),
              decoration: TextDecoration.lineThrough,
              decorationColor: AppColors.onBrand.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }
}

/// Buy, and the second way out. "Later" is a full-width tap target rather than
/// fine print — the ✕ alone puts the only exit in a corner.
class _Actions extends StatelessWidget {
  const _Actions({required this.onBuy});

  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBuy,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: AppColors.onBrand,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'aksiya_buy_cta'.tr(),
                textAlign: TextAlign.center,
                style: AppText.bold16.copyWith(color: AppColors.brandPurple),
              ),
            ),
          ),
          4.verticalSpace,
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).maybePop(),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                'aksiya_success_later'.tr(),
                style: AppText.semibold14.copyWith(
                  color: AppColors.onBrand.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
        ],
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

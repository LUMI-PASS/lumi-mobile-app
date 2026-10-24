import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/new_coins_summary.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_feed_inserts.dart';
import 'package:lumi_pass/presentation/app/new_coins/widgets/new_coins_widgets.dart';

/// The profile's headline: the Lumi Coin balance.
///
/// Coins are what the app is paid in, so on the screen that is about the
/// account this is the first thing under the name. It is the ticket Home's
/// banners are cut as, in the brand violet with the gold Lumi coin on its
/// stub: the balance as the title, and under it the soonest deadline when
/// there is one. With a live tariff the ticket is the tariff instead.
class ProfileCoinHero extends StatelessWidget {
  const ProfileCoinHero({
    super.key,
    required this.coins,
    required this.onTap,
  });

  final NewCoinsSummary coins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final plan = coins.currentPack;
    // A live tariff is what the account HAS, so it is the headline — as a
    // compact card in the tariff's own colour and coin rather than another
    // ticket banner, so the profile does not repeat the Home feed's shape.
    if (plan != null) {
      return _ProfileTariffCard(
        name: plan.name,
        tone: NewCoinTone.main(coins.currentPackIndex),
        balance: coins.balance,
        endsAt: coins.activeMainExpiresAt,
        onTap: onTap,
      );
    }
    final expiry = coins.nearestExpiry;
    return HomeTicketBanner(
      // The screen's list already has its gutter.
      padding: EdgeInsets.zero,
      // Shorter than the feed's: two lines of copy do not need 132pt, and
      // this screen is a list that should fit without a long scroll.
      height: 104.h,
      // Brand violet, not the gold Home's coin ticket wears: a flat yellow
      // slab was the one thing on this screen outside the app's palette, and
      // it fought the coin it was framing. On violet the gold lives in the
      // coin alone, which is where the eye should land.
      color: AppColors.brandPurple,
      // An empty balance is not a number worth a headline: "0 Lumi Coin"
      // reads as a verdict. With nothing held the ticket is just the name.
      title: coins.balance > 0
          ? 'new_coins_amount'.tr(args: [coins.balance.toGrouped()])
          : 'new_coins_title'.tr(),
      subtitle: expiry != null && coins.nearestExpiryCoins > 0
          // The title already says how many. When they all share the one
          // deadline the line is only the date; the count comes back only
          // when it is a PART of the balance that runs out first.
          ? (coins.nearestExpiryCoins >= coins.balance
              ? 'new_coins_valid_until'
                  .tr(args: [expiry.toRussianShortFormat(context)])
              : 'new_coins_expire_on'.tr(args: [
                  coins.nearestExpiryCoins.toGrouped(),
                  expiry.toRussianShortFormat(context),
                ]))
          // Nothing running out — nothing held, or coins that never expire —
          // so the line says what coins are for, as it does on Home.
          : 'home_coins_subtitle'.tr(),
      art: Assets.icons.coinLumi,
      onTap: onTap,
    );
  }
}

/// The buyer's live tariff, compact: the tariff's glass coin, its name with a
/// "current" tag and when it runs until, and the balance on the right.
///
/// Painted in the tariff's own tone — the same colour and coin its card wears
/// on the Tariflar shelf — so the two screens plainly name one thing.
class _ProfileTariffCard extends StatelessWidget {
  const _ProfileTariffCard({
    required this.name,
    required this.tone,
    required this.balance,
    required this.endsAt,
    required this.onTap,
  });

  final String name;
  final NewCoinTone tone;
  final int balance;
  final DateTime? endsAt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ink = tone.onAccent;
    final ends = endsAt;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        // The profile's other cards' shape: a 40 pill with an 8 inset, so
        // the round coin sits in the rounded end the way their icons do.
        padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // Light tint into the accent — the Buy button's own blend. Ending
            // on the deep shade read as a dark slab against the white page.
            colors: [Color.lerp(tone.accent, tone.light, 0.45)!, tone.accent],
          ),
          boxShadow: [
            BoxShadow(
              color: tone.accent.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            tone.art.image(width: 48.w, height: 48.w),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.bold18.copyWith(color: ink),
                        ),
                      ),
                      6.horizontalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: ink.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Text(
                          'new_coins_current_badge'.tr(),
                          style: AppText.bold10.copyWith(color: ink),
                        ),
                      ),
                    ],
                  ),
                  2.verticalSpace,
                  Text(
                    ends == null
                        ? 'new_coins_title'.tr()
                        : 'new_coins_valid_until'
                            .tr(args: [ends.toRussianShortFormat(context)]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.regular13.copyWith(
                      color: ink.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            8.horizontalSpace,
            // The balance: what the tariff left in hand, the one number worth
            // reading at a glance.
            Container(
              padding: EdgeInsets.fromLTRB(10.w, 6.h, 8.w, 6.h),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    balance.toGrouped(),
                    style: AppText.bold16.copyWith(color: AppColors.ink),
                  ),
                  4.horizontalSpace,
                  Assets.icons.coinLumi.image(width: 18.w, height: 18.w),
                ],
              ),
            ),
            4.horizontalSpace,
            Icon(
              Icons.chevron_right_rounded,
              size: 22.w,
              color: ink.withValues(alpha: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

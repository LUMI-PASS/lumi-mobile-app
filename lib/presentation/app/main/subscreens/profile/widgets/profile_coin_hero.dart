import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/utils/new_coins_summary.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_feed_inserts.dart';

/// The profile's headline: the Lumi Coin balance.
///
/// Coins are what the app is paid in, so on the screen that is about the
/// account this is the first thing under the name. It is the ticket Home's
/// banners are cut as, in the brand violet with the gold Lumi coin on its
/// stub: the balance as the title, and under it the soonest deadline when
/// there is one.
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

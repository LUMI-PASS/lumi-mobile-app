import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_feed_inserts.dart';
import 'package:lumi_pass/presentation/app/profile/referral/referral_actions.dart';

/// "Invite friends": the user's promo code with Copy and Share, and what a
/// friend's package purchase earns them.
///
/// Shared by the profile (where tapping the card opens the referral screen)
/// and the top of the referral screen itself ([onTap] null).
class ReferralInviteCard extends StatelessWidget {
  const ReferralInviteCard({super.key, required this.me, this.onTap});

  final ReferralMe me;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final code = me.code ?? '';
    // On the profile it is a row among rows: the ticket is twice their height
    // and the only saturated block on a quiet settings screen, where it read
    // as an advert. Same invitation, sized and shaped like its neighbours.
    if (onTap != null) return _compact(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // The same ticket Home shows, so the invitation looks like one thing
        // wherever it is met — not a banner there and a plain card here.
        HomeTicketBanner(
          padding: EdgeInsets.zero,
          color: AppColors.brandPurple,
          title: 'home_invite_title'.tr(),
          subtitle: 'home_invite_subtitle'.tr(),
          art: Assets.images.banner.bannerInvite,
          // On the referral screen itself there is nowhere further to go:
          // tapping the ticket does what the screen is for.
          onTap: () => shareReferral(context, me),
        ),
        ...[
          12.kh,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => copyReferralText(code),
                  child: Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: c.control,
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            code,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.semibold16.copyWith(
                              color: c.textPrimary,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        Icon(Icons.copy_rounded,
                            size: 18.sp, color: c.textSecondary),
                        6.kw,
                        Text(
                          'referral_copy'.tr(),
                          style:
                              AppText.medium12.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              8.kw,
              // A Builder so the share sheet's iPad anchor is this button,
              // not the whole card.
              Builder(
                builder: (btnContext) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => shareReferral(btnContext, me),
                  child: Container(
                    height: 44.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      gradient: AppGradients.brand,
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.ios_share_rounded,
                            size: 18.sp, color: AppColors.onBrand),
                        6.kw,
                        Text(
                          'referral_share'.tr(),
                          style: AppText.semibold14
                              .copyWith(color: AppColors.onBrand),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// The profile's way in: a pill like the rows around it, tinted with the
  /// brand violet so it is still the one that stands out, saying what the
  /// invitation is worth and that it opens.
  Widget _compact(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(8.w, 8.w, 14.w, 8.w),
        decoration: BoxDecoration(
          color: c.coinBand,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            Assets.images.banner.bannerInvite.image(
              width: 48.w,
              height: 48.w,
              fit: BoxFit.contain,
            ),
            10.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'home_invite_title'.tr(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  2.kh,
                  Text(
                    me.reward.hasReward
                        ? referralRewardLine(me.reward)
                        : 'home_invite_subtitle'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.regular12.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            8.kw,
            Icon(Icons.chevron_right_rounded,
                size: 20.sp, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';
import 'package:lumi_pass/presentation/app/profile/referral/referral_actions.dart';

/// "Invite friends": the user's code with Copy and Share, and what a friend's
/// first purchase earns them.
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
    return FrostedCard(
      onTap: onTap,
      borderWidth: 2,
      borderRadius: BorderRadius.circular(20.r),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.brandPurple.withValues(alpha: 0.12),
                ),
                child: ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) =>
                      AppGradients.brand.createShader(rect),
                  child: Assets.icons.detail.iconsaxAiUsers
                      .svg(width: 20.sp, height: 20.sp),
                ),
              ),
              12.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'referral_invite_title'.tr(),
                      style: AppText.semibold16.copyWith(color: c.textPrimary),
                    ),
                    if (me.reward.hasReward) ...[
                      2.kh,
                      Text(
                        referralRewardLine(me.reward),
                        style:
                            AppText.regular12.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(Icons.chevron_right_rounded,
                    size: 20.sp, color: c.textSecondary),
            ],
          ),
          14.kh,
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
                          style: AppText.medium12
                              .copyWith(color: c.textSecondary),
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
      ),
    );
  }
}

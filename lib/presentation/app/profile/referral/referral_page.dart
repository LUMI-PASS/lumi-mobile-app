import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';
import 'package:lumi_pass/presentation/app/profile/referral/cubit/referral_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/referral/cubit/referral_state.dart';
import 'package:lumi_pass/presentation/app/profile/referral/referral_actions.dart';
import 'package:lumi_pass/presentation/app/profile/referral/widgets/referral_code_sheet.dart';
import 'package:lumi_pass/presentation/app/profile/referral/widgets/referral_invite_card.dart';

/// "Invite friends" — the referral programme's own screen.
///
/// Reached from the profile's invite card, from `lumi://referral` and from a
/// `referral` push. Read-only apart from copy/share and the optional "Have a
/// referral code?" entry: every number here is the server's.
@RoutePage()
class ReferralPage
    extends BasePage<ReferralCubit, ReferralBuildable, ReferralListenable> {
  const ReferralPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<ReferralCubit>().load();
    super.init(context);
  }

  @override
  Widget builder(BuildContext context, ReferralBuildable state) {
    context.locale;
    final c = context.colors;
    final cubit = context.read<ReferralCubit>();
    final me = state.me;

    Widget body;
    if (me == null && state.isLoading) {
      body = const Center(child: CircularProgressIndicator.adaptive());
    } else if (me == null) {
      body = _LoadError(onRetry: cubit.load);
    } else {
      body = RefreshIndicator(
        color: AppColors.brandPurple,
        onRefresh: cubit.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16.w,
            8.h,
            16.w,
            32.h + MediaQuery.of(context).viewPadding.bottom,
          ),
          children: [
            if (me.applied != null) ...[
              _InvitedByBanner(applied: me.applied!),
              16.kh,
            ],
            if (me.canInvite) ...[
              ReferralInviteCard(me: me),
              24.kh,
              _SectionTitle('referral_how_it_works'.tr()),
              12.kh,
              _HowItWorks(me: me),
              24.kh,
              _SectionTitle('referral_your_friends'.tr()),
              12.kh,
              _StatsRow(stats: me.stats),
              12.kh,
              if (me.invitees.isEmpty)
                _EmptyNote('referral_no_invitees'.tr())
              else
                for (final i in me.invitees) ...[
                  _InviteeRow(invitee: i),
                  8.kh,
                ],
            ] else if (!me.enabled) ...[
              _EmptyNote('referral_program_off'.tr()),
            ],
            if (me.enabled && me.canApply) ...[
              16.kh,
              _HaveCodeRow(
                onTap: () async {
                  if (await showReferralCodeSheet(context)) cubit.refresh();
                },
              ),
            ],
            24.kh,
            _SectionTitle('referral_your_vouchers'.tr()),
            12.kh,
            if (me.vouchers.isEmpty)
              _EmptyNote('referral_no_vouchers'.tr())
            else
              for (final v in me.vouchers) ...[
                ReferralVoucherTile(voucher: v),
                8.kh,
              ],
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'referral_title'.tr()),
      body: body,
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'something_went_wrong'.tr(),
            style: AppText.regular14.copyWith(color: c.textSecondary),
          ),
          12.kh,
          TextButton(
            onPressed: onRetry,
            child: Text(
              'retry'.tr(),
              style: AppText.semibold14.copyWith(color: AppColors.brandPurple),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: AppText.semibold16.copyWith(color: context.colors.textPrimary),
      );
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          text,
          style: AppText.regular13.copyWith(color: context.colors.textSecondary),
        ),
      );
}

/// "You were invited by Aziza" — the invitee's side of the programme.
class _InvitedByBanner extends StatelessWidget {
  const _InvitedByBanner({required this.applied});
  final ReferralApplied applied;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final name = applied.referrerName;
    return FrostedCard(
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Icon(Icons.favorite_rounded, size: 20.sp, color: AppColors.brandPink),
          12.kw,
          Expanded(
            child: Text(
              name == null
                  ? 'referral_you_were_invited'.tr()
                  : 'referral_you_were_invited_by'.tr(args: [name]),
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Three steps, worded from the programme's live numbers.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.me});
  final ReferralMe me;

  @override
  Widget build(BuildContext context) {
    final reward = me.reward;
    final steps = [
      'referral_step_share'.tr(),
      me.qualifyMinOrder > 0
          ? 'referral_step_friend_buys_min'
              .tr(args: [me.qualifyMinOrder.toRawUzsPrice()])
          : 'referral_step_friend_buys'.tr(),
      'referral_step_reward'.tr(args: [
        '${reward.percent}',
        reward.maxDiscount.toRawUzsPrice(),
        '${reward.validityDays}',
      ]),
    ];
    return FrostedCard(
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0) 12.kh,
            _Step(number: i + 1, text: steps[i]),
          ],
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});
  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26.w,
          height: 26.w,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.brand,
          ),
          child: Text(
            '$number',
            style: AppText.semibold12.copyWith(color: AppColors.onBrand),
          ),
        ),
        12.kw,
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Text(
              text,
              style: AppText.regular14
                  .copyWith(color: context.colors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});
  final ReferralStats stats;

  @override
  Widget build(BuildContext context) {
    Widget tile(int value, String label) => Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Text(
                  '$value',
                  style: AppText.semibold18
                      .copyWith(color: context.colors.textPrimary),
                ),
                2.kh,
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.regular12
                      .copyWith(color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
        );
    return Row(
      children: [
        tile(stats.invited, 'referral_stats_invited'.tr()),
        8.kw,
        tile(stats.pending, 'referral_stats_pending'.tr()),
        8.kw,
        tile(stats.rewarded, 'referral_stats_rewarded'.tr()),
      ],
    );
  }
}

class _InviteeRow extends StatelessWidget {
  const _InviteeRow({required this.invitee});
  final ReferralInvitee invitee;

  static String _labelKey(ReferralStatus s) => switch (s) {
        ReferralStatus.applied => 'referral_status_applied',
        ReferralStatus.orderPaid => 'referral_status_order_paid',
        ReferralStatus.qualified => 'referral_status_qualified',
        ReferralStatus.queued => 'referral_status_queued',
        ReferralStatus.rewarded => 'referral_status_rewarded',
        ReferralStatus.expired => 'referral_status_expired',
        ReferralStatus.rejected => 'referral_status_rejected',
        ReferralStatus.unknown => 'referral_status_unknown',
      };

  static Color _color(ReferralStatus s, AppColorScheme c) => switch (s) {
        ReferralStatus.rewarded => AppColors.tagGreen,
        ReferralStatus.expired || ReferralStatus.rejected => c.textMuted,
        ReferralStatus.applied ||
        ReferralStatus.orderPaid ||
        ReferralStatus.qualified ||
        ReferralStatus.queued =>
          AppColors.warning,
        ReferralStatus.unknown => c.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final status = invitee.referralStatus;
    final color = _color(status, c);
    final date = invitee.appliedAt;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandPurple.withValues(alpha: 0.12),
            ),
            child: Assets.icons.detail.iconsaxAiUsers.svg(
              width: 18.sp,
              height: 18.sp,
              colorFilter: const ColorFilter.mode(
                AppColors.brandPurple,
                BlendMode.srcIn,
              ),
            ),
          ),
          10.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invitee.firstName ?? 'referral_friend'.tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.semibold14.copyWith(color: c.textPrimary),
                ),
                if (date != null)
                  Text(
                    date.toRussianShortFormat(context),
                    style: AppText.regular12.copyWith(color: c.textMuted),
                  ),
              ],
            ),
          ),
          8.kw,
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(40.r),
            ),
            child: Text(
              _labelKey(status).tr(),
              style: AppText.medium12.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// One voucher: its code (tap to copy), the discount and its limits, and
/// where it stands.
class ReferralVoucherTile extends StatelessWidget {
  const ReferralVoucherTile({super.key, required this.voucher});
  final ReferralVoucher voucher;

  static String _statusKey(ReferralVoucherStatus s) => switch (s) {
        ReferralVoucherStatus.active => 'referral_voucher_status_active',
        ReferralVoucherStatus.reserved => 'referral_voucher_status_reserved',
        ReferralVoucherStatus.used => 'referral_voucher_status_used',
        ReferralVoucherStatus.expired => 'referral_voucher_status_expired',
        ReferralVoucherStatus.revoked => 'referral_voucher_status_revoked',
        ReferralVoucherStatus.unknown => 'referral_voucher_status_unknown',
      };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = voucher;
    final status = v.voucherStatus;
    final live = status.isSpendable || status == ReferralVoucherStatus.reserved;
    final expires = v.expiresAt;
    final usedAmount = v.discountAmount;
    final details = <String>[
      if (v.minOrderAmount > 0)
        'referral_voucher_min_order'.tr(args: [v.minOrderAmount.toRawUzsPrice()]),
      if (status == ReferralVoucherStatus.used &&
          usedAmount != null &&
          usedAmount > 0)
        'referral_voucher_saved'.tr(args: [usedAmount.toRawUzsPrice()])
      else if (expires != null)
        'referral_voucher_expires'.tr(args: [expires.toRussianShortFormat(context)]),
    ];
    return Opacity(
      opacity: live ? 1 : 0.55,
      child: FrostedCard(
        onTap: status.isSpendable ? () => copyReferralText(v.code) : null,
        borderRadius: BorderRadius.circular(16.r),
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.brand,
              ),
              child: Text(
                '−${v.percent}%',
                style: AppText.semibold12.copyWith(color: AppColors.onBrand),
              ),
            ),
            12.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'referral_voucher_title'.tr(
                      args: ['${v.percent}', v.maxDiscount.toRawUzsPrice()],
                    ),
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  2.kh,
                  Text(
                    details.join(' · '),
                    style: AppText.regular12.copyWith(color: c.textSecondary),
                  ),
                  4.kh,
                  Row(
                    children: [
                      Text(
                        v.code,
                        style: AppText.medium13.copyWith(
                          color: c.textPrimary,
                          letterSpacing: 1,
                        ),
                      ),
                      if (status.isSpendable) ...[
                        6.kw,
                        Icon(Icons.copy_rounded,
                            size: 14.sp, color: c.textSecondary),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            8.kw,
            Text(
              _statusKey(status).tr(),
              style: AppText.medium12.copyWith(
                color: status.isSpendable ? AppColors.tagGreen : c.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HaveCodeRow extends StatelessWidget {
  const _HaveCodeRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'referral_have_code'.tr(),
                style: AppText.semibold14.copyWith(color: c.textPrimary),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20.sp, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

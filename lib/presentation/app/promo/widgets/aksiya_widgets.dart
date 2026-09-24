import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';
import 'package:lumi_pass/data/api_model/promo/promo_pass.dart';

/// The offer hero: how many visits, for how much, in how many days.
///
/// Every figure is read off the campaign — the flagship happens to be 3 / 99 000
/// / 5, but nothing here assumes it, so a second bundle needs no app release.
class AksiyaHero extends StatelessWidget {
  const AksiyaHero({super.key, required this.campaign});

  final PromoCampaign campaign;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
          decoration: BoxDecoration(
            gradient: AppGradients.brand,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The count leads, because it is the offer. Rendered as a numeral
              // beside its noun rather than inside a sentence, so it survives
              // translation into all three locales without reflowing.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${campaign.activitiesCount}',
                    style: AppText.code56.copyWith(
                      color: AppColors.onBrand,
                      height: 1,
                    ),
                  ),
                  12.kw,
                  Expanded(
                    child: Text(
                      'aksiya_hero_visits'.tr(
                        namedArgs: {'count': '${campaign.activitiesCount}'},
                      ),
                      style: AppText.semibold18
                          .copyWith(color: AppColors.onBrand, height: 1.2),
                    ),
                  ),
                ],
              ),
              16.kh,
              // Fixed inks on purpose: this block sits on the brand gradient in
              // both themes, so it must not follow the text roles.
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    campaign.price.toRawUzsPrice(),
                    style:
                        AppText.heading20.copyWith(color: AppColors.onBrand),
                  ),
                  if (campaign.oldPrice != null) ...[
                    8.kw,
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Text(
                        campaign.oldPrice!.toRawUzsPrice(),
                        style: AppText.regular13.copyWith(
                          color: AppColors.onBrand.withValues(alpha: 0.7),
                          decoration: TextDecoration.lineThrough,
                          decorationColor:
                              AppColors.onBrand.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              8.kh,
              Text(
                'aksiya_hero_per_visit'.tr(namedArgs: {
                  'price': campaign.pricePerActivity.toRawUzsPrice(),
                }),
                style: AppText.regular13.copyWith(
                  color: AppColors.onBrand.withValues(alpha: 0.85),
                ),
              ),
              16.kh,
              // The deadline is part of the offer, not a footnote — it is the
              // condition the buyer is agreeing to, so it sits in the hero.
              _HeroDeadlineChip(days: campaign.validDays),
            ],
          ),
        ),
        if ((campaign.badge ?? '').isNotEmpty)
          Positioned(
            top: -8.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(40.r),
                border: Border.all(color: AppColors.brandPurple, width: 1.5),
              ),
              child: Text(
                campaign.badge!,
                style:
                    AppText.bold10.copyWith(color: AppColors.brandPurple),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroDeadlineChip extends StatelessWidget {
  const _HeroDeadlineChip({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.onBrand.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.time.svg(
            width: 14.w,
            height: 14.w,
            colorFilter:
                const ColorFilter.mode(AppColors.onBrand, BlendMode.srcIn),
          ),
          6.kw,
          Text(
            'aksiya_hero_deadline'.tr(namedArgs: {'days': '$days'}),
            style: AppText.semibold12.copyWith(color: AppColors.onBrand),
          ),
        ],
      ),
    );
  }
}

/// "How it works" — buy, book, go. Three steps, because the five-day deadline
/// only makes sense once the buyer can see where in the sequence it bites.
class AksiyaSteps extends StatelessWidget {
  const AksiyaSteps({super.key, required this.campaign});

  final PromoCampaign campaign;

  @override
  Widget build(BuildContext context) {
    final steps = <({String title, String body})>[
      (
        title: 'aksiya_step1_title'.tr(),
        body: 'aksiya_step1_body'.tr(
          namedArgs: {'count': '${campaign.activitiesCount}'},
        ),
      ),
      (
        title: 'aksiya_step2_title'.tr(),
        body: 'aksiya_step2_body'.tr(
          namedArgs: {'days': '${campaign.validDays}'},
        ),
      ),
      (
        title: 'aksiya_step3_title'.tr(),
        body: campaign.distinctActivities
            ? 'aksiya_step3_body_distinct'.tr(
                namedArgs: {'count': '${campaign.activitiesCount}'},
              )
            : 'aksiya_step3_body'.tr(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0) 10.kh,
          _StepRow(
            index: i + 1,
            title: steps[i].title,
            body: steps[i].body,
          ),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.title,
    required this.body,
  });

  final int index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return FrostedCard(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(16.r),
      padding: EdgeInsets.all(14.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppGradients.stepNumeral,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: AppText.semibold14.copyWith(color: AppColors.onBrand),
            ),
          ),
          12.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.semibold14.copyWith(color: c.textPrimary),
                ),
                4.kh,
                Text(
                  body,
                  style: AppText.regular13.copyWith(color: c.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The campaign's bullet list, plus the rules the server will actually enforce.
class AksiyaHighlights extends StatelessWidget {
  const AksiyaHighlights({super.key, required this.campaign});

  final PromoCampaign campaign;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final lines = <String>[
      ...campaign.highlights,
      // Appended rather than left to the campaign copy: these two are the rules
      // checkout enforces, so the buyer must have been told them even if
      // marketing forgot to write them into `highlights`.
      if (campaign.distinctActivities)
        'aksiya_rule_distinct'.tr(
          namedArgs: {'count': '${campaign.activitiesCount}'},
        ),
      if (campaign.maxActivityPrice != null)
        'aksiya_rule_max_price'.tr(namedArgs: {
          'price': campaign.maxActivityPrice!.toRawUzsPrice(),
        }),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 3.h),
                  child: Assets.icons.sucess.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: const ColorFilter.mode(
                      AppColors.green,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                8.kw,
                Expanded(
                  child: Text(
                    line,
                    style:
                        AppText.regular14.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// The pass the buyer already holds: visits left, days left, where they went.
///
/// Shown in place of the Buy bar's pitch — someone who already owns the bundle
/// needs to know what is left on it and be sent off to spend it, not sold it a
/// second time.
class AksiyaPassCard extends StatelessWidget {
  const AksiyaPassCard({
    super.key,
    required this.total,
    required this.used,
    required this.left,
    required this.daysLeft,
    required this.code,
    this.expiresAt,
    this.onTap,
  });

  final int total;
  final int used;
  final int left;
  final int daysLeft;
  final String code;
  final DateTime? expiresAt;
  final VoidCallback? onTap;

  /// Built from the full pass — the detail screen's header.
  factory AksiyaPassCard.fromPass(PromoPass pass, {VoidCallback? onTap}) {
    return AksiyaPassCard(
      total: pass.activitiesTotal,
      used: pass.activitiesUsed,
      left: pass.activitiesLeft,
      daysLeft: pass.daysLeft,
      code: pass.code,
      expiresAt: pass.expiresAt,
      onTap: onTap,
    );
  }

  /// Built from the compact form a campaign carries.
  factory AksiyaPassCard.fromSummary(
    PromoPassSummary pass, {
    VoidCallback? onTap,
  }) {
    return AksiyaPassCard(
      total: pass.activitiesTotal,
      used: pass.activitiesUsed,
      left: pass.activitiesLeft,
      daysLeft: pass.daysLeft,
      code: pass.code,
      expiresAt: pass.expiresAt,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // The last two days turn the countdown red — a deadline the buyer can still
    // act on is worth shouting about; one five days out is not.
    final urgent = daysLeft <= 2 && left > 0;

    return FrostedCard(
      onTap: onTap,
      borderWidth: 2,
      borderRadius: BorderRadius.circular(20.r),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          AksiyaVisitsRing(total: total, used: used),
          14.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'aksiya_pass_visits_left'.tr(namedArgs: {'count': '$left'}),
                  style: AppText.semibold16.copyWith(color: c.textPrimary),
                ),
                6.kh,
                Row(
                  children: [
                    Assets.icons.time.svg(
                      width: 14.w,
                      height: 14.w,
                      colorFilter: ColorFilter.mode(
                        urgent ? AppColors.error : c.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                    6.kw,
                    Expanded(
                      child: Text(
                        daysLeft <= 0
                            ? 'aksiya_pass_expired'.tr()
                            : 'aksiya_pass_days_left'
                                .tr(namedArgs: {'days': '$daysLeft'}),
                        style: AppText.medium13.copyWith(
                          color: urgent ? AppColors.error : c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (expiresAt != null) ...[
                  4.kh,
                  Text(
                    'aksiya_pass_until'.tr(namedArgs: {
                      'date': DateFormat('d MMMM, HH:mm').format(expiresAt!),
                    }),
                    style:
                        AppText.regular12.copyWith(color: c.textMuted),
                  ),
                ],
              ],
            ),
          ),
          if (onTap != null)
            Assets.icons.arrowRight.svg(
              width: 18.w,
              height: 18.w,
              colorFilter:
                  ColorFilter.mode(c.textSecondary, BlendMode.srcIn),
            ),
        ],
      ),
    );
  }
}

/// "1 / 3" inside a progress ring. Reads at a glance, which a bare fraction
/// does not once the numbers get close.
class AksiyaVisitsRing extends StatelessWidget {
  const AksiyaVisitsRing({
    super.key,
    required this.total,
    required this.used,
    this.size = 56,
  });

  final int total;
  final int used;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progress = total <= 0 ? 0.0 : (used / total).clamp(0.0, 1.0);
    return SizedBox(
      width: size.w,
      height: size.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size.w, size.w),
            painter: _RingPainter(
              progress: progress,
              track: c.progressTrack,
              fill: AppColors.brandPurple,
              strokeWidth: 5.w,
            ),
          ),
          Text(
            '${total - used}',
            style: AppText.bold16.copyWith(color: c.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
    required this.strokeWidth,
  });

  final double progress;
  final Color track;
  final Color fill;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset(strokeWidth / 2, strokeWidth / 2) &
        Size(size.width - strokeWidth, size.height - strokeWidth);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);

    if (progress <= 0) return;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      base..color = fill,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.track != track || old.fill != fill;
}

/// One spent visit on the pass detail screen.
class AksiyaRedemptionRow extends StatelessWidget {
  const AksiyaRedemptionRow({super.key, required this.redemption});

  final PromoRedemption redemption;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final attended = redemption.attended;
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: FrostedCard(
        borderWidth: 2,
        borderRadius: BorderRadius.circular(16.r),
        padding: EdgeInsets.all(14.w),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (attended ? AppColors.green : AppColors.brandPurple)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Assets.icons.sucess.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  attended ? AppColors.green : AppColors.brandPurple,
                  BlendMode.srcIn,
                ),
              ),
            ),
            12.kw,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    redemption.activityName ?? 'aksiya_visit_generic'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold14.copyWith(color: c.textPrimary),
                  ),
                  4.kh,
                  Text(
                    [
                      if ((redemption.ticketDate ?? '').isNotEmpty)
                        redemption.ticketDate!,
                      // "Attended" vs "booked" is the difference between the
                      // promise being kept and merely scheduled, so it is said
                      // out loud rather than implied by a colour.
                      attended
                          ? 'aksiya_visit_attended'.tr()
                          : 'aksiya_visit_booked'.tr(),
                    ].join(' · '),
                    style:
                        AppText.regular12.copyWith(color: c.textSecondary),
                  ),
                ],
              ),
            ),
            if ((redemption.ticketNo ?? '').isNotEmpty)
              Text(
                '#${redemption.ticketNo}',
                style: AppText.medium12.copyWith(color: c.textMuted),
              ),
          ],
        ),
      ),
    );
  }
}

/// The sticky bottom bar: price on the left, the action on the right.
///
/// Shared by the offer screen and the "spend it" state, because they are the
/// same shape with a different verb — and a second bar would be a second set of
/// safe-area and disabled-state bugs.
class AksiyaBottomBar extends StatelessWidget {
  const AksiyaBottomBar({
    super.key,
    this.caption,
    this.amount,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.enabled = true,
  });

  /// Muted line above [amount]. Omit for an action-only bar.
  final String? caption;
  final num? amount;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  /// False greys the action out — the bar still renders, so the price stays
  /// readable while the reason it cannot be pressed is shown above it.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final live = enabled && !isLoading;
    return Container(
      color: c.bottomBar,
      padding: EdgeInsets.fromLTRB(
        16.w,
        16.h,
        16.w,
        16.h + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Row(
        children: [
          if (amount != null) ...[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (caption != null) ...[
                  Text(
                    caption!,
                    style: AppText.regular14
                        .copyWith(color: c.textSecondary),
                  ),
                  4.kh,
                ],
                Text(
                  amount!.toRawUzsPrice(),
                  style: AppText.bold16.copyWith(color: c.textPrimary),
                ),
              ],
            ),
            20.kw,
          ],
          Expanded(
            child: GestureDetector(
              onTap: live ? onTap : null,
              child: Container(
                height: 50.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: live ? AppGradients.brand : null,
                  color: live ? null : c.disabled,
                  borderRadius: BorderRadius.circular(44.r),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(c.onPrimary),
                        ),
                      )
                    : Text(
                        label,
                        style: AppText.medium16
                            .copyWith(color: c.onPrimary),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

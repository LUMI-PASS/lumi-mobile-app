import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/adaptive_card.dart';
import 'package:lumi_pass/data/api_model/subscription/subscription_record.dart';
import 'package:lumi_pass/data/api_model/subscription/subscription_status.dart';
import 'package:shimmer/shimmer.dart';

/// The purchased-coupon history body — shimmer, empty state and cards.
///
/// Shrink-wraps (it is a [Column], not a scroll view) so it can drop straight
/// into the History tab of the coupons page as well as fill the standalone
/// history route.
class CouponHistoryList extends StatelessWidget {
  const CouponHistoryList({
    super.key,
    required this.records,
    required this.isLoading,
    this.padding,
  });

  final List<SubscriptionRecord> records;
  final bool isLoading;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final pad = padding ?? EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h);

    if (isLoading) {
      return Padding(padding: pad, child: const _HistoryShimmer());
    }
    if (records.isEmpty) {
      return Padding(padding: pad, child: const _EmptyHistory());
    }

    return Padding(
      padding: pad,
      child: Column(
        children: [
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0) 8.kh,
            _HistoryCard(record: records[i]),
          ],
        ],
      ),
    );
  }
}

// ─── History card ────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record});

  final SubscriptionRecord record;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final r = record;
    final hasLimit = r.activitiesLimit > 0;
    final progress =
        hasLimit ? (r.usedCount / r.activitiesLimit).clamp(0.0, 1.0) : 0.0;

    return AdaptiveCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DiscountTile(percent: r.discountPercentage),
              12.kw,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.planName?.isNotEmpty == true
                          ? r.planName!
                          : 'coupon_plans_title'.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.semibold16
                          .copyWith(color: colors.textPrimary),
                    ),
                    6.kh,
                    Text(
                      r.amount.toRawUzsPrice(),
                      style:
                          AppText.regular12.copyWith(color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
              8.kw,
              _StatusPill(status: r.subscriptionStatus),
            ],
          ),
          16.kh,
          _PeriodRow(start: r.startDate, end: r.endDate),
          if (hasLimit) ...[
            16.kh,
            _UsageBar(
              progress: progress,
              used: r.usedCount,
              total: r.activitiesLimit,
            ),
          ],
        ],
      ),
    );
  }
}

/// Lime square carrying the coupon's discount, with the four-point star
/// bleeding out of its bottom-right corner. Ink-on-lime in both themes.
class _DiscountTile extends StatelessWidget {
  const _DiscountTile({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final size = 45.w;
    final star = 46.w;

    return Container(
      width: size,
      height: size,
      // The star is deliberately larger than the tile and gets cut to its
      // rounded corners.
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Positioned(
            left: size / 2 + 12.5.w - star / 2,
            top: size / 2 + 11.5.h - star / 2,
            child: Assets.icons.coupons.star4.svg(width: star, height: star),
          ),
          Positioned(
            left: size / 2 - 18.5.w,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                percent > 0 ? '-$percent%' : '—',
                style: AppText.semibold14.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The coupon's state, said and coloured.
///
/// Green for a coupon that can still be spent, grey for every state that has
/// finished — the one distinction that changes what the user can do with it. A
/// history list is mostly dead coupons, so the live one has to be findable
/// without reading each pill.
///
/// Fixed ink on a solid status fill, theme-invariant by design: the pill reads
/// the same in light and dark, like the brand/status chips elsewhere.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final SubscriptionStatus status;

  /// Exhaustive, no `default`: a status added to the enum later must fail to
  /// compile here rather than quietly painting itself as finished.
  (String, Color) get _style => switch (status) {
        SubscriptionStatus.active => (
            'sub_status_active'.tr(),
            AppColors.green,
          ),
        SubscriptionStatus.canceled => (
            'sub_status_canceled'.tr(),
            AppColors.chipGrey,
          ),
        // An unmodelled state is not claimed to be live. Saying "expired" of a
        // coupon that has merely gone unrecognised is the safe way round: it
        // sends the user to look, rather than promising a discount checkout
        // would then refuse.
        SubscriptionStatus.expired ||
        SubscriptionStatus.unknown =>
          ('sub_status_expired'.tr(), AppColors.chipGrey),
      };

  @override
  Widget build(BuildContext context) {
    final (label, fill) = _style;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(48.r),
      ),
      child: Text(
        label,
        style: AppText.medium10.copyWith(color: AppColors.white),
      ),
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final muted = AppText.semibold14.copyWith(color: AppColors.greeting);
    final strong = AppText.semibold14.copyWith(color: colors.textPrimary);

    return Row(
      children: [
        // Stroke-only calendar, already drawn in `textMuted` — no colour filter,
        // which would flatten the outline into a solid blob.
        Assets.icons.detail.icCalendar.svg(width: 20.w, height: 20.w),
        8.kw,
        Text(
          'coupon_period'.tr(),
          style: AppText.regular14.copyWith(color: colors.textMuted),
        ),
        const Spacer(),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: '${'coupon_from'.tr()} ', style: muted),
                  TextSpan(
                    text: start.toRussianShortFormat(context),
                    style: strong,
                  ),
                  TextSpan(text: ' ${'coupon_to'.tr()} ', style: muted),
                  TextSpan(
                    text: end.toRussianShortFormat(context),
                    style: strong,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UsageBar extends StatelessWidget {
  const _UsageBar({
    required this.progress,
    required this.used,
    required this.total,
  });

  final double progress;
  final int used;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 14.h,
            decoration: BoxDecoration(
              color: context.colors.progressTrack,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12.h,
                  margin: EdgeInsets.symmetric(horizontal: 1.w),
                  decoration: BoxDecoration(
                    color: AppColors.lime,
                    borderRadius: BorderRadius.circular(42.r),
                  ),
                ),
              ),
            ),
          ),
        ),
        16.kw,
        Text(
          'coupon_used_count'.tr(namedArgs: {
            'used': '$used',
            'total': '$total',
          }),
          style: AppText.medium12.copyWith(
            color: context.colors.textMuted,
            letterSpacing: 0.15,
          ),
        ),
      ],
    );
  }
}

// ─── Loading / empty ─────────────────────────────────────────────────────────

class _HistoryShimmer extends StatelessWidget {
  const _HistoryShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) 8.kh,
          Shimmer.fromColors(
            baseColor: context.colors.control,
            highlightColor: context.colors.surface,
            child: Container(
              height: 128.h,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.coupons.icFiles.svg(
            width: 32.w,
            height: 32.w,
            colorFilter: ColorFilter.mode(
              context.colors.textPlaceholder,
              BlendMode.srcIn,
            ),
          ),
          16.kh,
          Text(
            'sub_history_empty'.tr(),
            textAlign: TextAlign.center,
            style:
                AppText.semibold16.copyWith(color: context.colors.textPrimary),
          ),
          8.kh,
          Text(
            'sub_history_empty_hint'.tr(),
            textAlign: TextAlign.center,
            style:
                AppText.regular13.copyWith(color: context.colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

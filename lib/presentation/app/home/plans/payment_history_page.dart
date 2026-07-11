import 'package:auto_route/auto_route.dart';
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
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:shimmer/shimmer.dart';

/// Purchased-coupon history. Reached from the "История платежей" row on
/// [PlansPage].
@RoutePage()
class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final OrdersApi _api = getIt<OrdersApi>();

  List<SubscriptionRecord> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getSubscriptionHistory();
      if (!mounted) return;
      setState(() => _history = data);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _Header(onBack: () => context.router.maybePop()),
            Expanded(
              child: _isLoading
                  ? const _HistoryShimmer()
                  : _history.isEmpty
                      ? const _EmptyHistory()
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                          itemCount: _history.length,
                          separatorBuilder: (_, __) => 8.kh,
                          itemBuilder: (_, i) =>
                              _HistoryCard(record: _history[i]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AdaptiveCard(
              onTap: onBack,
              tone: CardTone.control,
              bordered: true,
              padding: EdgeInsets.all(8.w),
              child: Assets.icons.arrowLeftRounded.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  context.colors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Text(
            'coupon_history_title'.tr(),
            style:
                AppText.medium16.copyWith(color: context.colors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ─── History card ────────────────────────────────────────────────────────────

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record});

  final SubscriptionRecord record;

  String _statusLabel() {
    if (record.isActive) return 'sub_status_active'.tr();
    if (record.isCanceled) return 'sub_status_canceled'.tr();
    return 'sub_status_expired'.tr();
  }

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
                      style: AppText.regular12
                          .copyWith(color: AppColors.inkMuted),
                    ),
                  ],
                ),
              ),
              8.kw,
              _StatusPill(label: _statusLabel()),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.chipGrey,
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
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      itemCount: 4,
      separatorBuilder: (_, __) => 8.kh,
      itemBuilder: (_, __) => Shimmer.fromColors(
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
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
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
              style: AppText.semibold16
                  .copyWith(color: context.colors.textPrimary),
            ),
            8.kh,
            Text(
              'sub_history_empty_hint'.tr(),
              textAlign: TextAlign.center,
              style: AppText.regular13
                  .copyWith(color: context.colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

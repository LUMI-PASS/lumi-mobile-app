import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/calendar/widget/cancel_booking_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';

/// A single-ticket receipt opened from the paid booking detail (Figma 96:3358).
///
/// The card is a paper ticket: a branded stub carrying the Lumi logo, the
/// status chip, the ticket number and its date/time pills, then two torn-off
/// sections — the class/age detail and the amount — separated by perforated
/// dashed lines.
@RoutePage()
class TicketReceiptPage extends StatefulWidget {
  const TicketReceiptPage({
    super.key,
    required this.ticket,
    this.className,
    this.branch,
    this.orderId,
    this.canCancel = false,
    this.paidPrice,
    this.fromPromocode = false,
  });

  final OrderTicket ticket;
  final String? className;
  final String? branch;
  final String? orderId;
  final bool canCancel;

  /// Per-ticket amount the user actually paid after coupon discount.
  /// Null when no discount was applied — falls back to [ticket.price].
  final num? paidPrice;

  /// True when the discount came from a promocode (vs an auto coupon plan) —
  /// selects the "Promokod chegirmasi" vs "Kupon chegirmasi" label.
  final bool fromPromocode;

  @override
  State<TicketReceiptPage> createState() => _TicketReceiptPageState();
}

class _TicketReceiptPageState extends State<TicketReceiptPage> {
  bool _cancelling = false;

  Future<void> _showCancelSheet() async {
    final confirmed = await showCancelBookingSheet(context);
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await getIt<OrdersApi>().cancelOrder(widget.orderId!);
      if (!mounted) return;
      // Pop back to booking detail, which reloads on `true`.
      context.router.maybePop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('booking_cancel_failed'.tr(args: [e.toString()])),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = widget.ticket;
    final time = (t.startTime != null && t.endTime != null)
        ? '${t.startTime} – ${t.endTime}'
        : null;

    final showCancel = widget.canCancel &&
        widget.orderId != null &&
        t.status.toLowerCase() != 'canceled';

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      appBar: BaseAppBar(title: 'ticket_details'.tr()),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: _TicketCard(
          c: c,
          ticketNo: t.ticketNo,
          status: t.status,
          date: t.ticketDate,
          time: time,
          className: widget.className,
          branch: widget.branch,
          ageFrom: t.ageFrom,
          ageTo: t.ageTo,
          price: t.price,
          paidPrice: widget.paidPrice,
          fromPromocode: widget.fromPromocode,
        ),
      ),
      bottomNavigationBar: showCancel
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                16.w,
                8.h,
                16.w,
                MediaQuery.of(context).viewPadding.bottom + 16.h,
              ),
              child: _CancelButton(
                loading: _cancelling,
                onTap: _showCancelSheet,
              ),
            )
          : null,
    );
  }
}

// ─── The ticket ───────────────────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  const _TicketCard({
    required this.c,
    required this.ticketNo,
    required this.status,
    required this.date,
    required this.time,
    required this.className,
    required this.branch,
    required this.ageFrom,
    required this.ageTo,
    required this.price,
    required this.paidPrice,
    required this.fromPromocode,
  });

  final AppColorScheme c;
  final String? ticketNo;
  final String status;
  final String date;
  final String? time;
  final String? className;
  final String? branch;
  final int ageFrom;
  final int ageTo;
  final num price;
  final num? paidPrice;
  final bool fromPromocode;

  bool get _discounted => paidPrice != null && paidPrice != price;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Stub: logo, status, ticket number, date/time pills ──
        ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
          child: ColoredBox(
            color: c.surface,
            child: Stack(
              children: [
                // The purple bloom straddling the card's top edge, tinting the
                // branded half of the stub.
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration:
                        BoxDecoration(gradient: AppGradients.ticketStubGlow),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // The neon wordmark carries its own glow, and the
                          // asset is a square with the mark banded across the
                          // middle — `cover` crops the empty margins away.
                          Assets.icons.logoTransparent.image(
                            width: 96.w,
                            height: 40.h,
                            fit: BoxFit.cover,
                          ),
                          const Spacer(),
                          _StatusChip(status: status),
                        ],
                      ),
                      16.verticalSpace,
                      Text(
                        ticketNo != null
                            ? 'ticket_number'.tr(args: [ticketNo!])
                            : 'ticket_pending_label'.tr(),
                        style: AppText.semibold18
                            .copyWith(fontSize: 20.sp, color: c.textPrimary),
                      ),
                      6.verticalSpace,
                      Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: [
                          _MetaChip(
                              c: c,
                              label: 'ticket_date_label'.tr(),
                              value: date),
                          if (time != null)
                            _MetaChip(
                                c: c,
                                label: 'ticket_time_label'.tr(),
                                value: time!),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        _Perforation(c: c),
        // ── Class / venue / age ──
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          color: c.surface,
          child: Column(
            children: [
              if (className != null && className!.isNotEmpty)
                _DetailRow(
                  c: c,
                  icon: Assets.icons.coupons.icTicketTitle,
                  label: 'ticket_class'.tr(),
                  value: className!,
                ),
              if (branch != null && branch!.isNotEmpty) ...[
                16.verticalSpace,
                _DetailRow(
                  c: c,
                  icon: Assets.icons.detail.icLocation,
                  label: 'ticket_venue'.tr(),
                  value: branch!,
                ),
              ],
              16.verticalSpace,
              _DetailRow(
                c: c,
                icon: Assets.icons.detail.babyGirl,
                label: 'detail_age'.tr(),
                value: 'ticket_age_value'.tr(args: ['$ageFrom', '$ageTo']),
              ),
            ],
          ),
        ),
        _Perforation(c: c),
        // ── Amount + "show this at the entrance" note ──
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.r)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('order_sum'.tr(),
                      style:
                          AppText.regular14.copyWith(color: c.textSecondary)),
                  const Spacer(),
                  if (_discounted) ...[
                    Text(
                      price.toRawUzsPrice(),
                      style: AppText.regular12.copyWith(
                        color: c.textMuted,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    6.horizontalSpace,
                  ],
                  Text(
                    (paidPrice ?? price).toRawUzsPrice(),
                    style: AppText.semibold14.copyWith(
                      color: _discounted ? AppColors.green : c.textPrimary,
                    ),
                  ),
                ],
              ),
              if (_discounted) ...[
                8.verticalSpace,
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(40.r),
                    ),
                    child: Text(
                      (fromPromocode
                              ? 'booking_promocode_discount'
                              : 'booking_coupon_discount')
                          .tr(),
                      style:
                          AppText.semibold12.copyWith(color: AppColors.green),
                    ),
                  ),
                ),
              ],
              16.verticalSpace,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HomeIcon(Assets.icons.infoDis,
                      size: 20, color: AppColors.warning),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      'ticket_present_at_venue'.tr(),
                      style:
                          AppText.regular14.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The tear line between two ticket sections: a dashed rule with a notch bitten
/// out of each edge, so the card reads as a perforated paper stub.
class _Perforation extends StatelessWidget {
  const _Perforation({required this.c});

  final AppColorScheme c;

  @override
  Widget build(BuildContext context) {
    const notch = 16.0;

    return SizedBox(
      height: notch,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(color: c.surface),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // One dash per 8px of available width, so the rule keeps its
                // rhythm on any screen size.
                final count = (constraints.maxWidth / 8).floor().clamp(1, 60);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    count,
                    (_) => Container(
                      width: 4.w,
                      height: 1.6,
                      color: c.control,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(left: -notch / 2, child: _Notch(c: c)),
          Positioned(right: -notch / 2, child: _Notch(c: c)),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch({required this.c});

  final AppColorScheme c;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(color: c.scaffoldBg, shape: BoxShape.circle),
    );
  }
}

/// "Дата: 22 апр. 2026" pill — muted label, primary value.
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.c, required this.label, required this.value});

  final AppColorScheme c;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: c.control,
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: AppText.semibold14.copyWith(color: c.textMuted),
            ),
            TextSpan(
              text: value,
              style: AppText.semibold14.copyWith(color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon + muted label on the left, value on the right.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.c,
    required this.icon,
    required this.label,
    required this.value,
  });

  final AppColorScheme c;
  final SvgGenImage icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HomeIcon(icon, size: 20, color: c.textMuted),
        8.horizontalSpace,
        Text(label, style: AppText.regular14.copyWith(color: c.textSecondary)),
        16.horizontalSpace,
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: AppText.semibold14.copyWith(color: c.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status.toLowerCase()) {
      case 'confirmed':
        color = AppColors.tagGreen;
        label = 'ticket_confirmed'.tr();
      case 'canceled':
      case 'cancelled':
        color = AppColors.error;
        label = 'order_cancelled'.tr();
      default:
        color = AppColors.warning;
        label = 'ticket_pending'.tr();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(48.r),
      ),
      child: Text(label,
          style: AppText.medium10.copyWith(color: Colors.white)),
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap, this.loading = false});

  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: loading ? null : onTap,
      child: Container(
        height: 50.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(44.r),
        ),
        child: loading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  color: AppColors.error,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'booking_cancel_title'.tr(),
                style: AppText.medium16.copyWith(color: AppColors.error),
              ),
      ),
    );
  }
}

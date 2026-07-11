import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens Paycom for [order] from any surface. Falls back through several
/// [LaunchMode]s because some Android builds block `externalApplication` when
/// a matching browser isn't set as default, and iOS simulators sometimes
/// refuse `externalNonBrowserApplication`.
Future<void> payForOrder(BuildContext context, UserOrder order) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final api = getIt<OrdersApi>();
    final detail = await api.getOrderDetail(order.id);
    String? url = detail.checkoutUrl;
    if (url == null || url.isEmpty) {
      // GET /orders/:id doesn't return checkout_url, so re-initiate
      // checkout with the existing order's own data to get a fresh URL.
      final activityId = detail.order.activityId;
      final ticketDate = detail.earliestTicketDate;
      if (activityId != null &&
          ticketDate != null &&
          detail.order.items.isNotEmpty) {
        final result = await api.checkout(
          activityId: activityId,
          items: detail.order.items
              .map((i) => CheckoutItem(
                    ageFrom: i.ageFrom,
                    ageTo: i.ageTo,
                    count: i.count,
                  ))
              .toList(),
          ticketDate: ticketDate,
        );
        url = result.checkoutUrl.isNotEmpty ? result.checkoutUrl : null;
      }
    }
    if (url == null || url.isEmpty) {
      messenger?.showSnackBar(
        const SnackBar(
          content: Text('Payment link is not available yet.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final uri = Uri.parse(url);
    for (final mode in const [
      LaunchMode.externalApplication,
      LaunchMode.platformDefault,
      LaunchMode.inAppBrowserView,
    ]) {
      if (await launchUrl(uri, mode: mode)) return;
    }
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Could not open the payment page.'),
        backgroundColor: Colors.red,
      ),
    );
  } catch (e) {
    messenger?.showSnackBar(
      SnackBar(
        content: Text('Payment failed to start: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// One card in the Bookings tab (redesign — Figma 96-3204). Represents a single
/// order (transaction), which may hold multiple seats. Tap → [BookingDetailRoute].
///
/// Dark reference, but rendered on the design-system tokens so it also works in
/// light. Shared with the profile "My bookings" screen.
class BookingCard extends StatelessWidget {
  const BookingCard({super.key, required this.order});

  final UserOrder order;

  /// "22 апр. 09:55" — day + short month + time.
  String _dateTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      final month = 'month_short_${d.month}'.tr();
      final hh = d.hour.toString().padLeft(2, '0');
      final mm = d.minute.toString().padLeft(2, '0');
      return '${d.day} $month $hh:$mm';
    } catch (_) {
      return '';
    }
  }

  /// "22 апр" — day + short month.
  String _dateOnly(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso).toLocal();
      return '${d.day} ${'month_short_${d.month}'.tr()}';
    } catch (_) {
      return '';
    }
  }

  /// "22 апр 09:00 - 10:00" — first ticket's session date + time window.
  String _sessionDateTime() {
    if (order.ticketSummaries.isEmpty) return '';
    final t = order.ticketSummaries.first;
    final date = _dateOnly(t.ticketDate);
    final s = t.startTime, e = t.endTime;
    if (s != null && s.isNotEmpty && e != null && e.isNotEmpty) {
      return date.isNotEmpty ? '$date $s - $e' : '$s - $e';
    }
    return date;
  }

  /// "3-6 лет" — first item's age range.
  String _ageRange() {
    if (order.items.isEmpty) return '';
    final it = order.items.first;
    final to = it.ageTo >= 99 ? '∞' : '${it.ageTo}';
    return '${it.ageFrom}-$to ${'age_years_suffix'.tr()}';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final imageUrl = (order.activityImage != null &&
            order.activityImage!.isNotEmpty)
        ? order.activityImage
        : null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.router.push(BookingDetailRoute(orderId: order.id)),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: thumbnail + title + status badge.
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 56.w,
                    height: 56.w,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: c.control),
                            errorWidget: (_, __, ___) =>
                                Container(color: c.control),
                          )
                        : Container(color: c.control),
                  ),
                ),
                12.kw,
                Expanded(
                  child: Text(
                    order.activityName ?? 'Class',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.semibold16.copyWith(color: c.textPrimary),
                  ),
                ),
                8.kw,
                _StatusBadge(status: order.effectiveDisplayStatus),
              ],
            ),
            16.kh,
            _InfoRow(
              icon: Icons.child_care_rounded,
              label: _ageRange(),
              value: '${order.totalSeats}',
            ),
            12.kh,
            _InfoRow(
              icon: Icons.event_note_rounded,
              label: 'booking_date'.tr(),
              value: _dateTime(order.createdAt),
            ),
            if (_sessionDateTime().isNotEmpty) ...[
              12.kh,
              _InfoRow(
                icon: Icons.calendar_today_rounded,
                label: 'order_date'.tr(),
                value: _sessionDateTime(),
              ),
            ],
            12.kh,
            _InfoRow(
              label: 'order_sum'.tr(),
              value: order.totalAmount.toRawUzsPrice(),
            ),
            if (order.isPending) ...[
              14.kh,
              _PayNowFooter(order: order),
            ],
          ],
        ),
      ),
    );
  }
}

/// One label/value line in a [BookingCard]. Optional leading icon.
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.icon});

  final IconData? icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20.sp, color: c.textMuted),
          8.kw,
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.regular14.copyWith(color: c.textMuted),
          ),
        ),
        8.kw,
        Text(
          value,
          style: AppText.semibold14.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}

/// Booking status pill. Active is a green gradient; the terminal states are
/// solid (visited=blue, missed=orange, cancelled=red) per Figma 96-3204.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    Gradient? gradient;
    Color? color;
    final String label;
    switch (status.toLowerCase()) {
      case 'active':
        gradient = AppGradients.green;
        label = 'status_active'.tr();
        break;
      case 'visited':
        color = const Color(0xFF497BF1);
        label = 'status_visited'.tr();
        break;
      case 'missed':
        color = const Color(0xFFEF8E48);
        label = 'status_missed'.tr();
        break;
      case 'canceled':
      case 'cancelled':
        color = AppColors.error;
        label = 'status_canceled'.tr();
        break;
      default: // pending
        color = const Color(0xFFEF8E48);
        label = 'status_pending'.tr();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: gradient,
        color: color,
        borderRadius: BorderRadius.circular(48.r),
      ),
      child: Text(
        label,
        style: AppText.medium10.copyWith(color: Colors.white),
      ),
    );
  }
}

class _PayNowFooter extends StatefulWidget {
  const _PayNowFooter({required this.order});

  final UserOrder order;

  @override
  State<_PayNowFooter> createState() => _PayNowFooterState();
}

class _PayNowFooterState extends State<_PayNowFooter> {
  bool _launching = false;

  Future<void> _onTap() async {
    if (_launching) return;
    setState(() => _launching = true);
    try {
      await payForOrder(context, widget.order);
    } finally {
      if (mounted) setState(() => _launching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _launching ? null : _onTap,
        borderRadius: BorderRadius.circular(30.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            gradient: AppGradients.brand,
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_launching)
                SizedBox(
                  width: 14.w,
                  height: 14.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              else
                Icon(Icons.payments_rounded, size: 16.sp, color: Colors.white),
              8.kw,
              Text(
                _launching ? 'opening_payment'.tr() : 'pay_now'.tr(),
                style: AppText.semibold14.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';

/// A single-ticket receipt screen opened from the paid booking detail. Shows
/// the ticket id and its date/time prominently at the top, followed by class
/// and venue metadata — styled as a Lumi-branded paper receipt.
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

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      final weekday = 'weekday_full_${d.weekday}'.tr();
      final month = 'month_full_${d.month}'.tr();
      return '$weekday, $month ${d.day}, ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  Future<void> _showCancelSheet() async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CancelBookingSheet(
        ticketNo: widget.ticket.ticketNo,
        className: widget.className,
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _cancelling = true);
    try {
      await getIt<OrdersApi>().cancelOrder(widget.orderId!);
      if (!mounted) return;
      // Pop back to booking detail which will reload
      context.router.maybePop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('booking_cancel_failed'.tr(args: [e.toString()])),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final ticketNo = widget.ticket.ticketNo ?? '----';
    final time = (widget.ticket.startTime != null && widget.ticket.endTime != null)
        ? '${widget.ticket.startTime} – ${widget.ticket.endTime}'
        : null;

    final showCancel = widget.canCancel &&
        widget.orderId != null &&
        widget.ticket.status.toLowerCase() != 'canceled';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F8),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: const Color(0xFF1E293B), size: 20.w),
                    onPressed: () => context.router.maybePop(),
                  ),
                  const Spacer(),
                  'ticket_receipt'
                      .tr()
                      .s(14)
                      .w(700)
                      .c(const Color(0xFF1E293B)),
                  const Spacer(),
                  SizedBox(width: 44.w),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ReceiptBody(
                      primary: primary,
                      ticketNo: ticketNo,
                      ticketDate: _formatDate(widget.ticket.ticketDate),
                      time: time,
                      className: widget.className,
                      branch: widget.branch,
                      ageFrom: widget.ticket.ageFrom,
                      ageTo: widget.ticket.ageTo,
                      price: widget.ticket.price,
                      paidPrice: widget.paidPrice,
                      status: widget.ticket.status,
                      fromPromocode: widget.fromPromocode,
                    ),
                  ],
                ),
              ),
            ),
            if (showCancel)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  8.h,
                  20.w,
                  MediaQuery.of(context).viewPadding.bottom + 16.h,
                ),
                child: _CancelButton(
                  loading: _cancelling,
                  onTap: _showCancelSheet,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Cancel button ────────────────────────────────────────────────────────────

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap, this.loading = false});
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEF4444), width: 1.5),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(
                    color: Color(0xFFEF4444),
                    strokeWidth: 2,
                  ),
                )
              else ...[
                Icon(Icons.cancel_outlined,
                    color: const Color(0xFFEF4444), size: 18.w),
                8.kw,
                'booking_cancel_title'
                    .tr()
                    .s(15)
                    .w(700)
                    .c(const Color(0xFFEF4444)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cancel confirmation bottomsheet ─────────────────────────────────────────

class _CancelBookingSheet extends StatelessWidget {
  const _CancelBookingSheet({this.ticketNo, this.className});
  final String? ticketNo;
  final String? className;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      padding: EdgeInsets.fromLTRB(
        24.w,
        8.h,
        24.w,
        MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).viewPadding.bottom +
            24.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(bottom: 24.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          // Warning icon
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cancel_outlined,
              color: const Color(0xFFEF4444),
              size: 32.w,
            ),
          ),
          20.kh,
          'booking_cancel_title'
              .tr()
              .s(20)
              .w(800)
              .c(const Color(0xFF1E293B)),
          12.kh,
          Text(
            'booking_cancel_confirm'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF64748B),
              height: 1.6,
            ),
          ),
          if (className != null && className!.isNotEmpty) ...[
            16.kh,
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.confirmation_number_rounded,
                      color: const Color(0xFF64748B), size: 18.w),
                  10.kw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        className!
                            .s(13)
                            .w(600)
                            .c(const Color(0xFF1E293B)),
                        if (ticketNo != null) ...[
                          4.kh,
                          '#$ticketNo'
                              .s(12)
                              .w(500)
                              .c(const Color(0xFF94A3B8)),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          28.kh,
          // Keep button (primary)
          SizedBox(
            width: double.infinity,
            child: Material(
              color: const Color(0xFF6C4EF2),
              borderRadius: BorderRadius.circular(16.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () => Navigator.of(context).pop(false),
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C4EF2).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: 'booking_keep'
                        .tr()
                        .s(16)
                        .w(700)
                        .c(Colors.white),
                  ),
                ),
              ),
            ),
          ),
          12.kh,
          // Cancel action button (secondary)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  side: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
              ),
              child: 'booking_cancel_action'
                  .tr()
                  .s(15)
                  .w(600)
                  .c(const Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Receipt body (unchanged) ─────────────────────────────────────────────────

class _ReceiptBody extends StatelessWidget {
  const _ReceiptBody({
    required this.primary,
    required this.ticketNo,
    required this.ticketDate,
    required this.time,
    required this.className,
    required this.branch,
    required this.ageFrom,
    required this.ageTo,
    required this.price,
    required this.status,
    this.paidPrice,
    this.fromPromocode = false,
  });

  final Color primary;
  final String ticketNo;
  final String ticketDate;
  final String? time;
  final String? className;
  final String? branch;
  final int ageFrom;
  final int ageTo;
  final num price;
  final num? paidPrice;
  final String status;
  final bool fromPromocode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3C539A).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient header with Lumi branding, ticket # and date/time front
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, const Color(0xFFFF7093)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Assets.icons.lumiLogo.image(
                      width: 28.w,
                      height: 28.w,
                      color: Colors.white,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.auto_awesome,
                        size: 22.w,
                        color: Colors.white,
                      ),
                    ),
                    8.kw,
                    Text(
                      'LUMI',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    _StatusChip(status: status),
                  ],
                ),
                18.kh,
                Text(
                  'ticket_label'.tr(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.8),
                    letterSpacing: 2,
                  ),
                ),
                4.kh,
                Text(
                  '#$ticketNo',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                16.kh,
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 14.sp, color: Colors.white.withOpacity(0.9)),
                    6.kw,
                    Expanded(
                      child: Text(
                        ticketDate,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (time != null) ...[
                  6.kh,
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 14.sp, color: Colors.white.withOpacity(0.9)),
                      6.kw,
                      Text(
                        time!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const _Perforation(),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (className != null && className!.isNotEmpty) ...[
                  _ReceiptRow(label: 'ticket_class'.tr(), value: className!),
                  12.kh,
                ],
                if (branch != null && branch!.isNotEmpty) ...[
                  _ReceiptRow(label: 'ticket_venue'.tr(), value: branch!),
                  12.kh,
                ],
                _ReceiptRow(
                  label: 'ticket_age_label'.tr(),
                  value:
                      'ticket_age_value'.tr(args: ['$ageFrom', '$ageTo']),
                ),
                16.kh,
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade200,
                        Colors.grey.shade300,
                        Colors.grey.shade200,
                      ],
                    ),
                  ),
                ),
                16.kh,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'amount_paid'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (paidPrice != null && paidPrice != price) ...[
                          Text(
                            price.toRawUzsPrice(),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          4.kh,
                        ],
                        Text(
                          (paidPrice ?? price).toRawUzsPrice(),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w900,
                            color: paidPrice != null && paidPrice != price
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF1E293B),
                          ),
                        ),
                        if (paidPrice != null && paidPrice != price) ...[
                          4.kh,
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.local_offer_rounded,
                                    size: 10.sp,
                                    color: const Color(0xFF16A34A)),
                                3.kw,
                                Text(
                                  (fromPromocode
                                          ? 'booking_promocode_discount'
                                          : 'booking_coupon_discount')
                                      .tr(),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const _Perforation(),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14.sp, color: const Color(0xFF64748B)),
                6.kw,
                Expanded(
                  child: Text(
                    'ticket_present_at_venue'.tr(),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w700,
            ),
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
    final lower = status.toLowerCase();
    final String label;
    switch (lower) {
      case 'confirmed':
        label = 'ticket_confirmed'.tr();
        break;
      case 'canceled':
      case 'cancelled':
        label = 'order_cancelled'.tr();
        break;
      default:
        label = 'ticket_pending'.tr();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }
}

class _Perforation extends StatelessWidget {
  const _Perforation();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 16.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(left: -10.w, child: const _Notch()),
          Positioned(right: -10.w, child: const _Notch()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              children: List.generate(
                40,
                (_) => Expanded(
                  child: Container(
                    height: 1.h,
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Notch extends StatelessWidget {
  const _Notch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F8),
        shape: BoxShape.circle,
      ),
    );
  }
}

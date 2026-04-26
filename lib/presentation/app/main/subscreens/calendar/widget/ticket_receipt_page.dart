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

/// A single-ticket receipt screen opened from the paid booking detail. Shows
/// the ticket id and its date/time prominently at the top, followed by class
/// and venue metadata — styled as a Lumi-branded paper receipt.
@RoutePage()
class TicketReceiptPage extends StatelessWidget {
  const TicketReceiptPage({
    super.key,
    required this.ticket,
    this.className,
    this.branch,
  });

  final OrderTicket ticket;
  final String? className;
  final String? branch;

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final d = DateTime.parse(iso);
      const months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      const days = [
        'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
      ];
      return '${days[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final ticketNo = ticket.ticketNo ?? '----';
    final time = (ticket.startTime != null && ticket.endTime != null)
        ? '${ticket.startTime} – ${ticket.endTime}'
        : null;

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
                      ticketDate: _formatDate(ticket.ticketDate),
                      time: time,
                      className: className,
                      branch: branch,
                      ageFrom: ticket.ageFrom,
                      ageTo: ticket.ageTo,
                      price: ticket.price,
                      status: ticket.status,
                      ticketId: ticket.id,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
    required this.ticketId,
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
  final String status;
  final String ticketId;

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
                  'TICKET',
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
                  _ReceiptRow(label: 'Class', value: className!),
                  12.kh,
                ],
                if (branch != null && branch!.isNotEmpty) ...[
                  _ReceiptRow(label: 'Venue', value: branch!),
                  12.kh,
                ],
                _ReceiptRow(label: 'Age', value: '$ageFrom–$ageTo years'),
                12.kh,
                _ReceiptRow(
                  label: 'ticket_id'.tr(),
                  value: ticketId.isNotEmpty
                      ? ticketId.substring(
                          (ticketId.length - 10).clamp(0, ticketId.length))
                      : '—',
                  mono: true,
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
                    Text(
                      price.toRawUzsPrice(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1E293B),
                      ),
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
                    'Please present this ticket at the venue.',
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
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.mono = false,
  });
  final String label;
  final String value;
  final bool mono;

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
              fontFeatures: mono ? const [FontFeature.tabularFigures()] : null,
              letterSpacing: mono ? 0.4 : 0,
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
        label = 'Confirmed';
        break;
      case 'canceled':
      case 'cancelled':
        label = 'Cancelled';
        break;
      default:
        label = 'Pending';
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

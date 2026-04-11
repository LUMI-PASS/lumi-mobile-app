import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/router/app_router.dart';

class ScheduleWidget extends StatelessWidget {
  const ScheduleWidget({super.key, required this.scheduleItem});

  final ScheduleItem? scheduleItem;

  RelatedBooking? get _confirmedBooking {
    final bookings = scheduleItem?.relatedBookings ?? [];
    return bookings
            .where((b) => b.bookingStatus?.toUpperCase() == 'CONFIRMED')
            .firstOrNull ??
        bookings.firstOrNull;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = scheduleItem;
    if (item == null) return const SizedBox.shrink();

    final cls = item.scheduleClass;
    final child = item.forChild;
    final booking = _confirmedBooking;
    final chargedAmount = booking?.chargedCoinAmount;
    final isTrial = booking?.isTrialBooking ?? false;

    return Container3d(
      onTap: () => context.router.push(ScheduleDetailRoute(scheduleItem: item)),
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(14.w),
      depth: 3,
      backgroundColor: Colors.white,
      borderColor: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(18.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date + Time + Price badges
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              // Date badge
              _Badge(
                icon: Icons.calendar_today_rounded,
                text: _formatDate(item.forDate),
                bgColor: const Color(0xFFEEF2FF),
                textColor: const Color(0xFF4338CA),
              ),
              // Time badge
              _Badge(
                icon: Icons.access_time_rounded,
                text: '${item.startTime ?? ''} - ${item.endTime ?? ''}',
                bgColor: const Color(0xFFF1F5F9),
                textColor: const Color(0xFF475569),
              ),
              // Price badge
              if (chargedAmount != null)
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isTrial
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      '$chargedAmount'
                          .s(11)
                          .w(700)
                          .c(isTrial
                              ? const Color(0xFF059669)
                              : const Color(0xFFEA580C)),
                      4.kw,
                      Assets.icons.coinLumi.image(width: 14.w, height: 14.h),
                    ],
                  ),
                ),
            ],
          ),

          12.kh,

          // Class title
          (cls?.title ?? '').s(16).w(700).c(const Color(0xFF1E293B)),

          10.kh,

          // Child name badge
          if (child != null)
            _Badge(
              icon: Icons.person_outline_rounded,
              text: '${child.firstName ?? ''} ${child.lastName ?? ''}'.trim(),
              bgColor: const Color(0xFFEEF2FF),
              textColor: const Color(0xFF4338CA),
            ),

          if (cls?.branch != null) ...[
            8.kh,
            _Badge(
              icon: Icons.location_on_outlined,
              text: cls!.branch!,
              bgColor: const Color(0xFFF5F3FF),
              textColor: const Color(0xFF7C3AED),
            ),
          ],

          12.kh,

          // View Details button
          SizedBox(
            width: double.infinity,
            child: Container3d(
              onTap: () => context.router.push(ScheduleDetailRoute(scheduleItem: item)),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              depth: 2,
              backgroundColor: context.colors.primary.withOpacity(0.06),
              borderColor: context.colors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 14.w, color: context.colors.primary),
                    6.kw,
                    "View Details"
                        .s(13)
                        .w(700)
                        .c(context.colors.primary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.text,
    required this.bgColor,
    required this.textColor,
  });

  final IconData icon;
  final String text;
  final Color bgColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.w, color: textColor),
          4.kw,
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

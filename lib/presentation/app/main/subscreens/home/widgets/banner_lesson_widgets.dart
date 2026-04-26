import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/date_extensions.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/container_3d.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

class UpcomingClassWidget extends StatelessWidget {
  const UpcomingClassWidget({super.key, required this.upcomingClass});

  final HomUpcomingClass upcomingClass;

  @override
  Widget build(BuildContext context) {
    // Resolve the confirmed booking or fallback to first
    final related = upcomingClass.relatedBookings ?? [];
    final confirmed = related.where((b) => b.bookingStatus == 'CONFIRMED').firstOrNull;
    final selectedBooking = confirmed ?? (related.isNotEmpty ? related.first : null);
    final chargedAmount = selectedBooking?.chargedCoinAmount;
    final isTrialBooking = selectedBooking?.isTrialBooking ?? false;

    final child = upcomingClass.forChild;
    final childFullName = '${child?.firstName ?? ''} ${child?.lastName ?? ''}'.trim();

    final startFormatted = upcomingClass.startTime != null
        ? DateFormat('HH:mm').format(upcomingClass.startTime!)
        : '';
    final endFormatted = upcomingClass.endTime != null
        ? DateFormat('HH:mm').format(upcomingClass.endTime!)
        : '';
    final timeText = '$startFormatted - $endFormatted';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Container3d(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        backgroundColor: Colors.white,
        borderColor: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(22.r),
        depth: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Child badge + Time badge + Charged amount
            Wrap(
              spacing: 8.w,
              runSpacing: 6.h,
              children: [
                if (childFullName.isNotEmpty)
                  _buildBadge(
                    context,
                    icon: Icons.person_outline_rounded,
                    text: childFullName,
                    bgColor: context.colors.primary.withOpacity(0.1),
                    borderColor: context.colors.primary.withOpacity(0.2),
                    textColor: context.colors.primary,
                  ),
                _buildBadge(
                  context,
                  text: timeText,
                  bgColor: Colors.grey.shade50,
                  borderColor: Colors.grey.shade100,
                  textColor: const Color(0xFF2E3D5D),
                ),
                if (chargedAmount != null)
                  _buildBadge(
                    context,
                    text:
                        '${isTrialBooking ? 'Trial' : 'Full'}: ${chargedAmount.toUzsPrice()}',
                    bgColor: isTrialBooking
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFF7ED),
                    borderColor: isTrialBooking
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFED7AA),
                    textColor: isTrialBooking
                        ? const Color(0xFF047857)
                        : const Color(0xFFC2410C),
                  ),
              ],
            ),
            12.kh,

            // Class name
            (upcomingClass.className ?? '').s(18).w(700).c(const Color(0xFF2E3D5D)),
            12.kh,

            // Branch badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFEDE9FE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.apartment_rounded, size: 16.sp, color: const Color(0xFF6D28D9)),
                  4.kw,
                  (upcomingClass.branchName ?? '').s(12).c(const Color(0xFF6D28D9)),
                ],
              ),
            ),
            if (upcomingClass.branchAddress != null && upcomingClass.branchAddress!.isNotEmpty) ...[
              8.kh,
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16.sp, color: const Color(0xFF4338CA)),
                  4.kw,
                  Expanded(
                    child: Text(
                      upcomingClass.branchAddress!,
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF4338CA)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            16.kh,

            // View Details button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to schedule details if bookingId is available
                  // final bookingId = selectedBooking?.id;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'View Details',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    IconData? icon,
    required String text,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: textColor),
            4.kw,
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
          if (trailing != null) ...[
            4.kw,
            trailing,
          ],
        ],
      ),
    );
  }
}

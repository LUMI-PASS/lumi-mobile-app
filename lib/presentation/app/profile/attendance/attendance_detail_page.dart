import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/constants/constants.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/text_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/widget/base_app_bar.dart';
import 'package:lumi_pass/data/api_model/attendance/attendance_model.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/presentation/app/profile/attendance/cubit/attendance_cubit.dart';
import 'package:lumi_pass/presentation/app/profile/attendance/cubit/attendance_state.dart';
import 'package:lumi_pass/presentation/app/profile/children/children_page.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class AttendanceDetailPage extends BasePage<AttendanceCubit,
    AttendanceBuildable, AttendanceListenable> {
  const AttendanceDetailPage({
    super.key,
    required this.childModel,
  });

  final ChildModel childModel;

  @override
  void init(BuildContext context) {
    context
        .read<AttendanceCubit>()
        .getAttendanceHistory(childModel.id ?? '');
    super.init(context);
  }

  @override
  Widget builder(context, state) {
    final records = state.records;
    final age = childModel.age ?? getAge(childModel.dob);

    return Scaffold(
      appBar: const BaseAppBar(title: 'Attendance Details'),
      body: Column(
        children: [
          // Child info header
          _buildChildHeader(context, age),

          // Records
          Expanded(
            child: state.isDetailLoading
                ? _buildShimmer()
                : records.isEmpty
                    ? _buildEmptyState(context)
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 12.h),
                        itemCount: records.length,
                        separatorBuilder: (_, __) => 10.kh,
                        itemBuilder: (context, index) {
                          return _AttendanceRecordCard(
                              record: records[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildHeader(BuildContext context, int? age) {
    final photoUrl =
        '${Constants.baseUrl}assets/files/child-photo/${childModel.id}';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary.withOpacity(0.08),
            context.colors.primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: context.colors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: context.colors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: childModel.hasPhoto == true
                ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person_rounded,
                      size: 24.w,
                      color: context.colors.primary.withOpacity(0.4),
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    size: 24.w,
                    color: context.colors.primary.withOpacity(0.4),
                  ),
          ),
          12.kw,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                "${childModel.firstName ?? ''} ${childModel.lastName ?? ''}"
                    .s(16)
                    .w(600)
                    .c(context.colors.black ?? Colors.black),
                if (age != null) ...[
                  4.kh,
                  "$age years old"
                      .s(13)
                      .w(400)
                      .c(Colors.grey.shade600),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: 36.w,
                color: Colors.grey.shade400,
              ),
            ),
            16.kh,
            "No attendance records yet"
                .s(15)
                .w(600)
                .c(context.colors.black ?? Colors.black),
            8.kh,
            "This child has no attendance records"
                .s(13)
                .w(400)
                .c(Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: List.generate(
            4,
            (_) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Container(
                height: 120.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AttendanceRecordCard extends StatelessWidget {
  const _AttendanceRecordCard({required this.record});

  final AttendanceRecord record;

  @override
  Widget build(BuildContext context) {
    final isCanceled = (record.attendanceStatus?.toUpperCase().contains('CANCEL') ?? false) ||
        (record.bookingStatus?.toUpperCase().contains('CANCEL') ?? false);
    final statusInfo = _getStatusInfo(record.attendanceStatus);
    final bookingStatusInfo = _getBookingStatusInfo(record.bookingStatus);

    String dateStr = '';
    String timeStr = '';
    try {
      if (record.scheduleDate != null) {
        final date = DateTime.parse(record.scheduleDate!);
        dateStr = DateFormat('MMM dd, yyyy').format(date);
      }
      if (record.startTime != null && record.endTime != null) {
        final start = DateTime.parse(record.startTime!);
        final end = DateTime.parse(record.endTime!);
        timeStr =
            '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
      }
    } catch (_) {}

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class name + status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: (record.className ?? 'Unknown Class')
                    .s(15)
                    .w(600)
                    .c(context.colors.black ?? Colors.black),
              ),
              8.kw,
              if (isCanceled)
                _StatusBadge(
                  label: bookingStatusInfo.label,
                  color: bookingStatusInfo.color,
                )
              else
                _StatusBadge(
                  label: statusInfo.label,
                  color: statusInfo.color,
                ),
            ],
          ),
          10.kh,

          // Category & Branch tags
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              if (record.categoryTitle != null)
                _TagChip(
                  icon: Icons.category_outlined,
                  label: record.categoryTitle!,
                  color: context.colors.primary,
                ),
              if (record.branchTitle != null)
                _TagChip(
                  icon: Icons.location_on_outlined,
                  label: record.branchTitle!,
                  color: const Color(0xFF3B82F6),
                ),
            ],
          ),
          10.kh,

          // Date & Time
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                if (dateStr.isNotEmpty) ...[
                  Icon(Icons.calendar_today_outlined,
                      size: 14.w, color: Colors.grey.shade600),
                  6.kw,
                  dateStr.s(12).w(500).c(Colors.grey.shade700),
                ],
                if (dateStr.isNotEmpty && timeStr.isNotEmpty) ...[
                  16.kw,
                ],
                if (timeStr.isNotEmpty) ...[
                  Icon(Icons.access_time_outlined,
                      size: 14.w, color: Colors.grey.shade600),
                  6.kw,
                  timeStr.s(12).w(500).c(Colors.grey.shade700),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusData _getStatusInfo(String? status) {
    switch (status?.toUpperCase()) {
      case 'CHECKED_IN':
        return _StatusData('Present', const Color(0xFF22C55E));
      case 'NO_SHOW':
        return _StatusData('Absent', const Color(0xFFEF4444));
      case 'LATE':
        return _StatusData('Late', const Color(0xFFF59E0B));
      case 'NOT_APPLICABLE':
        return _StatusData('Confirmed', const Color(0xFF6366F1));
      case 'CANCELLED':
      case 'CANCELED':
        return _StatusData('Cancelled', const Color(0xFFEF4444));
      default:
        return _StatusData(status ?? 'Not marked', Colors.grey);
    }
  }

  _StatusData _getBookingStatusInfo(String? status) {
    switch (status?.toUpperCase()) {
      case 'CANCELED_BY_PARENT':
      case 'CANCELLED_BY_PARENT':
        return _StatusData('Canceled by Parent', const Color(0xFFEF4444));
      case 'CANCELED_BY_PARTNER':
      case 'CANCELLED_BY_PARTNER':
        return _StatusData('Canceled by Partner', const Color(0xFFF59E0B));
      case 'CANCELED_BY_SYSTEM':
      case 'CANCELLED_BY_SYSTEM':
        return _StatusData('Canceled by System', Colors.grey.shade600);
      case 'CANCELLED':
      case 'CANCELED':
        return _StatusData('Cancelled', const Color(0xFFEF4444));
      case 'CONFIRMED':
        return _StatusData('Confirmed', const Color(0xFF6366F1));
      case 'PENDING':
        return _StatusData('Pending', const Color(0xFFF59E0B));
      default:
        return _StatusData(status ?? 'Unknown', Colors.grey);
    }
  }
}

class _StatusData {
  final String label;
  final Color color;
  _StatusData(this.label, this.color);
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: label.s(11).w(600).c(color),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.w, color: color),
          4.kw,
          label.s(11).w(500).c(color),
        ],
      ),
    );
  }
}

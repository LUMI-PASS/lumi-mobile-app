// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AttendanceRecordImpl _$$AttendanceRecordImplFromJson(
        Map<String, dynamic> json) =>
    _$AttendanceRecordImpl(
      bookingId: json['booking_id'] as String?,
      attendanceStatus: json['attendance_status'] as String?,
      bookingStatus: json['booking_status'] as String?,
      className: json['class_name'] as String?,
      categoryTitle: json['category_title'] as String?,
      branchTitle: json['branch_title'] as String?,
      scheduleDate: json['schedule_date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );

Map<String, dynamic> _$$AttendanceRecordImplToJson(
        _$AttendanceRecordImpl instance) =>
    <String, dynamic>{
      'booking_id': instance.bookingId,
      'attendance_status': instance.attendanceStatus,
      'booking_status': instance.bookingStatus,
      'class_name': instance.className,
      'category_title': instance.categoryTitle,
      'branch_title': instance.branchTitle,
      'schedule_date': instance.scheduleDate,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
    };

import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_model.freezed.dart';
part 'attendance_model.g.dart';

@freezed
class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    @JsonKey(name: "booking_id") String? bookingId,
    @JsonKey(name: "attendance_status") String? attendanceStatus,
    @JsonKey(name: "booking_status") String? bookingStatus,
    @JsonKey(name: "class_name") String? className,
    @JsonKey(name: "category_title") String? categoryTitle,
    @JsonKey(name: "branch_title") String? branchTitle,
    @JsonKey(name: "schedule_date") String? scheduleDate,
    @JsonKey(name: "start_time") String? startTime,
    @JsonKey(name: "end_time") String? endTime,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);
}

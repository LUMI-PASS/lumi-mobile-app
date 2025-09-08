import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_class_model.freezed.dart';
part 'schedule_class_model.g.dart';

@freezed
class ScheduleClassModel with _$ScheduleClassModel {
  const factory ScheduleClassModel({
    bool? success,
    ScheduleData? data,
  }) = _ScheduleClassModel;

  factory ScheduleClassModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleClassModelFromJson(json);
}

@freezed
class ScheduleData with _$ScheduleData {
  const factory ScheduleData({
    @JsonKey(name: 'class_id') String? classId,
    @JsonKey(name: 'child_id') String? childId,
    @JsonKey(name: 'from_date') String? fromDate,
    @JsonKey(name: 'to_date') String? toDate,
    @JsonKey(name: 'time_slots') List<TimeSlot>? timeSlots,
    @JsonKey(name: 'total_slots') int? totalSlots,
    @JsonKey(name: 'available_slots') int? availableSlots,
  }) = _ScheduleData;

  factory ScheduleData.fromJson(Map<String, dynamic> json) =>
      _$ScheduleDataFromJson(json);
}

@freezed
class TimeSlot with _$TimeSlot {
  const factory TimeSlot({
    @JsonKey(name: 'schedule_id') String? scheduleId,
    @JsonKey(name: 'for_date') String? forDate,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    int? capacity,
    @JsonKey(name: 'booked_count') int? bookedCount,
    @JsonKey(name: 'empty_seats') int? emptySeats,
    @JsonKey(name: 'is_booking_conflict') bool? isBookingConflict,
    @JsonKey(name: 'is_available') bool? isAvailable,
  }) = _TimeSlot;

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);
}

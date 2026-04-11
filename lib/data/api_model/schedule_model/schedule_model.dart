import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_model.freezed.dart';
part 'schedule_model.g.dart';

@freezed
class ScheduleModel with _$ScheduleModel {
  const factory ScheduleModel({
    bool? success,
    List<ScheduleItem>? data,
    int? page,
    int? pages,
    int? limit,
    int? total,
  }) = _ScheduleModel;

  factory ScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ScheduleModelFromJson(json);
}

@freezed
class ScheduleItem with _$ScheduleItem {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ScheduleItem({
    String? id,
    @JsonKey(name: 'class') ScheduleClass? scheduleClass,
    @JsonKey(name: 'day_of_week') String? dayOfWeek,
    @JsonKey(name: 'for_date') String? forDate,
    @JsonKey(name: 'start_time') String? startTime,
    @JsonKey(name: 'end_time') String? endTime,
    @JsonKey(name: 'start_date') String? startDate,
    @JsonKey(name: 'end_date') String? endDate,
    int? capacity,
    String? status,
    String? notes,
    @JsonKey(name: 'for_child') ScheduleChild? forChild,
    @JsonKey(name: 'related_bookings') List<RelatedBooking>? relatedBookings,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ScheduleItem;

  factory ScheduleItem.fromJson(Map<String, dynamic> json) =>
      _$ScheduleItemFromJson(json);
}

@freezed
class ScheduleClass with _$ScheduleClass {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ScheduleClass({
    String? id,
    String? branch,
    String? category,
    String? title,
    String? description,
    int? duration,
    num? price,
    @JsonKey(name: 'trial_price') num? trialPrice,
    @JsonKey(name: 'min_age') int? minAge,
    @JsonKey(name: 'max_age') int? maxAge,
    String? gender,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'has_photo') bool? hasPhoto,
  }) = _ScheduleClass;

  factory ScheduleClass.fromJson(Map<String, dynamic> json) =>
      _$ScheduleClassFromJson(json);
}

@freezed
class ScheduleChild with _$ScheduleChild {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ScheduleChild({
    String? id,
    @JsonKey(name: 'first_name') String? firstName,
    @JsonKey(name: 'last_name') String? lastName,
    String? dob,
    String? gender,
  }) = _ScheduleChild;

  factory ScheduleChild.fromJson(Map<String, dynamic> json) =>
      _$ScheduleChildFromJson(json);
}

@freezed
class RelatedBooking with _$RelatedBooking {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory RelatedBooking({
    String? id,
    @JsonKey(name: 'schedule_id') String? scheduleId,
    @JsonKey(name: 'child_id') String? childId,
    @JsonKey(name: 'booking_status') String? bookingStatus,
    @JsonKey(name: 'charged_coin_amount') num? chargedCoinAmount,
    @JsonKey(name: 'is_trial_booking') bool? isTrialBooking,
    @JsonKey(name: 'attendance_status') String? attendanceStatus,
    @JsonKey(name: 'cancelled_at') String? cancelledAt,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _RelatedBooking;

  factory RelatedBooking.fromJson(Map<String, dynamic> json) =>
      _$RelatedBookingFromJson(json);
}

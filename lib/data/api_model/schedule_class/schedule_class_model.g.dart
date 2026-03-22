// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleClassModelImpl _$$ScheduleClassModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ScheduleClassModelImpl(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : ScheduleData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ScheduleClassModelImplToJson(
        _$ScheduleClassModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

_$ScheduleDataImpl _$$ScheduleDataImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleDataImpl(
      classId: json['class_id'] as String?,
      childId: json['child_id'] as String?,
      fromDate: json['from_date'] as String?,
      toDate: json['to_date'] as String?,
      timeSlots: (json['time_slots'] as List<dynamic>?)
          ?.map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalSlots: (json['total_slots'] as num?)?.toInt(),
      availableSlots: (json['available_slots'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ScheduleDataImplToJson(_$ScheduleDataImpl instance) =>
    <String, dynamic>{
      'class_id': instance.classId,
      'child_id': instance.childId,
      'from_date': instance.fromDate,
      'to_date': instance.toDate,
      'time_slots': instance.timeSlots,
      'total_slots': instance.totalSlots,
      'available_slots': instance.availableSlots,
    };

_$TimeSlotImpl _$$TimeSlotImplFromJson(Map<String, dynamic> json) =>
    _$TimeSlotImpl(
      scheduleId: json['schedule_id'] as String?,
      forDate: json['for_date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      capacity: (json['capacity'] as num?)?.toInt(),
      bookedCount: (json['booked_count'] as num?)?.toInt(),
      emptySeats: (json['empty_seats'] as num?)?.toInt(),
      isBookingConflict: json['is_booking_conflict'] as bool?,
      isAvailable: json['is_available'] as bool?,
    );

Map<String, dynamic> _$$TimeSlotImplToJson(_$TimeSlotImpl instance) =>
    <String, dynamic>{
      'schedule_id': instance.scheduleId,
      'for_date': instance.forDate,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'capacity': instance.capacity,
      'booked_count': instance.bookedCount,
      'empty_seats': instance.emptySeats,
      'is_booking_conflict': instance.isBookingConflict,
      'is_available': instance.isAvailable,
    };

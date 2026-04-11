// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScheduleModelImpl _$$ScheduleModelImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleModelImpl(
      success: json['success'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: (json['page'] as num?)?.toInt(),
      pages: (json['pages'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      total: (json['total'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ScheduleModelImplToJson(_$ScheduleModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
      'page': instance.page,
      'pages': instance.pages,
      'limit': instance.limit,
      'total': instance.total,
    };

_$ScheduleItemImpl _$$ScheduleItemImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleItemImpl(
      id: json['id'] as String?,
      scheduleClass: json['class'] == null
          ? null
          : ScheduleClass.fromJson(json['class'] as Map<String, dynamic>),
      dayOfWeek: json['day_of_week'] as String?,
      forDate: json['for_date'] as String?,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      capacity: (json['capacity'] as num?)?.toInt(),
      status: json['status'] as String?,
      notes: json['notes'] as String?,
      forChild: json['for_child'] == null
          ? null
          : ScheduleChild.fromJson(json['for_child'] as Map<String, dynamic>),
      relatedBookings: (json['related_bookings'] as List<dynamic>?)
          ?.map((e) => RelatedBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ScheduleItemImplToJson(_$ScheduleItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'class': instance.scheduleClass,
      'day_of_week': instance.dayOfWeek,
      'for_date': instance.forDate,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'capacity': instance.capacity,
      'status': instance.status,
      'notes': instance.notes,
      'for_child': instance.forChild,
      'related_bookings': instance.relatedBookings,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$ScheduleClassImpl _$$ScheduleClassImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleClassImpl(
      id: json['id'] as String?,
      branch: json['branch'] as String?,
      category: json['category'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      price: json['price'] as num?,
      trialPrice: json['trial_price'] as num?,
      minAge: (json['min_age'] as num?)?.toInt(),
      maxAge: (json['max_age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      isActive: json['is_active'] as bool?,
      hasPhoto: json['has_photo'] as bool?,
    );

Map<String, dynamic> _$$ScheduleClassImplToJson(_$ScheduleClassImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branch': instance.branch,
      'category': instance.category,
      'title': instance.title,
      'description': instance.description,
      'duration': instance.duration,
      'price': instance.price,
      'trial_price': instance.trialPrice,
      'min_age': instance.minAge,
      'max_age': instance.maxAge,
      'gender': instance.gender,
      'is_active': instance.isActive,
      'has_photo': instance.hasPhoto,
    };

_$ScheduleChildImpl _$$ScheduleChildImplFromJson(Map<String, dynamic> json) =>
    _$ScheduleChildImpl(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
    );

Map<String, dynamic> _$$ScheduleChildImplToJson(_$ScheduleChildImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'dob': instance.dob,
      'gender': instance.gender,
    };

_$RelatedBookingImpl _$$RelatedBookingImplFromJson(Map<String, dynamic> json) =>
    _$RelatedBookingImpl(
      id: json['id'] as String?,
      scheduleId: json['schedule_id'] as String?,
      childId: json['child_id'] as String?,
      bookingStatus: json['booking_status'] as String?,
      chargedCoinAmount: json['charged_coin_amount'] as num?,
      isTrialBooking: json['is_trial_booking'] as bool?,
      attendanceStatus: json['attendance_status'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$RelatedBookingImplToJson(
        _$RelatedBookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schedule_id': instance.scheduleId,
      'child_id': instance.childId,
      'booking_status': instance.bookingStatus,
      'charged_coin_amount': instance.chargedCoinAmount,
      'is_trial_booking': instance.isTrialBooking,
      'attendance_status': instance.attendanceStatus,
      'cancelled_at': instance.cancelledAt,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookingRequestImpl _$$BookingRequestImplFromJson(Map<String, dynamic> json) =>
    _$BookingRequestImpl(
      scheduleId: json['schedule_id'] as String,
      childId: json['child_id'] as String,
      subscriptionId: json['subscription_id'] as String,
    );

Map<String, dynamic> _$$BookingRequestImplToJson(
        _$BookingRequestImpl instance) =>
    <String, dynamic>{
      'schedule_id': instance.scheduleId,
      'child_id': instance.childId,
      'subscription_id': instance.subscriptionId,
    };

_$BookingResponseImpl _$$BookingResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$BookingResponseImpl(
      id: json['id'] as String?,
      scheduleId: json['schedule_id'] as String?,
      childId: json['child_id'] as String?,
      bookingStatus: json['booking_status'] as String?,
      chargedCoinAmount: json['charged_coin_amount'] as num?,
      isTrialBooking: json['is_trial_booking'] as bool?,
      attendanceStatus: json['attendance_status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$BookingResponseImplToJson(
        _$BookingResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schedule_id': instance.scheduleId,
      'child_id': instance.childId,
      'booking_status': instance.bookingStatus,
      'charged_coin_amount': instance.chargedCoinAmount,
      'is_trial_booking': instance.isTrialBooking,
      'attendance_status': instance.attendanceStatus,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$PurchaseResponseImpl _$$PurchaseResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseResponseImpl(
      id: json['id'] as String?,
      parentId: json['parent_id'] as String?,
      tariffId: json['tariff_id'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as String?,
      coins: (json['coins'] as num?)?.toInt(),
      amount: (json['amount'] as num?)?.toInt(),
      transaction: json['transaction'] == null
          ? null
          : PurchaseTransaction.fromJson(
              json['transaction'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$PurchaseResponseImplToJson(
        _$PurchaseResponseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_id': instance.parentId,
      'tariff_id': instance.tariffId,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'status': instance.status,
      'coins': instance.coins,
      'amount': instance.amount,
      'transaction': instance.transaction,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$PurchaseTransactionImpl _$$PurchaseTransactionImplFromJson(
        Map<String, dynamic> json) =>
    _$PurchaseTransactionImpl(
      id: json['id'] as String?,
      paymentMethod: json['payment_method'] as String?,
      status: json['status'] as String?,
      checkoutUrl: json['checkout_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$PurchaseTransactionImplToJson(
        _$PurchaseTransactionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payment_method': instance.paymentMethod,
      'status': instance.status,
      'checkout_url': instance.checkoutUrl,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletTransactionModelImpl _$$WalletTransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WalletTransactionModelImpl(
      id: json['_id'] as String?,
      kindRaw: json['kind'] as String?,
      amount: json['amount'] as num? ?? 0,
      balanceAfter: json['balance_after'] as num? ?? 0,
      orderId: json['order_id'] as String?,
      activityId: json['activity_id'] as String?,
      earnType: json['earn_type'] as String?,
      percent: json['percent'] as num?,
      baseAmount: json['base_amount'] as num?,
      status: json['status'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
      activityName: json['activity_name'] as String?,
      subcourseName: json['subcourse_name'] as String?,
      coursePurchase: json['course_purchase'] as String?,
    );

Map<String, dynamic> _$$WalletTransactionModelImplToJson(
        _$WalletTransactionModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'kind': instance.kindRaw,
      'amount': instance.amount,
      'balance_after': instance.balanceAfter,
      'order_id': instance.orderId,
      'activity_id': instance.activityId,
      'earn_type': instance.earnType,
      'percent': instance.percent,
      'base_amount': instance.baseAmount,
      'status': instance.status,
      'note': instance.note,
      'created_at': instance.createdAt,
      'activity_name': instance.activityName,
      'subcourse_name': instance.subcourseName,
      'course_purchase': instance.coursePurchase,
    };

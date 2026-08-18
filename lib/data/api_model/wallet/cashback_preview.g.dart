// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cashback_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CashbackPreviewImpl _$$CashbackPreviewImplFromJson(
        Map<String, dynamic> json) =>
    _$CashbackPreviewImpl(
      earnType: json['earn_type'] as String?,
      percent: json['percent'] as num? ?? 0,
      amount: json['amount'] as num? ?? 0,
      maxCashbackAmount: json['max_cashback_amount'] as num?,
      minOrderAmount: json['min_order_amount'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'UZS',
    );

Map<String, dynamic> _$$CashbackPreviewImplToJson(
        _$CashbackPreviewImpl instance) =>
    <String, dynamic>{
      'earn_type': instance.earnType,
      'percent': instance.percent,
      'amount': instance.amount,
      'max_cashback_amount': instance.maxCashbackAmount,
      'min_order_amount': instance.minOrderAmount,
      'currency': instance.currency,
    };

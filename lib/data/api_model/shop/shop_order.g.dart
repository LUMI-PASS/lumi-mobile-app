// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShopDeliveryImpl _$$ShopDeliveryImplFromJson(Map<String, dynamic> json) =>
    _$ShopDeliveryImpl(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      address: json['address'] as String? ?? '',
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String? ?? '',
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$$ShopDeliveryImplToJson(_$ShopDeliveryImpl instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'address': instance.address,
      'contact_name': instance.contactName,
      'contact_phone': instance.contactPhone,
      'comment': instance.comment,
    };

_$ShopOrderItemImpl _$$ShopOrderItemImplFromJson(Map<String, dynamic> json) =>
    _$ShopOrderItemImpl(
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as Map<String, dynamic>? ?? null,
      image: json['image'] as String?,
      unitPrice: json['unit_price'] as num? ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$ShopOrderItemImplToJson(_$ShopOrderItemImpl instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'name': instance.name,
      'image': instance.image,
      'unit_price': instance.unitPrice,
      'count': instance.count,
    };

_$ShopOrderEventImpl _$$ShopOrderEventImplFromJson(Map<String, dynamic> json) =>
    _$ShopOrderEventImpl(
      status: $enumDecode(_$ShopOrderStatusEnumMap, json['status']),
      at: json['at'] == null ? null : DateTime.parse(json['at'] as String),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$$ShopOrderEventImplToJson(
        _$ShopOrderEventImpl instance) =>
    <String, dynamic>{
      'status': _$ShopOrderStatusEnumMap[instance.status]!,
      'at': instance.at?.toIso8601String(),
      'note': instance.note,
    };

const _$ShopOrderStatusEnumMap = {
  ShopOrderStatus.isNew: 'new',
  ShopOrderStatus.confirmed: 'confirmed',
  ShopOrderStatus.delivering: 'delivering',
  ShopOrderStatus.delivered: 'delivered',
  ShopOrderStatus.canceled: 'canceled',
};

_$ShopOrderImpl _$$ShopOrderImplFromJson(Map<String, dynamic> json) =>
    _$ShopOrderImpl(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      orderId: json['order_id'] as String?,
      status: $enumDecodeNullable(_$ShopOrderStatusEnumMap, json['status']) ??
          ShopOrderStatus.isNew,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => ShopOrderItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      delivery: json['delivery'] == null
          ? null
          : ShopDelivery.fromJson(json['delivery'] as Map<String, dynamic>),
      totalAmount: json['total_amount'] as num? ?? 0,
      walletAmount: json['wallet_amount'] as num? ?? 0,
      paidAmount: json['paid_amount'] as num? ?? 0,
      currency: json['currency'] as String? ?? 'UZS',
      promisedBy: json['promised_by'] == null
          ? null
          : DateTime.parse(json['promised_by'] as String),
      paidAt: json['paid_at'] == null
          ? null
          : DateTime.parse(json['paid_at'] as String),
      deliveredAt: json['delivered_at'] == null
          ? null
          : DateTime.parse(json['delivered_at'] as String),
      canceledAt: json['canceled_at'] == null
          ? null
          : DateTime.parse(json['canceled_at'] as String),
      timeline: (json['timeline'] as List<dynamic>?)
              ?.map((e) => ShopOrderEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ShopOrderImplToJson(_$ShopOrderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'order_id': instance.orderId,
      'status': _$ShopOrderStatusEnumMap[instance.status]!,
      'items': instance.items,
      'delivery': instance.delivery,
      'total_amount': instance.totalAmount,
      'wallet_amount': instance.walletAmount,
      'paid_amount': instance.paidAmount,
      'currency': instance.currency,
      'promised_by': instance.promisedBy?.toIso8601String(),
      'paid_at': instance.paidAt?.toIso8601String(),
      'delivered_at': instance.deliveredAt?.toIso8601String(),
      'canceled_at': instance.canceledAt?.toIso8601String(),
      'timeline': instance.timeline,
      'created_at': instance.createdAt?.toIso8601String(),
    };

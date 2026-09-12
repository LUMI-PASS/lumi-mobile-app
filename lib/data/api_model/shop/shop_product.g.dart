// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShopProductImpl _$$ShopProductImplFromJson(Map<String, dynamic> json) =>
    _$ShopProductImpl(
      id: json['id'] as String? ?? '',
      name: json['name'] as Map<String, dynamic>? ?? const {},
      description: json['description'] as Map<String, dynamic>? ?? null,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      price: json['price'] as num? ?? 0,
      coinPrice: json['coin_price'] as num? ?? 0,
      oldPrice: json['old_price'] as num?,
      currency: json['currency'] as String? ?? 'UZS',
      available: (json['available'] as num?)?.toInt() ?? 0,
      inStock: json['in_stock'] as bool? ?? false,
      maxPerOrder: (json['max_per_order'] as num?)?.toInt() ?? 5,
      soldCount: (json['sold_count'] as num?)?.toInt() ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$ShopProductImplToJson(_$ShopProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'images': instance.images,
      'price': instance.price,
      'coin_price': instance.coinPrice,
      'old_price': instance.oldPrice,
      'currency': instance.currency,
      'available': instance.available,
      'in_stock': instance.inStock,
      'max_per_order': instance.maxPerOrder,
      'sold_count': instance.soldCount,
      'tags': instance.tags,
    };

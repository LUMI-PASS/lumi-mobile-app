// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressData _$AddressDataFromJson(Map<String, dynamic> json) => AddressData(
      country: json['country'] as String?,
      region: json['region'] as String?,
      district: json['district'] as String?,
      neighborhood: json['neighborhood'] as String?,
    );

Map<String, dynamic> _$AddressDataToJson(AddressData instance) =>
    <String, dynamic>{
      'country': instance.country,
      'region': instance.region,
      'district': instance.district,
      'neighborhood': instance.neighborhood,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileModelImpl _$$ProfileModelImplFromJson(Map<String, dynamic> json) =>
    _$ProfileModelImpl(
      id: json['_id'] as String?,
      fio: json['fio'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$ProfileModelImplToJson(_$ProfileModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'fio': instance.fio,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'country': instance.country,
      'city': instance.city,
      'role': instance.role,
      'status': instance.status,
    };

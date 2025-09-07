// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildModelImpl _$$ChildModelImplFromJson(Map<String, dynamic> json) =>
    _$ChildModelImpl(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      type: json['type'] as String?,
      childAgeType: json['child_age_type'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      isVerified: json['is_verified'] as bool?,
      hasPhoto: json['has_photo'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
      parent: json['parent'],
    );

Map<String, dynamic> _$$ChildModelImplToJson(_$ChildModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'dob': instance.dob,
      'gender': instance.gender,
      'type': instance.type,
      'child_age_type': instance.childAgeType,
      'city': instance.city,
      'district': instance.district,
      'is_verified': instance.isVerified,
      'has_photo': instance.hasPhoto,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
      'parent': instance.parent,
    };

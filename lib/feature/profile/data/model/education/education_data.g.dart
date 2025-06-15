// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EducationData _$EducationDataFromJson(Map<String, dynamic> json) =>
    EducationData(
      type: json['type'] as String?,
      region: json['region'] as String?,
      district: json['district'] as String?,
      organization: json['organization'] as String?,
    );

Map<String, dynamic> _$EducationDataToJson(EducationData instance) =>
    <String, dynamic>{
      'organization': instance.organization,
      'region': instance.region,
      'district': instance.district,
      'type': instance.type,
    };

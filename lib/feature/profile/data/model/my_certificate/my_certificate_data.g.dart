// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_certificate_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyCertificateData _$MyCertificateDataFromJson(Map<String, dynamic> json) =>
    MyCertificateData(
      id: json['id'] as String?,
      certificate: json['certificate'] as String?,
      courseTitle: json['course'] as String?,
      finishDate: json['finished_at'] as String?,
    );

Map<String, dynamic> _$MyCertificateDataToJson(MyCertificateData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'certificate': instance.certificate,
      'course': instance.courseTitle,
      'finished_at': instance.finishDate,
    };

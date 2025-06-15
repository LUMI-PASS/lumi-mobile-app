// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_certificate_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyCertificateResponse _$MyCertificateResponseFromJson(
        Map<String, dynamic> json) =>
    MyCertificateResponse(
      myCertificate: (json['data'] as List<dynamic>?)
          ?.map((e) => MyCertificateData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MyCertificateResponseToJson(
        MyCertificateResponse instance) =>
    <String, dynamic>{
      'data': instance.myCertificate,
    };

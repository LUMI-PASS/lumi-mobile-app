// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpData _$OtpDataFromJson(Map<String, dynamic> json) => OtpData(
      code: json['code'] as int?,
      codeHash: json['code_hash'] as String,
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$OtpDataToJson(OtpData instance) => <String, dynamic>{
      'code': instance.code,
      'code_hash': instance.codeHash,
      'phone_number': instance.phoneNumber,
      'email': instance.email,
    };

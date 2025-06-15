// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_user_login_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalUserLoginRequest _$LocalUserLoginRequestFromJson(
        Map<String, dynamic> json) =>
    LocalUserLoginRequest(
      phoneNumber: json['phone_number'] as String,
    );

Map<String, dynamic> _$LocalUserLoginRequestToJson(
        LocalUserLoginRequest instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
    };

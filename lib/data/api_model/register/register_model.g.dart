// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RegisterModelImpl _$$RegisterModelImplFromJson(Map<String, dynamic> json) =>
    _$RegisterModelImpl(
      phoneNumber: json['phone_number'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      fio: json['fio'] as String?,
      codeHash: json['codeHash'] as String?,
      code: (json['code'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$RegisterModelImplToJson(_$RegisterModelImpl instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'email': instance.email,
      'password': instance.password,
      'fio': instance.fio,
      'codeHash': instance.codeHash,
      'code': instance.code,
    };

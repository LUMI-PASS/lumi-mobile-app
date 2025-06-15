// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModulesResponse _$ModulesResponseFromJson(Map<String, dynamic> json) =>
    ModulesResponse(
      modules: (json['data'] as List<dynamic>?)
          ?.map((e) => ModuleData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ModulesResponseToJson(ModulesResponse instance) =>
    <String, dynamic>{
      'data': instance.modules,
    };

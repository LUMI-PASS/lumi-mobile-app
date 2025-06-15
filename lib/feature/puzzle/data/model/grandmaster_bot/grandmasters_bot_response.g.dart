// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grandmasters_bot_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrandMasterBotResponse _$GrandMasterBotResponseFromJson(
        Map<String, dynamic> json) =>
    GrandMasterBotResponse(
      grandmasterBotData: (json['data'] as List<dynamic>?)
          ?.map((e) => GrandmasterBotData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GrandMasterBotResponseToJson(
        GrandMasterBotResponse instance) =>
    <String, dynamic>{
      'data': instance.grandmasterBotData,
    };

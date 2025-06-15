// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grandmasters_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrandmastersResponse _$GrandmastersResponseFromJson(
        Map<String, dynamic> json) =>
    GrandmastersResponse(
      paginationData:
          PaginationData.fromJson(json['pagination'] as Map<String, dynamic>),
      grandmasters: (json['data'] as List<dynamic>?)
          ?.map((e) => GrandmasterData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GrandmastersResponseToJson(
        GrandmastersResponse instance) =>
    <String, dynamic>{
      'data': instance.grandmasters,
      'pagination': instance.paginationData,
    };

GrandmasterResponse _$GrandmasterResponseFromJson(Map<String, dynamic> json) =>
    GrandmasterResponse(
      grandmaster: json['data'] == null
          ? null
          : GrandmasterData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GrandmasterResponseToJson(
        GrandmasterResponse instance) =>
    <String, dynamic>{
      'data': instance.grandmaster,
    };

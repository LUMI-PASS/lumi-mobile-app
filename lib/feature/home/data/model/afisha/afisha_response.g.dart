// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'afisha_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AfishaResponse _$AfishaResponseFromJson(Map<String, dynamic> json) =>
    AfishaResponse(
      paginationData:
          PaginationData.fromJson(json['pagination'] as Map<String, dynamic>),
      afishas: (json['data'] as List<dynamic>?)
          ?.map((e) => AfishaData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AfishaResponseToJson(AfishaResponse instance) =>
    <String, dynamic>{
      'data': instance.afishas,
      'pagination': instance.paginationData,
    };

AfishaItemResponse _$AfishaItemResponseFromJson(Map<String, dynamic> json) =>
    AfishaItemResponse(
      afishas: json['data'] == null
          ? null
          : AfishaData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AfishaItemResponseToJson(AfishaItemResponse instance) =>
    <String, dynamic>{
      'data': instance.afishas,
    };

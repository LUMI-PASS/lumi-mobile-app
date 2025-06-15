// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsResponse _$NewsResponseFromJson(Map<String, dynamic> json) => NewsResponse(
      paginationData:
          PaginationData.fromJson(json['pagination'] as Map<String, dynamic>),
      news: (json['data'] as List<dynamic>?)
          ?.map((e) => NewsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NewsResponseToJson(NewsResponse instance) =>
    <String, dynamic>{
      'data': instance.news,
      'pagination': instance.paginationData,
    };

NewsItemResponse _$NewsItemResponseFromJson(Map<String, dynamic> json) =>
    NewsItemResponse(
      news: json['data'] == null
          ? null
          : NewsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NewsItemResponseToJson(NewsItemResponse instance) =>
    <String, dynamic>{
      'data': instance.news,
    };

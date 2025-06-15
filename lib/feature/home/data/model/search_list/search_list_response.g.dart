// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchListResponse _$SearchListResponseFromJson(Map<String, dynamic> json) =>
    SearchListResponse(
      searchList: json['data'] == null
          ? null
          : SearchListData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SearchListResponseToJson(SearchListResponse instance) =>
    <String, dynamic>{
      'data': instance.searchList,
    };

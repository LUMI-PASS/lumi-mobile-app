// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_matches_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewMatchesResponse _$ReviewMatchesResponseFromJson(
        Map<String, dynamic> json) =>
    ReviewMatchesResponse(
      paginationData:
          PaginationData.fromJson(json['pagination'] as Map<String, dynamic>),
      reviewMatches: (json['data'] as List<dynamic>?)
          ?.map((e) => ReviewMatchData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReviewMatchesResponseToJson(
        ReviewMatchesResponse instance) =>
    <String, dynamic>{
      'data': instance.reviewMatches,
      'pagination': instance.paginationData,
    };

ReviewMatchResponse _$ReviewMatchResponseFromJson(Map<String, dynamic> json) =>
    ReviewMatchResponse(
      reviewMatches: json['data'] == null
          ? null
          : ReviewMatchData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ReviewMatchResponseToJson(
        ReviewMatchResponse instance) =>
    <String, dynamic>{
      'data': instance.reviewMatches,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_list_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchListData _$SearchListDataFromJson(Map<String, dynamic> json) =>
    SearchListData(
      afisha: (json['afisha'] as List<dynamic>?)
              ?.map((e) => AfishaData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      books: (json['books'] as List<dynamic>?)
              ?.map((e) => BookData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      courses: (json['courses'] as List<dynamic>?)
              ?.map((e) => CourseData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      grandmasters: (json['grandmasters'] as List<dynamic>?)
              ?.map((e) => GrandmasterData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      news: (json['news'] as List<dynamic>?)
              ?.map((e) => NewsData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reviewMatches: (json['reviews'] as List<dynamic>?)
              ?.map((e) => ReviewMatchData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$SearchListDataToJson(SearchListData instance) =>
    <String, dynamic>{
      'afisha': instance.afisha,
      'books': instance.books,
      'courses': instance.courses,
      'grandmasters': instance.grandmasters,
      'news': instance.news,
      'reviews': instance.reviewMatches,
    };

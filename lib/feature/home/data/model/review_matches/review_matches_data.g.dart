// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_matches_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewMatchData _$ReviewMatchDataFromJson(Map<String, dynamic> json) =>
    ReviewMatchData(
      id: json['_id'] as String,
      title: json['title'] as String,
      thumbnailUrl: json['thumbnail'] as String,
      description: json['description'] as String,
      shortDescription: json['short_description'] as String?,
      youtubeLink: json['youtube_link'] as String,
      date: json['date'] as String,
    );

Map<String, dynamic> _$ReviewMatchDataToJson(ReviewMatchData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'thumbnail': instance.thumbnailUrl,
      'description': instance.description,
      'short_description': instance.shortDescription,
      'youtube_link': instance.youtubeLink,
      'date': instance.date,
    };

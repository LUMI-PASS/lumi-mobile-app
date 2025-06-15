// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playlist_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaylistData _$PlaylistDataFromJson(Map<String, dynamic> json) => PlaylistData(
      title: json['title'] as String,
      shortDescription: json['short_description'] as String,
      youtubeLink: json['youtube_link'] as String,
    );

Map<String, dynamic> _$PlaylistDataToJson(PlaylistData instance) =>
    <String, dynamic>{
      'title': instance.title,
      'short_description': instance.shortDescription,
      'youtube_link': instance.youtubeLink,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_stream_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveStreamData _$LiveStreamDataFromJson(Map<String, dynamic> json) =>
    LiveStreamData(
      id: json['_id'] as String,
      title: json['title'] as String,
      videoLink: json['video_link'] as String,
      startsAt: json['starts_at'] as String,
      endsAt: json['ends_at'] as String,
      thumbnail: json['thumbnail'] as String,
    );

Map<String, dynamic> _$LiveStreamDataToJson(LiveStreamData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'video_link': instance.videoLink,
      'starts_at': instance.startsAt,
      'ends_at': instance.endsAt,
      'thumbnail': instance.thumbnail,
    };

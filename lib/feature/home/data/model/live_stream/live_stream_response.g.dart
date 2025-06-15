// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_stream_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LiveStreamResponse _$LiveStreamResponseFromJson(Map<String, dynamic> json) =>
    LiveStreamResponse(
      liveStream: json['data'] == null
          ? null
          : LiveStreamData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LiveStreamResponseToJson(LiveStreamResponse instance) =>
    <String, dynamic>{
      'data': instance.liveStream,
    };

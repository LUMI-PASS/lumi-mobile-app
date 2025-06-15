// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grandmaster_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrandmasterData _$GrandmasterDataFromJson(Map<String, dynamic> json) =>
    GrandmasterData(
      id: json['_id'] as String,
      fullName: json['full_name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      videoUrl: json['video_url'] as String,
    );

Map<String, dynamic> _$GrandmasterDataToJson(GrandmasterData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'full_name': instance.fullName,
      'description': instance.description,
      'image': instance.image,
      'video_url': instance.videoUrl,
    };

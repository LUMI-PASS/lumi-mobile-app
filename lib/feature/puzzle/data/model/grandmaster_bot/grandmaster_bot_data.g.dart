// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grandmaster_bot_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrandmasterBotData _$GrandmasterBotDataFromJson(Map<String, dynamic> json) =>
    GrandmasterBotData(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      bots: (json['bots'] as List<dynamic>?)
          ?.map((e) => BotData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GrandmasterBotDataToJson(GrandmasterBotData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'bots': instance.bots,
    };

BotData _$BotDataFromJson(Map<String, dynamic> json) => BotData(
      id: json['_id'] as String?,
      fullName: json['full_name'] as String?,
      image: json['image'] as String?,
      description: json['description'] as String?,
      botLink: json['bot_link'] as String?,
      rating: json['rating'] as int?,
    );

Map<String, dynamic> _$BotDataToJson(BotData instance) => <String, dynamic>{
      '_id': instance.id,
      'full_name': instance.fullName,
      'image': instance.image,
      'description': instance.description,
      'bot_link': instance.botLink,
      'rating': instance.rating,
    };

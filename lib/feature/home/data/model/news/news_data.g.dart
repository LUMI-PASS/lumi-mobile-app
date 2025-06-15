// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsData _$NewsDataFromJson(Map<String, dynamic> json) => NewsData(
      id: json['_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      shortDescription: json['short_description'] as String,
      imageUrl: json['image'] as String,
      date: json['date'] as String,
    );

Map<String, dynamic> _$NewsDataToJson(NewsData instance) => <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'short_description': instance.shortDescription,
      'image': instance.imageUrl,
      'date': instance.date,
    };

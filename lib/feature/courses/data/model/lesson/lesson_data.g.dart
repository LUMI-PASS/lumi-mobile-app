// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonData _$LessonDataFromJson(Map<String, dynamic> json) => LessonData(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      youtubeLink: json['youtube_link'] as String,
      downloadLink: json['download_link'] as String,
      duration: json['duration'] as int?,
      isOpen: json['is_open'] as bool? ?? true,
      isCompleted: json['is_completed'] as bool? ?? true,
      hasQuiz: json['has_quiz'] as bool? ?? false,
      shortDescription: json['short_description'] as String?,
    );

Map<String, dynamic> _$LessonDataToJson(LessonData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'short_description': instance.shortDescription,
      'youtube_link': instance.youtubeLink,
      'download_link': instance.downloadLink,
      'is_open': instance.isOpen,
      'is_completed': instance.isCompleted,
      'duration': instance.duration,
      'has_quiz': instance.hasQuiz,
    };

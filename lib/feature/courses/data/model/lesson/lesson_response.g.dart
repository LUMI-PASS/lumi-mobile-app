// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonResponse _$LessonResponseFromJson(Map<String, dynamic> json) =>
    LessonResponse(
      lesson: json['data'] == null
          ? null
          : LessonData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LessonResponseToJson(LessonResponse instance) =>
    <String, dynamic>{
      'data': instance.lesson,
    };

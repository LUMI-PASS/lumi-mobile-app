// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseData _$CourseDataFromJson(Map<String, dynamic> json) => CourseData(
      id: json['_id'] as String,
      name: json['name'] as String,
      shortDescription: json['short_description'] as String,
      price: json['price'] as int,
      icon: json['icon'] as String,
      lessonsCount: json['lessons_count'] as int?,
      completedLessonsCount: json['completed_lessons_count'] as int?,
      duration: json['duration'] as int?,
      isEnrolled: json['is_enrolled'] as bool? ?? false,
    );

Map<String, dynamic> _$CourseDataToJson(CourseData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'short_description': instance.shortDescription,
      'price': instance.price,
      'icon': instance.icon,
      'lessons_count': instance.lessonsCount,
      'completed_lessons_count': instance.completedLessonsCount,
      'duration': instance.duration,
      'is_enrolled': instance.isEnrolled,
    };

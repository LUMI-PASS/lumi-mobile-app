// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoursesResponse _$CoursesResponseFromJson(Map<String, dynamic> json) =>
    CoursesResponse(
      courses: (json['data'] as List<dynamic>?)
          ?.map((e) => CourseData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CoursesResponseToJson(CoursesResponse instance) =>
    <String, dynamic>{
      'data': instance.courses,
    };

CourseResponse _$CourseResponseFromJson(Map<String, dynamic> json) =>
    CourseResponse(
      course: json['data'] == null
          ? null
          : CourseData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CourseResponseToJson(CourseResponse instance) =>
    <String, dynamic>{
      'data': instance.course,
    };

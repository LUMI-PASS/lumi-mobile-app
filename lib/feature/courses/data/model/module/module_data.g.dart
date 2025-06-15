// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ModuleData _$ModuleDataFromJson(Map<String, dynamic> json) => ModuleData(
      id: json['_id'] as String,
      name: json['name'] as String,
      lessons: (json['lessons'] as List<dynamic>?)
          ?.map((e) => LessonData.fromJson(e as Map<String, dynamic>))
          .toList(),
      duration: json['duration'] as int?,
    );

Map<String, dynamic> _$ModuleDataToJson(ModuleData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'lessons': instance.lessons,
      'duration': instance.duration,
    };

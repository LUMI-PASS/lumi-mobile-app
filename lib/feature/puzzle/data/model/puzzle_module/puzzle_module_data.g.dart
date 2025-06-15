// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_module_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuzzleModuleData _$PuzzleModuleDataFromJson(Map<String, dynamic> json) =>
    PuzzleModuleData(
      id: json['_id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      puzzles: (json['puzzles'] as List<dynamic>?)
          ?.map((e) => PuzzleData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PuzzleModuleDataToJson(PuzzleModuleData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'puzzles': instance.puzzles,
    };

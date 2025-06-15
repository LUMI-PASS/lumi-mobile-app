// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_module_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuzzleModuleListResponse _$PuzzleModuleListResponseFromJson(
        Map<String, dynamic> json) =>
    PuzzleModuleListResponse(
      puzzleModules: (json['data'] as List<dynamic>?)
          ?.map((e) => PuzzleModuleData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PuzzleModuleListResponseToJson(
        PuzzleModuleListResponse instance) =>
    <String, dynamic>{
      'data': instance.puzzleModules,
    };

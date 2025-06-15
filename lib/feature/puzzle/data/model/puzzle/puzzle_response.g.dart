// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuzzleResponse _$PuzzleResponseFromJson(Map<String, dynamic> json) =>
    PuzzleResponse(
      puzzle: json['data'] == null
          ? null
          : PuzzleData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PuzzleResponseToJson(PuzzleResponse instance) =>
    <String, dynamic>{
      'data': instance.puzzle,
    };

PuzzleQuickResponse _$PuzzleQuickResponseFromJson(Map<String, dynamic> json) =>
    PuzzleQuickResponse(
      puzzles: (json['data'] as List<dynamic>?)
          ?.map((e) => PuzzleQuickData.fromJson(e as Map<String, dynamic>))
          .toList(),
      score: json['score'] as int?,
    );

Map<String, dynamic> _$PuzzleQuickResponseToJson(
        PuzzleQuickResponse instance) =>
    <String, dynamic>{
      'data': instance.puzzles,
      'score': instance.score,
    };

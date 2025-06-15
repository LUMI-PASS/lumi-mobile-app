// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuzzleData _$PuzzleDataFromJson(Map<String, dynamic> json) => PuzzleData(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      boardState: json['board_state'] as String?,
      correctMoves: (json['correct_moves'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      userPoints: json['user_points'] as int?,
    )..index = json['index'] as int?;

Map<String, dynamic> _$PuzzleDataToJson(PuzzleData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'board_state': instance.boardState,
      'correct_moves': instance.correctMoves,
      'user_points': instance.userPoints,
      'index': instance.index,
    };

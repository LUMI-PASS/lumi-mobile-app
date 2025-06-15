// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'puzzle_quick_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuzzleQuickData _$PuzzleQuickDataFromJson(Map<String, dynamic> json) =>
    PuzzleQuickData(
      id: json['_id'] as String,
      title: json['title'] as String,
      boardState: json['board_state'] as String,
      correctMoves: (json['correct_moves'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      puzzleType: json['puzzle_type'] as String,
      index: json['index'] as int?,
    );

Map<String, dynamic> _$PuzzleQuickDataToJson(PuzzleQuickData instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'board_state': instance.boardState,
      'correct_moves': instance.correctMoves,
      'puzzle_type': instance.puzzleType,
      'index': instance.index,
    };

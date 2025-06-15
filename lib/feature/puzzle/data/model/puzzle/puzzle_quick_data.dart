import 'package:json_annotation/json_annotation.dart';

part 'puzzle_quick_data.g.dart';

@JsonSerializable()
class PuzzleQuickData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'title') // We are not using this field!
  final String title;
  @JsonKey(name: 'board_state')
  final String boardState;
  @JsonKey(name: 'correct_moves')
  final List<String> correctMoves;
  @JsonKey(name: 'puzzle_type')
  final String puzzleType;
  @JsonKey(name: 'index')
  int? index;

  PuzzleQuickData({
    required this.id,
    required this.title,
    required this.boardState,
    required this.correctMoves,
    required this.puzzleType,
    required this.index,
  });

  factory PuzzleQuickData.fromJson(Map<String, dynamic> json) =>
      _$PuzzleQuickDataFromJson(json);
  Map<String, dynamic> toJson() => _$PuzzleQuickDataToJson(this);
}

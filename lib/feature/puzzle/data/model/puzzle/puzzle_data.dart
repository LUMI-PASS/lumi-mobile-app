import 'package:json_annotation/json_annotation.dart';

part 'puzzle_data.g.dart';

@JsonSerializable()
class PuzzleData {
  @JsonKey(name: '_id')
  final String? id;
  @JsonKey(name: 'title') // We are not using this field!
  final String? title;
  @JsonKey(name: 'board_state')
  final String? boardState;
  @JsonKey(name: 'correct_moves')
  final List<String>? correctMoves;
  @JsonKey(name: 'user_points')
  int? userPoints;
  @JsonKey(name: 'index')
  int? index;

  PuzzleData({
    this.id,
    this.title,
    this.boardState,
    this.correctMoves,
    this.userPoints,
  });

  set setPoint(int point) {
    userPoints = point;
  }

  factory PuzzleData.fromJson(Map<String, dynamic> json) =>
      _$PuzzleDataFromJson(json);
}

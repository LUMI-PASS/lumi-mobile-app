import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_data.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_quick_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'puzzle_response.g.dart';

@JsonSerializable()
class PuzzleResponse {
  @JsonKey(name: 'data')
  final PuzzleData? puzzle;

  const PuzzleResponse({this.puzzle});

  factory PuzzleResponse.fromJson(Map<String, dynamic> json) =>
      _$PuzzleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PuzzleResponseToJson(this);
}

@JsonSerializable()
class PuzzleQuickResponse {
  @JsonKey(name: 'data')
  final List<PuzzleQuickData>? puzzles;

  @JsonKey(name: 'score')
  final int? score;

  PuzzleQuickResponse({
    this.puzzles,
    this.score,
  });

  factory PuzzleQuickResponse.fromJson(Map<String, dynamic> json) =>
      _$PuzzleQuickResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PuzzleQuickResponseToJson(this);
}

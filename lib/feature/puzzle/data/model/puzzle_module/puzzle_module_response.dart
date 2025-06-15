import 'package:founders_academy/feature/puzzle/data/model/puzzle_module/puzzle_module_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'puzzle_module_response.g.dart';

@JsonSerializable()
class PuzzleModuleListResponse {
  @JsonKey(name: 'data')
  final List<PuzzleModuleData>? puzzleModules;

  const PuzzleModuleListResponse({this.puzzleModules});

  factory PuzzleModuleListResponse.fromJson(Map<String, dynamic> json) =>
      _$PuzzleModuleListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PuzzleModuleListResponseToJson(this);
}

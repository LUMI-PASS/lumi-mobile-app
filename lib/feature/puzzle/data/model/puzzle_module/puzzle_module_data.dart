import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'puzzle_module_data.g.dart';

@JsonSerializable()
class PuzzleModuleData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'icon')
  final String icon;
  @JsonKey(name: 'puzzles')
  final List<PuzzleData>? puzzles;

  PuzzleModuleData({
    required this.id,
    required this.name,
    required this.icon,
    this.puzzles,
  });

  String get level {
    switch (name) {
      case "Oson":
        return "easy";
      case "O'rtacha":
        return "medium";
      case "Qiyin":
        return "hard";
      default:
        return "easy";
    }
  }

  factory PuzzleModuleData.fromJson(Map<String, dynamic> json) =>
      _$PuzzleModuleDataFromJson(json);
}

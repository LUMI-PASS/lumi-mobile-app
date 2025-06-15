import 'package:json_annotation/json_annotation.dart';

part 'puzzle_report_data.g.dart';

@JsonSerializable()
class PuzzleReportData {
  @JsonKey(name: 'body')
  final String? body;
  @JsonKey(name: 'is_wrong_answer')
  final bool? isWrongAnswer;
  @JsonKey(name: 'is_technical_error')
  final bool? isTechnicalError;

  PuzzleReportData({
    this.body,
    this.isWrongAnswer,
    this.isTechnicalError,
  });

  factory PuzzleReportData.fromJson(Map<String, dynamic> json) =>
      _$PuzzleReportDataFromJson(json);

  Map<String, dynamic> toJson() => _$PuzzleReportDataToJson(this);
}

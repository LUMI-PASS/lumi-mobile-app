import 'package:freezed_annotation/freezed_annotation.dart';

part 'puzzle_submission_response.g.dart';

@JsonSerializable()
class PuzzleSubmissionResponse {
  @JsonKey(name: 'earned_mark')
  final int? earnedMark;

  const PuzzleSubmissionResponse({this.earnedMark});

  factory PuzzleSubmissionResponse.fromJson(Map<String, dynamic> json) =>
      _$PuzzleSubmissionResponseFromJson(json["data"] ?? {});

  Map<String, dynamic> toJson() => _$PuzzleSubmissionResponseToJson(this);
}

import 'package:lumi_pass/feature/courses/data/model/lesson/lesson_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'lesson_response.g.dart';

@JsonSerializable()
class LessonResponse {
  @JsonKey(name: 'data')
  final LessonData? lesson;

  const LessonResponse({this.lesson});

  factory LessonResponse.fromJson(Map<String, dynamic> json) =>
      _$LessonResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LessonResponseToJson(this);
}

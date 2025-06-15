import 'package:lumi_pass/feature/courses/data/model/course/course_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'course_response.g.dart';

@JsonSerializable()
class CoursesResponse {
  @JsonKey(name: 'data')
  final List<CourseData>? courses;

  const CoursesResponse({
    this.courses,
  });

  factory CoursesResponse.fromJson(Map<String, dynamic> json) =>
      _$CoursesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CoursesResponseToJson(this);
}

@JsonSerializable()
class CourseResponse {
  @JsonKey(name: 'data')
  final CourseData? course;

  const CourseResponse({
    this.course,
  });

  factory CourseResponse.fromJson(Map<String, dynamic> json) =>
      _$CourseResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CourseResponseToJson(this);
}

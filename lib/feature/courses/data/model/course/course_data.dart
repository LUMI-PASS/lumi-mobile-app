import 'package:json_annotation/json_annotation.dart';

part 'course_data.g.dart';

@JsonSerializable()
class CourseData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'short_description')
  final String shortDescription;
  @JsonKey(name: 'price')
  final int price;
  @JsonKey(name: 'icon')
  final String icon;
  @JsonKey(name: 'lessons_count')
  final int? lessonsCount;
  @JsonKey(name: 'completed_lessons_count')
  final int? completedLessonsCount;
  @JsonKey(name: 'duration')
  final int? duration;
  @JsonKey(name: 'is_enrolled')
  final bool isEnrolled;

  const CourseData({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.price,
    required this.icon,
    required this.lessonsCount,
    required this.completedLessonsCount,
    required this.duration,
    this.isEnrolled = false,
  });

  int get progress {
    final int? completedLessonsCount = this.completedLessonsCount;
    final int? lessonsCount = this.lessonsCount;
    if (completedLessonsCount == null || lessonsCount == null) return 0;
    if (completedLessonsCount == 0 || lessonsCount == 0) return 0;

    return (((completedLessonsCount) / (lessonsCount)) * 100).round();
  }

  factory CourseData.fromJson(Map<String, dynamic> json) =>
      _$CourseDataFromJson(json);

  Map<String, dynamic> toJson() => _$CourseDataToJson(this);
}

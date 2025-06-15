import 'package:founders_academy/feature/courses/data/model/lesson/lesson_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'module_data.g.dart';

@JsonSerializable()
class ModuleData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'lessons')
  final List<LessonData>? lessons;
  @JsonKey(name: 'duration')
  final int? duration;

  const ModuleData({
    required this.id,
    required this.name,
    required this.lessons,
    required this.duration,
  });

  factory ModuleData.fromJson(Map<String, dynamic> json) =>
      _$ModuleDataFromJson(json);

  bool get isExpanded {
    final lessons = this.lessons;

    if (lessons != null) {
      bool hasIncompleteLesson = lessons.any((lesson) => !lesson.isCompleted);
      bool hasCompleteLesson = lessons.any((lesson) => lesson.isCompleted);

      return hasIncompleteLesson && hasCompleteLesson;
    }

    return false;
  }

  String? nextLessonId(String currentId) {
    if (this.lessons == null) return null;
    final lessons = this.lessons ?? [];

    int currentIndex = lessons.indexWhere((lesson) => lesson.id == currentId);

    return currentIndex + 1 < lessons.length
        ? lessons[currentIndex + 1].id
        : null;
  }

  Map<String, dynamic> toJson() => _$ModuleDataToJson(this);
}

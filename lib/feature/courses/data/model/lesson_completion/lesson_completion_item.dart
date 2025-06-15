import 'package:isar/isar.dart';

part 'lesson_completion_item.g.dart';

@collection
class LessonCompletionItem {
  Id id;
  String userId;
  @Index(unique: true)
  String lessonId;

  LessonCompletionItem({
    this.id = Isar.autoIncrement,
    this.userId = "",
    this.lessonId = "",
  });
}

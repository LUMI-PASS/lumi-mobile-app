import 'package:founders_academy/core/database/isar_provider.dart';
import 'package:founders_academy/feature/courses/data/model/lesson_completion/lesson_completion_item.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

@Injectable()
class LessonCompletionDatabase {
  final IsarProvider _isarProvider;

  LessonCompletionDatabase(this._isarProvider);

  Future<LessonCompletionItem?> write({
    required String lessonId,
    required String userId,
  }) async {
    final isar = await _isarProvider.isar;
    final lessonModel = LessonCompletionItem()
      ..lessonId = lessonId
      ..userId = userId;

    final existingItem = await isar.lessonCompletionItems
        .filter()
        .lessonIdEqualTo(lessonId)
        .findFirst();

    if (existingItem != null) {
      await isar.writeTxn(() async {
        await isar.lessonCompletionItems.delete(existingItem.id);
      });
    }

    await isar.writeTxn(() async {
      await isar.lessonCompletionItems.put(lessonModel);
    });

    return lessonModel;
  }

  Future<LessonCompletionItem?> read({
    required String lessonId,
    required String userId,
  }) async {
    final isar = await _isarProvider.isar;
    final result = await isar.lessonCompletionItems
        .filter()
        .lessonIdEqualTo(lessonId)
        .userIdEqualTo(userId)
        .findFirst();

    return result;
  }

  Future<void> clear() async {
    final isar = await _isarProvider.isar;

    await isar.writeTxn(() async {
      await isar.lessonCompletionItems.clear();
    });
  }
}

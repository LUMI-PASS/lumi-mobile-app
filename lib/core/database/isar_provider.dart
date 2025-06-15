import 'package:lumi_pass/feature/courses/data/model/lesson_completion/lesson_completion_item.dart';
import 'package:lumi_pass/feature/home/data/model/search_item/search_item.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

@LazySingleton()
class IsarProvider {
  Isar? _isar;

  Future<Isar> get isar async {
    var isar = _isar;
    if (isar != null) return isar;

    final dir = await getApplicationCacheDirectory();
    isar = await Isar.open([
      SearchItemSchema,
      LessonCompletionItemSchema

      /// Add new Schema here
    ], directory: dir.path);
    _isar = isar;
    return isar;
  }
}

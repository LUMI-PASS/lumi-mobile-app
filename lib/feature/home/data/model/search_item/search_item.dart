import 'package:isar/isar.dart';

part 'search_item.g.dart';

@collection
class SearchItem {
  Id id;
  String title;

  SearchItem({
    this.id = Isar.autoIncrement,
    this.title = "",
  });
}

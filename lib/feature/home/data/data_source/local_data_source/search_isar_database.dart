import 'package:lumi_pass/core/database/isar_provider.dart';
import 'package:lumi_pass/feature/home/data/model/search_item/search_item.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

@Injectable()
class SearchIsarDatabase {
  final IsarProvider _isarProvider;

  SearchIsarDatabase(this._isarProvider);

  Future<SearchItem> addSearchHistory(String query) async {
    final isar = await _isarProvider.isar;
    final searchHistory = SearchItem()..title = query;

    final existingItem =
        await isar.searchItems.filter().titleEqualTo(query).findFirst();

    if (existingItem != null) {
      await isar.writeTxn(() async {
        await isar.searchItems.delete(existingItem.id);
      });
    }

    await isar.writeTxn(() async {
      await isar.searchItems.put(searchHistory);
    });

    return searchHistory;
  }

  Stream<List<SearchItem>> getSearchHistory() async* {
    final isar = await _isarProvider.isar;

    yield* isar.searchItems
        .filter()
        .titleIsNotEmpty()
        .watch(fireImmediately: true);
  }

  Future<void> delete(int id) async {
    final isar = await _isarProvider.isar;

    await isar.writeTxn(() async {
      await isar.searchItems.delete(id);
    });
  }
}

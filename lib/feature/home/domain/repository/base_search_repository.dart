import 'package:founders_academy/feature/home/data/model/search_item/search_item.dart';
import 'package:founders_academy/feature/home/data/model/search_list/search_list_data.dart';

abstract interface class BaseSearchRepository {
  Stream<List<SearchItem>> getSearchHistory();

  Future<SearchListData> search({required String query});

  Future<void> deleteItemHistory({required int id});

  Future<SearchItem> addHistory({required String query});
}

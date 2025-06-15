import 'dart:async';

import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/feature/home/data/data_source/local_data_source/search_isar_database.dart';
import 'package:founders_academy/feature/home/data/data_source/remote_data_source/search_api_client.dart';
import 'package:founders_academy/feature/home/data/model/search_item/search_item.dart';
import 'package:founders_academy/feature/home/data/model/search_list/search_list_data.dart';
import 'package:founders_academy/feature/home/domain/repository/base_search_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

@Injectable(as: BaseSearchRepository)
class SearchRepository implements BaseSearchRepository {
  final SearchIsarDatabase _isarDatabase;
  final SearchApiClient _searchApiClient;

  SearchRepository(this._isarDatabase, this._searchApiClient);

  @override
  Stream<List<SearchItem>> getSearchHistory() async* {
    try {
      final history = _isarDatabase.getSearchHistory();
      yield* history;
    } on IsarError catch (exception) {
      throw ChessException.fromIsarException(exception);
    }
  }

  @override
  Future<SearchItem> addHistory({required String query}) async {
    try {
      final addedHistory = await _isarDatabase.addSearchHistory(query);

      return addedHistory;
    } on IsarError catch (exception) {
      throw ChessException.fromIsarException(exception);
    }
  }

  @override
  Future<SearchListData> search({required String query}) async {
    try {
      final searchData = await _searchApiClient.search(query);

      return searchData.result.searchList ?? const SearchListData();
    } on DioException catch (exception) {
      throw ChessException.fromDioException(exception);
    }
  }

  @override
  Future<void> deleteItemHistory({required int id}) async {
    try {
      await _isarDatabase.delete(id);
    } on IsarError catch (exception) {
      throw ChessException.fromIsarException(exception);
    }
  }
}

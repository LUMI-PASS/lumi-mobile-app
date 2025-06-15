import 'dart:async';

import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/home/data/model/search_item/search_item.dart';
import 'package:founders_academy/feature/home/data/model/search_list/search_list_data.dart';
import 'package:founders_academy/feature/home/domain/repository/base_search_repository.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'search_state.dart';

@Injectable()
class SearchCubit extends ChessCubit<SearchState> {
  final BaseSearchRepository _searchRepository;
  final SafeExecutionManager _safeExecutionManager;

  SearchCubit(
    this._searchRepository,
    this._safeExecutionManager,
  ) : super(const SearchInitialState());

  StreamSubscription? _searchHistorySubscription;

  void initSearchIsarDatabase() async {
    _getSearchHistory();
  }

  /// Remote request
  Future<void> search(String query) async {
    final currentState = state;
    if (currentState is! SearchLoadedState) return;

    safeEmit(const SearchLoadingState());

    try {
      final result = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _searchRepository.search(query: query),
      );

      safeEmit(SearchLoadedState(
        searchList: result,
        searchHistory: currentState.searchHistory,
      ));
    } on ChessException catch (exception) {
      safeEmit(SearchErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  /// Local request
  Future<void> delete(int id) async {
    try {
      await _searchRepository.deleteItemHistory(id: id);
    } on ChessException catch (exception) {
      safeEmit(SearchErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> addHistory(String query) async {
    final currentState = state;
    if (currentState is! SearchLoadedState) return;

    try {
      await _searchRepository.addHistory(query: query);
    } on ChessException catch (exception) {
      safeEmit(SearchErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getSearchHistory() async {
    try {
      final result = _searchRepository.getSearchHistory();

      _searchHistorySubscription = result.listen((history) {
        SearchListData? listData;
        if (state is SearchLoadedState) {
          final currentState = state as SearchLoadedState;
          listData = currentState.searchList;
        }

        safeEmit(
          SearchLoadedState(
            searchHistory: history,
            searchList: listData ?? const SearchListData(),
          ),
        );
      });
    } on ChessException catch (exception) {
      safeEmit(SearchErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  @override
  Future<void> close() {
    _searchHistorySubscription?.cancel();
    return super.close();
  }
}

part of 'search_cubit.dart';

sealed class SearchState {
  const SearchState();
}

class SearchInitialState extends SearchState {
  const SearchInitialState();
}

class SearchLoadingState extends SearchState {
  const SearchLoadingState();
}

class SearchLoadedState extends SearchState {
  final SearchListData searchList;
  final List<SearchItem> searchHistory;

  const SearchLoadedState({
    required this.searchList,
    required this.searchHistory,
  });
}

class SearchErrorState extends SearchState {
  final ChessException exception;

  const SearchErrorState(this.exception);
}

part of 'news_cubit.dart';

sealed class NewsState {
  const NewsState();
}

class NewsLoadingState extends NewsState {
  const NewsLoadingState();
}

class NewsLoadedState extends NewsState {
  final List<NewsData> newsList;
  final int page;
  final bool isNextPageLoading;
  final bool isNextPageAvailable;

  NewsLoadedState({
    required this.newsList,
    required this.page,
    this.isNextPageLoading = false,
    this.isNextPageAvailable = true,
  });

  NewsLoadedState copyWith({
    List<NewsData>? newsList,
    int? page,
    bool? isNextPageLoading,
    bool? isNextPageAvailable,
  }) {
    return NewsLoadedState(
      newsList: newsList ?? this.newsList,
      page: page ?? this.page,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      isNextPageAvailable: isNextPageAvailable ?? this.isNextPageAvailable,
    );
  }
}

class NewsErrorState extends NewsState {
  const NewsErrorState();
}

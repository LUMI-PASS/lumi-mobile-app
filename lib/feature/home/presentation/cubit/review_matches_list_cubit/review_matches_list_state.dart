part of 'review_matches_list_cubit.dart';

sealed class ReviewMatchesListState {
  const ReviewMatchesListState();
}

class ReviewMatchesListLoadingState extends ReviewMatchesListState {
  const ReviewMatchesListLoadingState();
}

class ReviewMatchesListLoadedState extends ReviewMatchesListState {
  final List<ReviewMatchData> reviewMatchesList;
  final int page;
  final bool isNextPageLoading;
  final bool isNextPageAvailable;

  const ReviewMatchesListLoadedState({
    required this.reviewMatchesList,
    required this.page,
    this.isNextPageLoading = false,
    this.isNextPageAvailable = true,
  });

  ReviewMatchesListLoadedState copyWith({
    List<ReviewMatchData>? reviewMatchList,
    int? page,
    bool? isNextPageLoading,
    bool? isNextPageAvailable,
  }) {
    return ReviewMatchesListLoadedState(
      reviewMatchesList: reviewMatchList ?? reviewMatchesList,
      page: page ?? this.page,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      isNextPageAvailable: isNextPageAvailable ?? this.isNextPageAvailable,
    );
  }
}

class ReviewMatchesListErrorState extends ReviewMatchesListState {
  const ReviewMatchesListErrorState();
}

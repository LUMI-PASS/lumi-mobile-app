part of 'review_match_cubit.dart';

sealed class ReviewMatchState {
  const ReviewMatchState();
}

class ReviewMatchLoadingState extends ReviewMatchState {
  const ReviewMatchLoadingState();
}

class ReviewMatchLoadedState extends ReviewMatchState {
  final ReviewMatchData reviewMatch;
  const ReviewMatchLoadedState(this.reviewMatch);
}

class ReviewMatchErrorState extends ReviewMatchState {
  const ReviewMatchErrorState();
}

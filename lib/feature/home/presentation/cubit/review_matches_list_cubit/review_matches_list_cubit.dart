import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:lumi_pass/feature/home/domain/repository/base_home_repository.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'review_matches_list_state.dart';

@Injectable()
class ReviewMatchesListCubit extends ChessCubit<ReviewMatchesListState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  ReviewMatchesListCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const ReviewMatchesListLoadingState());

  void init() {
    _getReviewMatchesList(1);
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! ReviewMatchesListLoadedState ||
        currentState.isNextPageLoading) {
      return;
    }
    try {
      safeEmit(currentState.copyWith(isNextPageLoading: true));
      if (currentState.isNextPageAvailable) {
        await _getReviewMatchesList(
          currentState.page + 1,
          list: currentState.reviewMatchesList,
        );
      } else {
        safeEmit(currentState.copyWith(isNextPageLoading: false));
      }
    } on Exception catch (exception) {
      safeEmit(currentState.copyWith(isNextPageLoading: false));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getReviewMatchesList(
    int page, {
    List<ReviewMatchData>? list,
  }) async {
    try {
      final reviewMatchesResponse =
          await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getReviewMatches(page: page),
      );
      List<ReviewMatchData> reviewMatchesList = [
        if (list != null && list.isNotEmpty) ...list,
        ...reviewMatchesResponse.reviewMatches ?? [],
      ];

      final pagination = reviewMatchesResponse.paginationData;

      safeEmit(
        ReviewMatchesListLoadedState(
          reviewMatchesList: reviewMatchesList,
          page: page,
          isNextPageAvailable: pagination.nextPage != null,
        ),
      );
    } on ChessException catch (exception) {
      safeEmit(const ReviewMatchesListErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

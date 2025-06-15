import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'review_match_state.dart';

@Injectable()
class ReviewMatchCubit extends ChessCubit<ReviewMatchState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  ReviewMatchCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const ReviewMatchLoadingState());

  void init(String id) {
    _getReviewMatchById(id);
  }

  Future<void> _getReviewMatchById(String id) async {
    try {
      final reviewMatch = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getReviewMatchById(id: id),
      );
      safeEmit(ReviewMatchLoadedState(reviewMatch!));
    } on ChessException catch (exception) {
      safeEmit(const ReviewMatchErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

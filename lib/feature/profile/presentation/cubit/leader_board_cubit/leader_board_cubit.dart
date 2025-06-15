import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/profile/domain/repository/base_profile_repository.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/leader_board_cubit/leader_board_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class LeaderBoardCubit extends ChessCubit<LeaderboardState> {
  final BaseProfileRepository _profileRepository;
  final SafeExecutionManager _safeExecutionManager;

  LeaderBoardCubit(
    this._profileRepository,
    this._safeExecutionManager,
  ) : super(const LeaderboardInitState());

  void init([String period = 'weekly']) {
    getLeaderboard(period);
  }

  Future<void> getLeaderboard(String period) async {
    try {
      final response = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _profileRepository.getLeaderboardData(period: period),
      );

      final leaderboardData = response.leaderboard;
      final currentUser = response.user;

      safeEmit(LeaderboardLoadedState(leaderboardData ?? [], currentUser));
    } on ChessException catch (exception) {
      safeEmit(const LeaderboardErrorState());
      throw UnknownChessException(exception.toString());
    }
  }

  void changePeriod(String period) {
    safeEmit(const LeaderboardInitState());
    getLeaderboard(period);
  }
}

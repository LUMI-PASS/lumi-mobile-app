import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/puzzle/domain/repository/base_puzzle_repository.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_quick/puzzle_quick_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class PuzzleQuickCubit extends ChessCubit<PuzzleQuickState> {
  final BasePuzzleRepository _puzzleRepository;
  final SafeExecutionManager _safeExecutionManager;

  PuzzleQuickCubit(
    this._puzzleRepository,
    this._safeExecutionManager,
  ) : super(const PuzzleQuickInitState());

  void init(List<String> types, int limit) {
    _getPuzzleQuick(types, limit);
  }

  Future<void> _getPuzzleQuick(List<String> types, int limit) async {
    try {
      final response = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _puzzleRepository.getPuzzleQuick(types, limit),
      );

      final puzzles = response?.puzzles ?? [];

      safeEmit(PuzzleQuickLoadedState(puzzles));
    } on ChessException catch (exception) {
      safeEmit(const PuzzleQuickErrorState());
      throw UnknownChessException(exception.toString());
    }
  }

  Future<int> submitSolvedPuzzles(List<String> solvedPuzzleIds) async {
    try {
      final score = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _puzzleRepository.submitSolvedPuzzles(solvedPuzzleIds),
      );
      return score;
    } on ChessException catch (exception) {
      safeEmit(const PuzzleQuickErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

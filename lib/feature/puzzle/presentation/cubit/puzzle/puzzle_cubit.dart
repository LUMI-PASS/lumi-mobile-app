import 'dart:async';

import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/feature/puzzle/domain/repository/base_puzzle_repository.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle/puzzle_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class PuzzleCubit extends ChessCubit<PuzzleState> {
  final BasePuzzleRepository _puzzleRepository;
  PuzzleCubit(this._puzzleRepository) : super(const PuzzleState.initial());

  Timer? _timer;

  void init(String moduleId) {
    fetchPuzzle(moduleId);
  }

  Future<void> fetchPuzzle(String level) async {
    safeEmit(const PuzzleState.loading());
    _resetTimer();
    try {
      final puzzleModel = await _puzzleRepository.getPuzzle(level: level);

      if (puzzleModel != null) {
        await _startTimer();
        safeEmit(PuzzleState.loaded(puzzle: puzzleModel));
      } else {
        safeEmit(const PuzzleState.empty());
      }
    } on ChessException catch (exception) {
      safeEmit(PuzzleState.failed(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  @override
  Future<void> close() {
    _resetTimer();
    return super.close();
  }

  Future<void> _startTimer() async {
    if (isClosed) return;

    try {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final currentState = state;
        if (currentState is PuzzleLoadedState) {
          safeEmit(
            currentState.copyWith(
              elapsedTime: currentState.elapsedTime + 1,
            ),
          );
        }
      });
    } on ChessException catch (exception) {
      safeEmit(PuzzleState.failed(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> setMove(bool isCorrectMove) async {
    try {
      final currentState = state;
      if (currentState is! PuzzleLoadedState) return;
      final puzzleId = currentState.puzzle.id;

      safeEmit(currentState.copyWith(isCorrect: isCorrectMove));

      if (puzzleId != null && isCorrectMove) {
        safeEmit(currentState.copyWith(submittingMove: true));
        _resetTimer();

        final earnedPoint = await _puzzleRepository.setMove(
          puzzleId,
          isHintUsed: currentState.isHintShowed,
          isRetried: currentState.isRetried,
          triedCount: currentState.retriesCount,
          time: currentState.elapsedTime,
        );

        if (earnedPoint != null) {
          int userPoints = currentState.puzzle.userPoints ?? 0;
          userPoints = userPoints + earnedPoint;
          currentState.puzzle.setPoint = userPoints;

          safeEmit(currentState.copyWith(puzzle: currentState.puzzle));
        }
        safeEmit(currentState.copyWith(
          submittingMove: false,
          isCorrect: isCorrectMove,
        ));
      }
    } on ChessException catch (exception) {
      safeEmit(PuzzleState.failed(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  void showHint() {
    try {
      final currentState = state;
      if (currentState is! PuzzleLoadedState) return;
      safeEmit(currentState.copyWith(isHintShowed: true));
    } on ChessException catch (exception) {
      safeEmit(PuzzleState.failed(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  void resetBoard() {
    try {
      final currentState = state;

      if (currentState is! PuzzleLoadedState) return;

      safeEmit(currentState.copyWith(
        puzzle: currentState.puzzle,
        isRetried: true,
        retriesCount: currentState.retriesCount + 1,
        isCorrect: null,
      ));
    } on ChessException catch (exception) {
      safeEmit(PuzzleState.failed(exception));
      throw UnknownChessException(exception.toString());
    }
  }
}

import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_data.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'puzzle_state.freezed.dart';

/// [StatusTextType] type is to show the status of the Puzzle.
/// If you haven't started the puzzle yet. In middle of the screen
/// Explanation text will be visible. After selecting the moves, you can check
/// status of the result with type that is correct or wrong moves.
enum StatusTextType { explanation, correct, wrong }

@freezed
class PuzzleState with _$PuzzleState {
  const factory PuzzleState.initial() = PuzzleInitialState;

  const factory PuzzleState.loading() = PuzzleLoadingState;

  const factory PuzzleState.loaded({
    required PuzzleData puzzle,
    @Default(false) bool isHintShowed,
    @Default(false) bool isRetried,
    @Default(false) bool submittingMove,
    @Default(0) int retriesCount,
    @Default(0) int elapsedTime,
    bool? isCorrect,
  }) = PuzzleLoadedState;

  const factory PuzzleState.empty() = PuzzleEmptyState;

  const factory PuzzleState.failed(ChessException exception) =
      PuzzleFailedState;
}

extension PuzzleStateExtension on PuzzleState {
  StatusTextType get statusTextType {
    final state = this;

    if (state is PuzzleLoadedState) {
      final isCorrect = state.isCorrect;

      if (isCorrect != null) {
        return isCorrect ? StatusTextType.correct : StatusTextType.wrong;
      }
    }

    return StatusTextType.explanation;
  }

  bool get isCorrectAnswer {
    if (this is PuzzleLoadedState) {
      final isCorrect = (this as PuzzleLoadedState).isCorrect;
      return isCorrect != null && isCorrect;
    }

    return false;
  }

  bool get isWrongAnswer {
    if (this is PuzzleLoadedState) {
      final isCorrect = (this as PuzzleLoadedState).isCorrect;
      return isCorrect != null && !isCorrect;
    }

    return false;
  }
}

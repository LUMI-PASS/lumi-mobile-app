part of 'puzzle_module_cubit.dart';

@freezed
class PuzzleModuleState with _$PuzzleModuleState {
  const factory PuzzleModuleState.initial() = PuzzleModuleInitialState;

  const factory PuzzleModuleState.loading() = PuzzleModuleLoadingState;

  const factory PuzzleModuleState.loaded({
    required List<PuzzleModuleData> puzzleModules,
  }) = PuzzleModuleLoadedState;

  const factory PuzzleModuleState.failed(
    final ChessException exception,
  ) = PuzzleModuleFailedState;
}

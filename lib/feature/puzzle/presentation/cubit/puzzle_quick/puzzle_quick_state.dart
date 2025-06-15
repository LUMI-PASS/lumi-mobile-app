import 'package:founders_academy/feature/puzzle/data/model/puzzle/puzzle_quick_data.dart';

sealed class PuzzleQuickState {
  const PuzzleQuickState();
}

class PuzzleQuickInitState extends PuzzleQuickState {
  const PuzzleQuickInitState();
}

class PuzzleQuickLoadedState extends PuzzleQuickState {
  final List<PuzzleQuickData> puzzles;

  PuzzleQuickLoadedState(this.puzzles);
}

class PuzzleQuickErrorState extends PuzzleQuickState {
  const PuzzleQuickErrorState();
}

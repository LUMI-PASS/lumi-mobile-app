sealed class PuzzleReportState {
  const PuzzleReportState();
}

class PuzzleReportInitState extends PuzzleReportState {
  const PuzzleReportInitState();
}

class PuzzleReportLoadingState extends PuzzleReportState {
  const PuzzleReportLoadingState();
}

class PuzzleReportLoadedState extends PuzzleReportState {
  PuzzleReportLoadedState();
}

class PuzzleReportErrorState extends PuzzleReportState {
  const PuzzleReportErrorState();
}

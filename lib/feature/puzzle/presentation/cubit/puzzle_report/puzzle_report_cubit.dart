import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/puzzle/data/model/puzzle_report/puzzle_report_data.dart';
import 'package:founders_academy/feature/puzzle/domain/repository/base_puzzle_repository.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/puzzle_report/puzzle_report_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class PuzzleReportCubit extends ChessCubit<PuzzleReportState> {
  final BasePuzzleRepository _puzzleRepository;
  final SafeExecutionManager _safeExecutionManager;

  PuzzleReportCubit(
    this._puzzleRepository,
    this._safeExecutionManager,
  ) : super(const PuzzleReportInitState());

  Future<void> puzzleReport(
      {required String id, required PuzzleReportData puzzleReport}) async {
    try {
      safeEmit(const PuzzleReportLoadingState());
      final PuzzleReportData? reportData =
          await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _puzzleRepository.puzzleReport(
          id: id,
          reportPuzzle: puzzleReport,
        ),
      );

      if (reportData != null) {
        safeEmit(PuzzleReportLoadedState());
      } else {
        safeEmit(const PuzzleReportErrorState());
      }
    } on ChessException catch (exception) {
      safeEmit(const PuzzleReportErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

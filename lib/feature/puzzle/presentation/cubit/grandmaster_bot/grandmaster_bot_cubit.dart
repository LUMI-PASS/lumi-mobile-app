import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/puzzle/domain/repository/base_puzzle_repository.dart';
import 'package:founders_academy/feature/puzzle/presentation/cubit/grandmaster_bot/grandMaster_bot_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class GrandMasterBotCubit extends ChessCubit<GrandMasterBotState> {
  final BasePuzzleRepository _puzzleRepository;
  final SafeExecutionManager _safeExecutionManager;

  GrandMasterBotCubit(
    this._puzzleRepository,
    this._safeExecutionManager,
  ) : super(GrandMasterBotInitial());

  void init() {
    _getGranMasterBotList();
  }

  Future<void> _getGranMasterBotList() async {
    try {
      final response = await _safeExecutionManager.makeAsyncSafeExecution(
        function: _puzzleRepository.getGrandMasterBotList,
      );

      final grandMasterBotData = response.grandmasterBotData;

      safeEmit(GrandMasterBotLoadedState(
        grandMasterBotData ?? [],
      ));
    } on ChessException catch (exception) {
      safeEmit(GrandMasterBotErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

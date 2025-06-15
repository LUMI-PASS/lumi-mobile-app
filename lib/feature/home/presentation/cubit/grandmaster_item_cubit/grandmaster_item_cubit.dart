import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/home/domain/repository/base_home_repository.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/grandmaster_item_cubit/grandmaster_item_state.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class GrandmasterItemCubit extends ChessCubit<GrandmasterItemState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  GrandmasterItemCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const GrandmasterItemLoadingState());

  void init(String id) {
    _getGrandmasterById(id);
  }

  Future<void> _getGrandmasterById(String id) async {
    try {
      final grandmasterById =
          await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getGrandmasterById(id: id),
      );
      if (grandmasterById != null) {
        safeEmit(GrandmasterItemLoadedState(grandmasterById));
      } else {
        safeEmit(const GrandmasterItemErrorState());
      }
    } on ChessException catch (exception) {
      safeEmit(const GrandmasterItemErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

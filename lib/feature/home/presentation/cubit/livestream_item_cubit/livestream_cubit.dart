import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/home/domain/repository/base_home_repository.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/livestream_item_cubit/livestream_state.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class LiveStreamItemCubit extends ChessCubit<LiveStreamItemState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  LiveStreamItemCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const LiveStreamItemInitState());

  Future<void> init(String id) async {
    await _getLiveStreamById(id);
  }

  Future<void> _getLiveStreamById(String id) async {
    safeEmit(const LiveStreamItemLoadingState());
    try {
      final liveStreamById = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getLiveStreamById(id: id),
      );
      if (liveStreamById != null) {
        safeEmit(LiveStreamItemLoadedState(liveStreamById));
      } else {
        safeEmit(const LiveStreamItemErrorState());
      }
    } on ChessException catch (exception) {
      safeEmit(const LiveStreamItemErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

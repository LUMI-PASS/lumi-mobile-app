import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart';
import 'package:founders_academy/feature/home/presentation/cubit/afisha_item_cubit/afisha_item_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class AfishaItemCubit extends ChessCubit<AfishaItemState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  AfishaItemCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const AfishaItemLoadingState());

  void init(String id) {
    _getAfishaById(id);
  }

  Future<void> _getAfishaById(String id) async {
    try {
      final afishaById = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getAfishaById(id: id),
      );
      safeEmit(AfishaItemLoadedState(afishaById!));
    } on ChessException catch (exception) {
      safeEmit(const AfishaItemErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

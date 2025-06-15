import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:lumi_pass/feature/home/domain/repository/base_home_repository.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'grandmaster_state.dart';

@Injectable()
class GrandmasterCubit extends ChessCubit<GrandmasterState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  GrandmasterCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const GrandmasterLoadingState());

  void init() {
    _getGrandmasterList(1);
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! GrandmasterLoadedState ||
        currentState.isNextPageLoading) {
      return;
    }
    try {
      safeEmit(currentState.copyWith(isNextPageLoading: true));
      if (currentState.isNextPageAvailable) {
        await _getGrandmasterList(
          currentState.page + 1,
          list: currentState.grandmasterList,
        );
      } else {
        safeEmit(currentState.copyWith(isNextPageLoading: false));
      }
    } on Exception catch (exception) {
      safeEmit(currentState.copyWith(isNextPageLoading: false));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getGrandmasterList(
    int page, {
    List<GrandmasterData>? list,
  }) async {
    try {
      final grandmastersResponse =
          await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getGrandmasters(page: page),
      );

      List<GrandmasterData> grandmasterList = [
        if (list != null && list.isNotEmpty) ...list,
        ...grandmastersResponse.grandmasters ?? [],
      ];

      final pagination = grandmastersResponse.paginationData;

      safeEmit(
        GrandmasterLoadedState(
          grandmasterList: grandmasterList,
          page: page,
          isNextPageAvailable: pagination.nextPage != null,
        ),
      );
    } on ChessException catch (exception) {
      safeEmit(const GrandmasterErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

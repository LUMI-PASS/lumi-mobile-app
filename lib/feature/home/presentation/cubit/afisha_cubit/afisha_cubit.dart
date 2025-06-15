import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/home/data/model/afisha/afisha_data.dart';
import 'package:lumi_pass/feature/home/domain/repository/base_home_repository.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/afisha_cubit/afisha_state.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class AfishaCubit extends ChessCubit<AfishaState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  AfishaCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const AfishaListLoadingState());

  void init() {
    _getAfishaList(1);
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! AfishaListLoadedState ||
        currentState.isNextPageLoading) {
      return;
    }
    try {
      safeEmit(currentState.copyWith(isNextPageLoading: true));
      if (currentState.isNextPageAvailable) {
        await _getAfishaList(
          currentState.page + 1,
          list: currentState.afishaList,
        );
      } else {
        safeEmit(currentState.copyWith(isNextPageLoading: false));
      }
    } on Exception catch (exception) {
      safeEmit(currentState.copyWith(isNextPageLoading: false));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getAfishaList(
    int page, {
    List<AfishaData>? list,
  }) async {
    try {
      final afishasResponse =
          await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getAfishas(page: page),
      );
      List<AfishaData> afishaList = [
        if (list != null && list.isNotEmpty) ...list,
        ...afishasResponse.afishas ?? [],
      ];

      final pagination = afishasResponse.paginationData;

      safeEmit(
        AfishaListLoadedState(
          afishaList: afishaList,
          page: page,
          isNextPageAvailable: pagination.nextPage != null,
        ),
      );
    } on ChessException catch (exception) {
      safeEmit(const AfishaListErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

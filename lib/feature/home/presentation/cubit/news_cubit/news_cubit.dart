import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/home/data/model/news/news_data.dart';
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'news_state.dart';

@Injectable()
class NewsCubit extends ChessCubit<NewsState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  NewsCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const NewsLoadingState());

  void init() {
    _getNewsList(1);
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! NewsLoadedState || currentState.isNextPageLoading) {
      return;
    }
    try {
      safeEmit(currentState.copyWith(isNextPageLoading: true));
      if (currentState.isNextPageAvailable) {
        await _getNewsList(
          currentState.page + 1,
          list: currentState.newsList,
        );
      } else {
        safeEmit(currentState.copyWith(isNextPageLoading: false));
      }
    } on Exception catch (exception) {
      safeEmit(currentState.copyWith(isNextPageLoading: false));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getNewsList(
    int page, {
    List<NewsData>? list,
  }) async {
    try {
      final newsResponse = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getNews(page: page),
      );
      List<NewsData> newsList = [
        if (list != null && list.isNotEmpty) ...list,
        ...newsResponse.news ?? [],
      ];

      final pagination = newsResponse.paginationData;

      safeEmit(
        NewsLoadedState(
          newsList: newsList,
          page: page,
          isNextPageAvailable: pagination.nextPage != null,
        ),
      );
    } on ChessException catch (exception) {
      safeEmit(const NewsErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

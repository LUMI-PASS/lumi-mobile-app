import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart';
import 'package:founders_academy/feature/home/presentation/cubit/news_item_cubit/news_item_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class NewsItemCubit extends ChessCubit<NewsItemState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  NewsItemCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const NewsItemLoadingState());

  void init(String id) {
    _getNewsById(id);
  }

  Future<void> _getNewsById(String id) async {
    try {
      final newsById = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getNewsById(id: id),
      );
      safeEmit(NewsItemLoadedState(newsById!));
    } on ChessException catch (exception) {
      safeEmit(const NewsItemErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

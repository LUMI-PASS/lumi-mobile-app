import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/home/data/model/book/book_data.dart';
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'book_list_state.dart';

@Injectable()
class BookListCubit extends ChessCubit<BookListState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  BookListCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const BookListLoadingState());

  void init() {
    _getBookList(1);
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! BookListLoadedState ||
        currentState.isNextPageLoading) {
      return;
    }
    try {
      safeEmit(currentState.copyWith(isNextPageLoading: true));
      if (currentState.isNextPageAvailable) {
        await _getBookList(
          currentState.page + 1,
          list: currentState.bookList,
        );
      } else {
        safeEmit(currentState.copyWith(isNextPageLoading: false));
      }
    } on Exception catch (exception) {
      safeEmit(currentState.copyWith(isNextPageLoading: false));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getBookList(
    int page, {
    List<BookData>? list,
  }) async {
    try {
      final booksResponse = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getBooks(page: page),
      );

      List<BookData> bookList = [
        if (list != null && list.isNotEmpty) ...list,
        ...booksResponse.books ?? [],
      ];

      final pagination = booksResponse.paginationData;

      safeEmit(
        BookListLoadedState(
          bookList: bookList,
          page: page,
          isNextPageAvailable: pagination.nextPage != null,
        ),
      );
    } on ChessException catch (exception) {
      safeEmit(const BookListErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

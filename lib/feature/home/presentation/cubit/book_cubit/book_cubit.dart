import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/home/data/model/book/book_data.dart';
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'book_state.dart';

@Injectable()
class BookCubit extends ChessCubit<BookState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  BookCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const BookLoadingState());

  void init(String bookId) {
    _getBook(bookId);
  }

  Future<void> _getBook(String bookId) async {
    try {
      final book = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getBookById(id: bookId),
      );

      if (book != null) {
        safeEmit(BookLoadedState(book));
      } else {
        safeEmit(const BookErrorState());
      }
    } on ChessException catch (exception) {
      safeEmit(const BookErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

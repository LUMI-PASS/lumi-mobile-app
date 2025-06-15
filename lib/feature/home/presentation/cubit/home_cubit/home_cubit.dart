import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/courses/domain/repository/base_course_repository.dart';
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart';
import 'package:founders_academy/feature/home/presentation/cubit/home_cubit/home_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class HomeCubit extends ChessCubit<HomeState> {
  final BaseHomeRepository _homeRepository;
  final BaseCourseRepository _courseRepository;
  final SafeExecutionManager _safeExecutionManager;

  HomeCubit(
    this._homeRepository,
    this._courseRepository,
    this._safeExecutionManager,
  ) : super(HomeState());

  void init() async {
    getActiveLiveStream();
    _getAfishaList();
    _getNewsList();
    _reviewMatchesList();
    _getBookList();
    _getGrandmastersList();
    getActiveCourses();
  }

  Future<void> getActiveCourses() async {
    try {
      final course = await _safeExecutionManager.makeAsyncSafeExecution(
        function: _courseRepository.getActiveCourse,
      );
      if (course != null) {
        safeEmit(state.copyWith(activeCourse: course));
      }
    } on FormatException catch (exception) {
      throw FormatException(exception.message);
    }
  }

  Future<void> _getAfishaList() async {
    try {
      final afishaList = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getAfishas(count: 2),
      );
      if (afishaList != null) {
        safeEmit(
          state.copyWith(
            afishaList: afishaList,
            isLoading: false,
          ),
        );
      }
    } on ChessException catch (exception) {
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getNewsList() async {
    try {
      final newsList = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getNews(count: 2),
      );
      if (newsList != null) {
        safeEmit(state.copyWith(newsList: newsList));
      }
    } on ChessException catch (exception) {
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _reviewMatchesList() async {
    try {
      final reviewMatchesList =
          await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getReviewMatches(count: 3),
      );
      if (reviewMatchesList != null) {
        safeEmit(state.copyWith(reviewMatchesList: reviewMatchesList));
      }
    } on ChessException catch (exception) {
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getBookList() async {
    try {
      final bookList = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getBooks(count: 4),
      );
      if (bookList != null) {
        safeEmit(state.copyWith(bookList: bookList));
      }
    } on ChessException catch (exception) {
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> getActiveLiveStream() async {
    try {
      final liveStream = await _safeExecutionManager.makeAsyncSafeExecution(
        function: _homeRepository.getActiveLiveStream,
      );

      if (liveStream != null) {
        safeEmit(state.copyWith(liveStream: liveStream));
      }
    } on ChessException catch (exception) {
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getGrandmastersList() async {
    try {
      final grandmastersList =
          await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getGrandmasters(count: 3),
      );

      if (grandmastersList != null) {
        safeEmit(state.copyWith(grandmastersList: grandmastersList));
      }
    } on ChessException catch (exception) {
      throw UnknownChessException(exception.toString());
    }
  }
}

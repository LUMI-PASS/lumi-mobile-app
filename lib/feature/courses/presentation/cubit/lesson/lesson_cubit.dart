import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/logging/logger.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/auth/domain/user_session_manager.dart';
import 'package:lumi_pass/feature/courses/data/model/lesson/lesson_data.dart';
import 'package:lumi_pass/feature/courses/domain/repository/base_course_repository.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'lesson_state.dart';

@Injectable()
class LessonCubit extends ChessCubit<LessonState> {
  final BaseCourseRepository _courseRepository;
  final UserSessionManager _userSessionManager;
  final SafeExecutionManager _safeExecutionManager;

  LessonCubit(
    this._courseRepository,
    this._userSessionManager,
    this._safeExecutionManager,
  ) : super(const LessonLoadingState());

  void init(String id) {
    _getLessonById(id);
  }

  Future<void> _getLessonById(String id) async {
    safeEmit(const LessonLoadingState());

    try {
      final lesson = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _courseRepository.getLessonById(id: id),
      );

      if (lesson == null) return;

      final bool hasQuiz = lesson.hasQuiz ?? false;
      final bool isLessonCompleted = lesson.isCompleted;

      final bool isCompleted = hasQuiz
          ? await _isQuizLessonCompleted(id, isLessonCompleted)
          : isLessonCompleted;

      safeEmit(LessonLoadedState(
        lesson: lesson,
        isCompleted: isCompleted,
      ));
    } on ChessException catch (exception) {
      safeEmit(LessonErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<bool> _isQuizLessonCompleted(String id, bool isLessonCompleted) async {
    return isLessonCompleted || await _getQuizLessonCompletion(id);
  }

  Future<void> completeLesson(String id) async {
    final currentState = state;

    if (currentState is! LessonLoadedState) return;

    if (currentState.lesson.hasQuiz ?? false) {
      final stored = await _storeQuizLessonCompletion(id);

      safeEmit(currentState.copyWith(isCompleted: true));

      if (stored) logger.f("lesson id ${currentState.lesson.id} stored");

      return;
    }

    try {
      final lesson = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _courseRepository.completeLesson(id: id),
      );

      if (lesson == null) return;

      safeEmit(currentState.copyWith(
        lesson: lesson,
        isCompleted: true,
      ));
    } on NotFoundChessException {
      // Handle 404 errors specifically
      safeEmit(LessonErrorState(NotFoundChessException()));
    } on ChessException catch (exception) {
      safeEmit(LessonErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<bool> _storeQuizLessonCompletion(String lessonId) async {
    final currentState = state;

    try {
      final userId = await _userSessionManager.getUserId();
      if (currentState is! LessonLoadedState) return false;
      if (userId != null) {
        final isCompletionStored =
            await _courseRepository.storeQuizLessonCompletion(
          userId: userId,
          lessonId: lessonId,
        );

        return isCompletionStored;
      } else {
        safeEmit(LessonErrorState(UnknownChessException("Username is null")));
        return false;
      }
    } on ChessException catch (exception) {
      safeEmit(LessonErrorState(exception));
      return false;
    }
  }

  Future<bool> _getQuizLessonCompletion(String lessonId) async {
    try {
      final userId = await _userSessionManager.getUserId();
      if (userId != null) {
        final completed = await _safeExecutionManager.makeAsyncSafeExecution(
          function: () => _courseRepository.getQuizLessonCompletion(
            userId: userId,
            lessonId: lessonId,
          ),
        );
        return completed;
      }
      return false;
    } on ChessException catch (exception) {
      safeEmit(LessonErrorState(exception));
      return false;
    }
  }
}

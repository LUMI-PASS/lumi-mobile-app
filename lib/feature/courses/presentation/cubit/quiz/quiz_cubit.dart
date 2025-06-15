import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/courses/data/model/quiz/option_data.dart';
import 'package:lumi_pass/feature/courses/data/model/quiz/quiz_data.dart';
import 'package:lumi_pass/feature/courses/data/model/quiz_submission/submit_quiz_data.dart';
import 'package:lumi_pass/feature/courses/domain/repository/base_course_repository.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'quiz_state.dart';

@Injectable()
class QuizCubit extends ChessCubit<QuizState> {
  final BaseCourseRepository _courseRepository;
  final SafeExecutionManager _safeExecutionManager;

  QuizCubit(
    this._courseRepository,
    this._safeExecutionManager,
  ) : super(const QuizLoadingState());

  String? _lessonId;

  void init(String id) {
    _lessonId = id;
    _getLessonQuiz(id);
  }

  Future<void> _getLessonQuiz(String id) async {
    safeEmit(const QuizLoadingState());

    try {
      final quizzes = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _courseRepository.getLessonQuizzes(id: id),
      );

      if (quizzes != null) {
        safeEmit(QuizLoadedState(
          quizzes: quizzes,
          activeQuizIndex: 0,
          quizzesAnswers: [],
        ));
      }
    } on ChessException catch (exception) {
      safeEmit(QuizErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  void loadNextQuiz(List<OptionData> selectedOptions) {
    final currentState = state;

    if (currentState is! QuizLoadedState) return;

    final quizId = currentState.activeQuiz.id;
    final selectedOptionsIdList =
        selectedOptions.map((option) => option.id).toList();

    final currentQuizResult =
        SubmitQuizData(quizId: quizId, selectedOptions: selectedOptionsIdList);

    currentState.quizzesAnswers.add(currentQuizResult);

    if (currentState.isNextQuizAvailable) {
      safeEmit(
        currentState.copyWith(
          activeQuizIndex: currentState.activeQuizIndex + 1,
        ),
      );
    } else {
      _submitQuizzesAnswers(
          currentState.quizzesAnswers, currentState.quizzes.length);
    }
  }

  Future<void> _submitQuizzesAnswers(
    List<SubmitQuizData> quizzesAnswers,
    int totalQuizzesCount,
  ) async {
    safeEmit(const QuizLoadingState());
    try {
      final quizResult = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _courseRepository.submitQuiz(
          id: _lessonId ?? '',
          submitQuizData: quizzesAnswers,
        ),
      );

      safeEmit(
        QuizFinishedState(
          correctAnswersCount: quizResult.correctAnswersCount ?? 0,
          earnedPoints: quizResult.quizPoint ?? 0,
          totalQuizzesCount: totalQuizzesCount,
        ),
      );
    } on ChessException catch (exception) {
      safeEmit(QuizErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }
}

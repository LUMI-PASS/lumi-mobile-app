part of 'quiz_cubit.dart';

sealed class QuizState {
  const QuizState();
}

class QuizLoadingState extends QuizState {
  const QuizLoadingState();
}

class QuizLoadedState extends QuizState {
  final int activeQuizIndex;
  final List<QuizData> quizzes;
  final List<SubmitQuizData> quizzesAnswers;

  QuizLoadedState({
    required this.activeQuizIndex,
    required this.quizzes,
    required this.quizzesAnswers,
  });

  QuizLoadedState copyWith({
    int? activeQuizIndex,
    List<QuizData>? quizzes,
    List<SubmitQuizData>? quizzesAnswers,
  }) {
    return QuizLoadedState(
      activeQuizIndex: activeQuizIndex ?? this.activeQuizIndex,
      quizzes: quizzes ?? this.quizzes,
      quizzesAnswers: quizzesAnswers ?? this.quizzesAnswers,
    );
  }

  late final activeQuizNumber = activeQuizIndex + 1;

  late final activeQuiz = quizzes[activeQuizIndex];

  late final quizPageTitle = "$activeQuizNumber/${quizzes.length}";

  late final isNextQuizAvailable = activeQuizNumber < quizzes.length;
}

class QuizErrorState extends QuizState {
  final ChessException exception;
  const QuizErrorState(this.exception);
}

class QuizFinishedState extends QuizState {
  final int correctAnswersCount;
  final int totalQuizzesCount;
  final int earnedPoints;

  const QuizFinishedState({
    required this.correctAnswersCount,
    required this.totalQuizzesCount,
    required this.earnedPoints,
  });
}

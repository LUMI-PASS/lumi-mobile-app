part of 'lesson_cubit.dart';

sealed class LessonState {
  const LessonState();
}

class LessonLoadingState extends LessonState {
  const LessonLoadingState();
}

class LessonLoadedState extends LessonState {
  final LessonData lesson;
  final bool isCompleted;

  const LessonLoadedState({
    required this.lesson,
    required this.isCompleted,
  });

  LessonLoadedState copyWith({
    LessonData? lesson,
    bool? isCompleted,
  }) {
    return LessonLoadedState(
      lesson: lesson ?? this.lesson,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class LessonErrorState extends LessonState {
  final ChessException exception;
  const LessonErrorState(this.exception);
}

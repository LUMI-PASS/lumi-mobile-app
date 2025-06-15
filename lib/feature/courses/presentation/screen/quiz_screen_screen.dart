import 'package:auto_route/auto_route.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:founders_academy/feature/courses/presentation/cubit/quiz/quiz_cubit.dart';
import 'package:founders_academy/feature/courses/presentation/widget/check_box_widget.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class QuizDetailsScreen extends StatelessWidget {
  final String id;

  const QuizDetailsScreen({
    required this.id,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<QuizCubit>()..init(id),
      child: BlocListener<QuizCubit, QuizState>(
        listener: (context, state) {
          if (state is QuizFinishedState) {
            context.router.push(
              QuizResultRoute(
                correctAnswersCount: state.correctAnswersCount,
                totalQuizzesCount: state.totalQuizzesCount,
                earnedPoints: state.earnedPoints,
              ),
            );
          }
          if (state is QuizErrorState) {
            showModalBottomSheet(
              context: context,
              builder: (_) => const ChessErrorStateBottomSheet(),
            );
          }
        },
        child: Scaffold(
          backgroundColor: ChessColors.greyG20,
          appBar: AppBar(
              centerTitle: true,
              backgroundColor: ChessColors.greyG20,
              automaticallyImplyLeading: false,
              leading: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: GestureDetector(
                  onTap: () => context.router.pop(),
                  child: ChessUiKitAssets.icons.general.arrowNarrowLeft.svg(
                    height: 24,
                    width: 24,
                  ),
                ),
              ),
              title: BlocBuilder<QuizCubit, QuizState>(
                builder: (context, state) {
                  return Text(
                    state is QuizLoadedState
                        ? state.quizPageTitle
                        : 'Yuklanmoqda...',
                    style: context.textTheme.headlineSemibold.copyWith(
                      color: ChessColors.greyG900,
                    ),
                  );
                },
              )),
          body: BlocBuilder<QuizCubit, QuizState>(
            builder: (context, state) {
              return switch (state) {
                QuizLoadingState() => const ChessCircularProgressIndicator(),
                QuizLoadedState() => Builder(
                    builder: (context) {
                      return CheckboxWidget(
                        quiz: state.quizzes[state.activeQuizIndex],
                        questionNumber: state.activeQuizNumber.toString(),
                        isNextQuizAvailable: state.isNextQuizAvailable,
                        onPrimaryButtonTap: (selectedOptions) => context
                            .read<QuizCubit>()
                            .loadNextQuiz(selectedOptions),
                      );
                    },
                  ),
                QuizErrorState() ||
                QuizFinishedState() =>
                  const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }
}

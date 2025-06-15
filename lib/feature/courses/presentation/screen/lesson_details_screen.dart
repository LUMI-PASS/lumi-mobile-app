import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/di/get_it.dart';
import 'package:lumi_pass/feature/courses/data/model/lesson/lesson_data.dart';
import 'package:lumi_pass/feature/courses/data/model/module/module_data.dart';
import 'package:lumi_pass/feature/courses/presentation/cubit/lesson/lesson_cubit.dart';
import 'package:lumi_pass/feature/courses/presentation/widget/lesson_not_found.widget.dart';
import 'package:lumi_pass/feature/home/presentation/screen/list_screen/items_list_screen.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';

@RoutePage()
class LessonDetailsScreen extends StatelessWidget {
  final LessonData lesson;
  final ModuleData module;

  const LessonDetailsScreen({
    super.key,
    required this.lesson,
    required this.module,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<LessonCubit>()..init(lesson.id),
      child: BlocBuilder<LessonCubit, LessonState>(
        builder: (context, state) {
          return PopScope(
              canPop: false,
              onPopInvoked: (didPop) {
                context.router.popForced();
              },
              child: ItemsListScreen(
                title: state is LessonLoadedState
                    ? state.lesson.name
                    : "Yuklanmoqda...",
                body: switch (state) {
                  LessonLoadingState() =>
                    const ChessCircularProgressIndicator(),
                  LessonLoadedState() => _BodyContent(
                      lesson: state.lesson,
                      module: module,
                      isNextButtonEnabled: state.isCompleted,
                    ),
                  LessonErrorState() =>
                    state.exception is NotFoundChessException
                        ? const LessonNotFound()
                        : const SizedBox(),
                },
              ));
        },
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  final LessonData lesson;
  final ModuleData module;
  final bool isNextButtonEnabled;

  const _BodyContent({
    required this.lesson,
    required this.module,
    required this.isNextButtonEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9, // Adjust the aspect ratio as needed
                    child: VimeoPlayer(
                      videoId: lesson.youtubeLink,
                      onVideoCompleted: () {
                        context.read<LessonCubit>().completeLesson(lesson.id);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    child: Html(
                      data: lesson.description,
                      style: context.textTheme.htmlStyle.map(
                        (key, value) =>
                            MapEntry(key, Style.fromTextStyle(value)),
                      ),
                      onLinkTap: (url, _, __) => ChessUrlLauncher.launch(
                        url: url,
                        onError: (error) {
                          CornerCaseBottomSheet.show(
                            context,
                            type: CornerCaseType.error,
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Column(
              children: [
                lesson.hasQuiz == true
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ChessButton.secondary(
                          onPressed: () => _onButtonTapQuiz(context),
                          label: (lesson.hasQuiz == true)
                              ? "Testga O'tish"
                              : "Testga O'tish",
                        ),
                      )
                    : const SizedBox(),
                ChessButton.secondary(
                  onPressed: () => _onButtonTap(context),
                  label: (lesson.hasQuiz == true && lesson.isCompleted != true)
                      ? "Keyingisiga o'tish"
                      : "Keyingisiga o'tish",
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _onButtonTap(BuildContext context) {
    _openNextLesson(context);
    ChessVideoPlayer.pause();
  }

  void _onButtonTapQuiz(BuildContext context) {
    _openQuizScreen(context);

    ChessVideoPlayer.pause();
  }

  void _openNextLesson(BuildContext context) {
    final String? nextLessonId = module.nextLessonId(lesson.id);

    if (nextLessonId != null) {
      context.read<LessonCubit>().init(nextLessonId);
    } else {
      context.router.pop();
    }
  }

  void _openQuizScreen(BuildContext context) {
    context.router.push(QuizDetailsRoute(id: lesson.id));
  }
}

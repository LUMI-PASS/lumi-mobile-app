import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

@RoutePage()
class QuizResultScreen extends StatelessWidget {
  final int correctAnswersCount;
  final int totalQuizzesCount;
  final int earnedPoints;

  const QuizResultScreen({
    required this.correctAnswersCount,
    required this.totalQuizzesCount,
    required this.earnedPoints,
    super.key,
  });

  String getScoreMessage() {
    double percentage = (correctAnswersCount / totalQuizzesCount) * 100;

    if (percentage <= 40) {
      return "Koʻnglingizni choʻktirmang, siz yaxshiroq natija koʻrsata olasiz!";
    } else if (percentage < 100) {
      return "Ohoo, natija yaxshi! Lekin bundan ham yaxshisi qoʻlingizdan kelishiga ishonamiz!";
    } else {
      return "Qoyil! Natijangizga gap yoʻq!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChessResultScreen(
      image: ChessUiKitAssets.icons.course.quizSuccess.svg(),
      title: "To'g'ri javoblar: $correctAnswersCount/$totalQuizzesCount",
      subtitle: getScoreMessage(),
      primaryButtonLabel: "Mashqni tugatish",
      onPrimaryButtonTap: () {
        Navigator.of(context).popUntil(
          (route) => route.settings.name == CourseDetailsRoute.name,
        );
      },
      // Code below removed as there is no need for retry option for quiz
      // secondaryButtonLabel: "Qayta urinish",
      // onSecondaryButtonTap: () {
      //   Navigator.of(context).popUntil(
      //     (route) => route.settings.name == LessonDetailsRoute.name,
      //   );
      // },
    );
  }
}

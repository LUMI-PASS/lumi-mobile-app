import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PuzzleResultScreen extends StatelessWidget {
  final int currentIndex;
  final int score;
  final int correctPuzzleCount;
  const PuzzleResultScreen({
    required this.currentIndex,
    required this.score,
    required this.correctPuzzleCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChessResultScreen(
      title: "To'gri javoblar: $correctPuzzleCount/${currentIndex + 1}",
      subtitle:
          "Qoyil! Siz $score ballni qolga kiritdingiz. Xuddi shu ruhda davom eting.",
      image: ChessUiKitAssets.icons.course.quizSuccess.svg(),
      primaryButtonLabel: "Mashqni tugatish",
      onPrimaryButtonTap: () {
        context.popRoute(context);
      },
    );
  }
}

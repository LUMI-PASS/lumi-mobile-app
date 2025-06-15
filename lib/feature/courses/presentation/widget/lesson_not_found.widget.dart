import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class LessonNotFound extends StatelessWidget {
  const LessonNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      children: [
        ChessUiKitAssets.icons.general.notFoound.svg(),
        Text(
          'Siz kurslarni sotib olmagansiz!',
          style: context.textTheme.title3Bold.copyWith(
            color: ChessColors.black,
          ),
        ),
        Text(
          'Ushbu saxifa pullik kurslar sotib olinganda mavjud bo‘ladi, iltimos kusrlarni sotib oling.',
          style: context.textTheme.calloutMedium.copyWith(
            color: ChessColors.greyG200,
          ),
        ),
      ],
    ));
  }
}

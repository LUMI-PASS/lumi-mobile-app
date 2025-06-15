import 'package:chess_ui_kit/src/theme/chess_colors.dart';
import 'package:chess_ui_kit/src/theme/theme_extension.dart';
import 'package:chess_ui_kit/src/ui_components/button/chess_button.dart';
import 'package:flutter/material.dart';

class ChessAndroidDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirmTap;
  final VoidCallback? onBackTap;

  const ChessAndroidDialog({
    super.key,
    required this.title,
    required this.message,
    this.onConfirmTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ChessColors.white,
      title: Text(title),
      content: Text(
        message,
        style: context.textTheme.subheadlineRegular.copyWith(
          color: ChessColors.greyG900,
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: ChessButton.text(
                onPressed: onConfirmTap,
                label: 'Ha',
                textStyle: const TextStyle(
                  color: ChessColors.errorDefault,
                ),
              ),
            ),
            Expanded(
              child: ChessButton.text(
                onPressed: onBackTap,
                label: "Yo'q",
                textStyle: const TextStyle(
                  color: ChessColors.primaryDefault,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

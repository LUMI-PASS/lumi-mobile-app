import 'package:chess_ui_kit/src/theme/chess_colors.dart';
import 'package:flutter/cupertino.dart';

class ChessIosDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onConfirmTap;
  final VoidCallback? onBackTap;

  const ChessIosDialog({
    super.key,
    required this.title,
    required this.message,
    this.onConfirmTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: onConfirmTap,
          child: const Text(
            'Ha',
            style: TextStyle(color: ChessColors.errorDefault),
          ),
        ),
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: onBackTap,
          child: const Text(
            "Yo'q",
            style: TextStyle(color: ChessColors.primaryDefault),
          ),
        ),
      ],
    );
  }
}

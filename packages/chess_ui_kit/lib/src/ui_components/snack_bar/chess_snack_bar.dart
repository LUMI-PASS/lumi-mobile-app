import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
}

class ChessSnackBar {
  final IconData icon;
  final String message;
  final Color backgroundColor;

  const ChessSnackBar({
    required this.icon,
    required this.message,
    required this.backgroundColor,
  });
  SnackBar get getChessSnackBar {
    return SnackBar(
      content: _SnackBarContent(
          icon: icon, message: message, backgroundColor: backgroundColor),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
    );
  }
}

class _SnackBarContent extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color backgroundColor;

  const _SnackBarContent({
    required this.icon,
    required this.message,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Icon(
            icon,
            color: ChessColors.white,
          ),
        ),
        Expanded(
          child: Text(
            maxLines: 1,
            message,
            style: context.textTheme.bodyRegular.copyWith(
              color: ChessColors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

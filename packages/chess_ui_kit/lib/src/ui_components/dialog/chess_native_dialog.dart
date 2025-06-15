import 'dart:io';

import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChessNativeDialog {
  static void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? yesButtonLabel,
    String? noButtonLabel,
    VoidCallback? onConfirm,
    VoidCallback? onBackTap,
  }) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: onConfirm,
              child: Text(
                yesButtonLabel ?? 'Ha',
                style: const TextStyle(color: ChessColors.errorDefault),
              ),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: onBackTap,
              child: Text(
                noButtonLabel ?? "Yo'q",
                style: const TextStyle(color: ChessColors.primaryDefault),
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
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
                    onPressed: onConfirm,
                    label: yesButtonLabel ?? 'Ha',
                    textStyle: const TextStyle(
                      color: ChessColors.errorDefault,
                    ),
                  ),
                ),
                Expanded(
                  child: ChessButton.text(
                    onPressed: onBackTap,
                    label: noButtonLabel ?? "Yo'q",
                    textStyle: const TextStyle(
                      color: ChessColors.primaryDefault,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
  }

  static void showNotificationDialog({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    VoidCallback? onBackTap,
  }) {
    if (Platform.isIOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: onBackTap,
              child: const Text(
                "Keyinroq",
                style: TextStyle(color: ChessColors.primaryDefault),
              ),
            ),
            CupertinoDialogAction(
              onPressed: onConfirm,
              child: const Text(
                "Yangilash",
                style: TextStyle(color: ChessColors.primaryDefault),
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
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
                    onPressed: onBackTap,
                    label: "Keyinroq",
                    textStyle: const TextStyle(
                      color: ChessColors.primaryDefault,
                    ),
                  ),
                ),
                Expanded(
                  child: ChessButton.text(
                    onPressed: onConfirm,
                    label: "Yangilash",
                    textStyle: const TextStyle(
                      color: ChessColors.primaryDefault,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
  }
}

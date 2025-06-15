import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class ChessErrorStateBottomSheet extends StatelessWidget {
  const ChessErrorStateBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CornerCaseBottomSheet(
      image: ChessUiKitAssets.icons.cornerCase.errorIcon.svg(
        height: 40,
        width: 40,
        fit: BoxFit.none,
      ),
      title: "Nimadir noto'g'ri bajarildi",
      subtitle: "So'rovingiz yuklanmayapti, qayta urinib ko‘ring",
      buttonLabel: "Qayta urinish",
      onPressed: Navigator.of(context).pop,
    );
  }
}

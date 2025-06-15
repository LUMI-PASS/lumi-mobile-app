import 'package:chess_ui_kit/src/assets/assets.gen.dart';
import 'package:chess_ui_kit/src/ui_components/corner_case_bottom_sheet/corner_case_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ChessComingSoonBottomSheet extends StatelessWidget {
  const ChessComingSoonBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CornerCaseBottomSheet(
      image: ChessUiKitAssets.icons.cornerCase.soonIcon.svg(
        height: 40,
        width: 40,
        fit: BoxFit.none,
      ),
      title: "Tez kunda",
      subtitle: "Bu sahifa hozirda ishlab chiqilmoqda, "
          "tez kunda ko'rishingiz mumkin bo'ladi",
      buttonLabel: "Ortga qaytish",
      onPressed: Navigator.of(context).pop,
    );
  }
}

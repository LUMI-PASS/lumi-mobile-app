import 'package:chess_ui_kit/src/assets/assets.gen.dart';
import 'package:chess_ui_kit/src/ui_components/corner_case_bottom_sheet/corner_case_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ChessNoConnectionBottomSheet extends StatelessWidget {
  const ChessNoConnectionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return CornerCaseBottomSheet(
      image: ChessUiKitAssets.icons.cornerCase.networkConnection.svg(
        height: 40,
        width: 40,
        fit: BoxFit.none,
      ),
      title: "Internet uzildi",
      subtitle: "Internetingizni tekshiring va qaytadan urinib ko'ring",
      onPressed: Navigator.of(context).pop,
      buttonLabel: "Qayta urinish",
    );
  }
}

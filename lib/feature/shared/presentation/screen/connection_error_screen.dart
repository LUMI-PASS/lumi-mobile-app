import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

@RoutePage<bool>()
class ConnectionErrorScreen extends StatelessWidget {
  const ConnectionErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChessResultScreen(
      image: Container(
        height: 80,
        width: 80,
        decoration: BoxDecoration(
          color: ChessColors.greyG20,
          borderRadius: ChessRadius.radiusLg,
        ),
        child: ChessUiKitAssets.icons.cornerCase.networkConnection.svg(
          fit: BoxFit.none,
        ),
      ),
      title: "Internet uzildi",
      subtitle: "Internetingzini tekshiring va qaytadan urinib ko'ring",
      primaryButtonLabel: "Qayta urinish",
      onPrimaryButtonTap: () => Navigator.of(context).pop(true),
    );
  }
}

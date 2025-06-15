import 'package:auto_route/auto_route.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AfishaResultScreen extends StatelessWidget {
  const AfishaResultScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChessResultScreen(
      title: "Tabriklaymiz!",
      subtitle: "Siz muvaffaqiyatli ro'yxatga o'tdingiz",
      image: ChessUiKitAssets.images.successLogo.svg(),
      primaryButtonLabel: "Bosh sahifaga o'tish",
      onPrimaryButtonTap: () {
        context.popRoute(context);
      },
    );
  }
}

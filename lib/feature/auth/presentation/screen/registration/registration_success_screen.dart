import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/routing/app_router.gr.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

@RoutePage()
class RegistrationSuccessScreen extends StatelessWidget {
  const RegistrationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: ChessResultScreen(
        image: ChessUiKitAssets.images.successLogo.svg(),
        title: "Tabriklaymiz",
        subtitle: "Siz ro'yxatdan muvaffaqiyatli o'tdingiz",
        onPrimaryButtonTap: () {
          context.router.replaceAll([
            const AuthorizedContainerRoute(),
          ]);
        },
        primaryButtonLabel: "Bosh sahifaga o'tish",
      ),
    );
  }
}

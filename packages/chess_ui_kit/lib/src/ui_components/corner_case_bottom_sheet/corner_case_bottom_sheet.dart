import 'package:chess_ui_kit/chess_ui_kit.dart'; // Assuming this is a custom package you are using.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum CornerCaseType { soon, error, connection }

class CornerCaseBottomSheet extends StatelessWidget {
  final SvgPicture image;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final String buttonLabel;

  const CornerCaseBottomSheet({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    required this.buttonLabel,
  });

  static void show(BuildContext context, {required CornerCaseType type}) {
    Widget child;

    switch (type) {
      case CornerCaseType.connection:
        child = const ChessNoConnectionBottomSheet();
        break;
      case CornerCaseType.error:
        child = const ChessErrorStateBottomSheet();
        break;
      case CornerCaseType.soon:
        child = const ChessComingSoonBottomSheet();
        break;
    }

    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      builder: (_) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ChessColors.greyG800,
        borderRadius: ChessRadius.radiusXl,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 24),
                child: Container(
                  height: 6,
                  width: 34,
                  decoration: BoxDecoration(
                    color: ChessColors.greyG30,
                    borderRadius: ChessRadius.radiusXl,
                  ),
                ),
              ),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: ChessColors.greyG900,
                  borderRadius: ChessRadius.radiusLg,
                ),
                child: image,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Text(
                  title,
                  style: context.textTheme.title3Bold.copyWith(
                    color: ChessColors.greyG10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                subtitle,
                style: context.textTheme.bodyRegular.copyWith(
                  color: ChessColors.greyG20,
                ),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ChessButton.secondary(
                  textStyle: context.textTheme.bodyRegular.copyWith(color: ChessColors.white),
                  onPressed: onPressed,
                  label: buttonLabel,

                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

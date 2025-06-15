import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class ChessResultScreen extends StatelessWidget {
  final Widget image;
  final String title;
  final String subtitle;
  final String? primaryButtonLabel;
  final VoidCallback? onPrimaryButtonTap;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryButtonTap;

  const ChessResultScreen({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.primaryButtonLabel,
    this.onPrimaryButtonTap,
    this.secondaryButtonLabel,
    this.onSecondaryButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChessColors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                image,
                const SizedBox(height: 24),
                Text(
                  textAlign: TextAlign.center,
                  title,
                  style: context.textTheme.title1Bold.copyWith(
                    color: ChessColors.greyG20,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  textAlign: TextAlign.center,
                  subtitle,
                  style: context.textTheme.calloutRegular.copyWith(
                    color: ChessColors.greyG40,
                  ),
                ),
                const Spacer(),
                if (primaryButtonLabel != null) ...[
                  const SizedBox(height: 16),
                  ChessButton.primary(
                    onPressed: onPrimaryButtonTap,
                    label: primaryButtonLabel ?? '',
                    background: ChessColors.primaryDefault,
                    borderRadius: 16,
                    textStyle: context.textTheme.bodyMedium.copyWith(
                      color: ChessColors.white,
                    ),
                  ),
                ],
                if (secondaryButtonLabel != null) ...[
                  const SizedBox(height: 16),
                  ChessButton.secondary(
                    onPressed: onSecondaryButtonTap,
                    label: secondaryButtonLabel ?? '',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

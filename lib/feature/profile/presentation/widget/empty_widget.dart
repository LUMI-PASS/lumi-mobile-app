import 'package:chess_ui_kit/chess_ui_kit.dart'; // Replace with your actual UI kit import
import 'package:flutter/material.dart';

class EmptyCertificateCenter extends StatelessWidget {
  const EmptyCertificateCenter({super.key});

  @override
  Widget build(BuildContext context) {
    // Replace 'ChessUiKitAssets.icons.general.certificate' with your actual icon path or widget
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 24.0), // Optional padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Certificate Icon
            ChessUiKitAssets.icons.course.certificate.svg(
              width: 100,
              height: 100,
              colorFilter: const ColorFilter.mode(
                ChessColors.primaryDefault,
                BlendMode.srcIn,
              ), // Adjust the color if necessary
            ),
            const SizedBox(height: 16), // Spacing between icon and text
            // Message Text
            Text(
              'Siz kurslarni tugatmagansiz',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSemibold.copyWith(
                color: ChessColors.greyG10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

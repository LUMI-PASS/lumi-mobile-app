import 'package:chess_ui_kit/chess_ui_kit.dart' show ChessUiKitAssets;
import 'package:chess_ui_kit/src/theme/chess_colors.dart';
import 'package:flutter/material.dart';

class ChessCircularProgressIndicator extends StatelessWidget {
  final double strokeWidth;
  final Color color;

  const ChessCircularProgressIndicator({
    super.key,
    this.strokeWidth = 4,
    this.color = ChessColors.primaryDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ChessUiKitAssets.lotties.indicator.lottie(
        height: 36,
        width: 36,
      ),
    );
  }
}

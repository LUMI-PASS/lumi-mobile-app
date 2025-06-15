import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class ChessProgressIndicator extends StatelessWidget {
  final int value;
  const ChessProgressIndicator({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text("$value%"),
        const SizedBox(width: 4),
        Expanded(
          child: LinearProgressIndicator(
            minHeight: 8,
            borderRadius: ChessRadius.radius5xl,
            backgroundColor: ChessColors.greyG20,
            color: ChessColors.primaryDefault,
            value: value * 0.01,
          ),
        )
      ],
    );
  }
}

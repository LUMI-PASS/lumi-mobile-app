import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class HomeItemsGroup extends StatelessWidget {
  final String title;
  final VoidCallback onViewAllTap;
  final Widget body;

  const HomeItemsGroup({
    required this.title,
    required this.onViewAllTap,
    required this.body,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: context.textTheme.title3Regular.copyWith(
                    color: ChessColors.white,
                   ),
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: Text(
                  'Hammasini ko\'rish',
                  style: context.textTheme.subheadlineSemibold.copyWith(
                    color: ChessColors.primaryDefault,
                      decoration: TextDecoration.underline, decorationColor: ChessColors.primaryDefault
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        body,
      ],
    );
  }
}

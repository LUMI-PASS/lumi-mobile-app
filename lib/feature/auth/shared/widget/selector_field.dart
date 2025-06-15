import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class SelectorField extends StatelessWidget {
  final String placeholder;
  final String? value;

  const SelectorField({
    super.key,
    required this.placeholder,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: ChessColors.greyG30,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          value ?? placeholder,
          maxLines: 1,
          style: context.textTheme.bodyRegular.copyWith(
            color: ChessColors.greyG400,
          ),
        ),
      ),
    );
  }
}

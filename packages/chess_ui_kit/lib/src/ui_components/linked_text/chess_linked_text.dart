import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ChessLinkedText extends StatelessWidget {
  final String text;
  final Function()? onLinkTap;
  final TextStyle? textStyle;

  static final RegExp regex = RegExp("(?={)|(?<=})");

  const ChessLinkedText({
    super.key,
    required this.text,
    this.onLinkTap,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> split = text.split(regex);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: <InlineSpan>[
          for (String text in split)
            !text.startsWith("{")
                ? TextSpan(
                    text: text,
                    style: textStyle ??
                        context.textTheme.bodyMedium.copyWith(
                          color: ChessColors.greyG20,
                        ),
                  )
                : TextSpan(
                    text: text.substring(1, text.length - 1),
                    recognizer: TapGestureRecognizer()..onTap = onLinkTap,
                    style: textStyle ??
                        context.textTheme.bodyMedium.copyWith(
                          color: ChessColors.primaryDefault,
                        ),
                  ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:chess_ui_kit/src/utils/button_state_mixin.dart';
import 'package:flutter/material.dart';

enum ButtonType {
  primary,
  secondary,
  ghost,
  text,
}

class ChessButton extends StatefulWidget {
  final FutureOr<void> Function()? onPressed;
  final String label;
  final ButtonType type;
  final Color? background;
  final Color? foreground;
  final TextStyle? textStyle;
  final bool isSizeByContent;
  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;
  final Color? borderColor;

  const ChessButton.primary({
    required this.onPressed,
    required this.label,
    this.background,
    this.foreground,
    this.textStyle,
    this.contentPadding,
    this.borderRadius,
    this.isSizeByContent = false,
    super.key,
  })  : borderColor = null,
        type = ButtonType.primary;

  const ChessButton.secondary({
    required this.onPressed,
    required this.label,
    this.background,
    this.foreground,
    this.textStyle,
    this.contentPadding,
    this.borderRadius,
    this.isSizeByContent = false,
    this.borderColor,
    super.key,
  }) : type = ButtonType.secondary;

  const ChessButton.ghost({
    required this.onPressed,
    required this.label,
    this.background,
    this.foreground,
    this.textStyle,
    this.contentPadding,
    this.borderRadius,
    this.isSizeByContent = false,
    super.key,
  })  : borderColor = null,
        type = ButtonType.ghost;

  const ChessButton.text({
    required this.onPressed,
    required this.label,
    this.background,
    this.foreground,
    this.textStyle,
    this.contentPadding,
    this.borderRadius,
    this.isSizeByContent = false,
    super.key,
  })  : borderColor = null,
        type = ButtonType.text;

  @override
  State<ChessButton> createState() => _ChessButtonState();
}

class _ChessButtonState extends State<ChessButton> with ButtonStateMixin {
  @override
  Widget build(BuildContext context) {
    var style = _getButtonStyle(context, widget.type);

    final useCustomStyle = widget.background != null ||
        widget.foreground != null ||
        widget.textStyle != null ||
        widget.contentPadding != null ||
        widget.borderRadius != null ||
        widget.borderColor != null;

    if (useCustomStyle) {
      style = style.copy(
        widget.background,
        widget.foreground,
        widget.textStyle,
        widget.isSizeByContent,
        widget.contentPadding,
        widget.borderRadius,
        widget.type,
        widget.borderColor,
      );
    }

    final onPressed = widget.onPressed;

    final onPressedFunction = onPressed is Future<void> Function()?
        ? onPressedAsyncFuncOrNull(onPressed)
        : onPressedFuncOrNull(onPressed);

    var circularProgressIndicator = _getCircularProgressIndicator(widget.type);

    return FilledButton(
      style: style,
      onPressed: onPressedFunction,
      child: isProcessing
          ? circularProgressIndicator
          : Text(
              widget.label,
              style: widget.textStyle,
              strutStyle: const StrutStyle(
                height: 1,
                forceStrutHeight: true,
              ),
            ),
    );
  }
}

ButtonStyle _getButtonStyle(BuildContext context, ButtonType type) {
  final styles = ChessButtonStyle.of(context);

  switch (type) {
    case ButtonType.primary:
      return styles.primaryButtonStyle;
    case ButtonType.secondary:
      return styles.secondaryButtonStyle;
    case ButtonType.ghost:
      return styles.ghostButtonStyle;
    case ButtonType.text:
      return styles.textButtonStyle;
  }
}

Widget _getCircularProgressIndicator(ButtonType type) {
  if (type == ButtonType.primary) {
    return const _CircularProgressIndicator(color: ChessColors.white);
  } else if (type == ButtonType.text) {
    return const _CircularProgressIndicator(
      color: ChessColors.primaryDefault,
      size: 16,
    );
  } else {
    return const _CircularProgressIndicator(color: ChessColors.primaryDefault);
  }
}

class _CircularProgressIndicator extends StatelessWidget {
  final Color color;
  final double? size;

  const _CircularProgressIndicator({required this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size ?? 24,
      width: size ?? 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color,
      ),
    );
  }
}

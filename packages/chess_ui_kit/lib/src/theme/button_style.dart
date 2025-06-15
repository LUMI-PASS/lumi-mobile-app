import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';

class ChessButtonStyle {
  final ButtonStyle primaryButtonStyle;
  final ButtonStyle secondaryButtonStyle;
  final ButtonStyle ghostButtonStyle;
  final ButtonStyle textButtonStyle;

  const ChessButtonStyle({
    required this.primaryButtonStyle,
    required this.secondaryButtonStyle,
    required this.ghostButtonStyle,
    required this.textButtonStyle,
  });

  factory ChessButtonStyle.fromTheme({required ChessTextTheme textTheme}) {
    final textStyle = MaterialStateProperty.all(
      textTheme.bodyMedium.copyWith(
        fontFamily: FontFamily.nunito,
      ),
    );
    final textButtonTextStyle = MaterialStateProperty.all(
      textTheme.subheadlineSemibold.copyWith(
        fontFamily: FontFamily.nunito,
      ),
    );

    final shape = MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );

    final transparentColor = MaterialStateProperty.all(
      Colors.transparent,
    );

    final primaryBackgroundColor = MaterialStateProperty.resolveWith(
      (states) {
        if (states.contains(MaterialState.disabled)) {
          return ChessColors.greyG30;
        }

        return ChessColors.primaryDefault;
      },
    );

    final primaryForegroundColor = MaterialStateProperty.resolveWith(
      (states) {
        if (states.contains(MaterialState.disabled)) {
          return ChessColors.greyG50;
        }

        return ChessColors.white;
      },
    );

    final minimumSize = MaterialStateProperty.all(
      const Size(double.infinity, 56),
    );

    final smallerMinSize = MaterialStateProperty.all(
      const Size(double.infinity, 40),
    );

    final outlinedSideStateResolved = MaterialStateProperty.resolveWith(
      (states) {
        if (states.contains(MaterialState.disabled)) {
          return const BorderSide(
            color: ChessColors.greyG30,
          );
        }

        return const BorderSide(
          color: ChessColors.primaryDefault,
        );
      },
    );

    final secondaryBackground = MaterialStateProperty.resolveWith(
      (states) {
        if (states.contains(MaterialState.pressed)) {
          return ChessColors.greyG20;
        }

        return Colors.transparent;
      },
    );

    final secondaryForeground = MaterialStateProperty.resolveWith(
      (states) {
        if (states.contains(MaterialState.disabled)) {
          return ChessColors.greyG50;
        }

        return ChessColors.greyG900;
      },
    );

    final textButtonForeground = MaterialStateProperty.resolveWith(
      (states) {
        if (states.contains(MaterialState.disabled)) {
          return ChessColors.greyG50;
        }

        return ChessColors.primaryDefault;
      },
    );

    final primaryButtonStyle = ButtonStyle(
      textStyle: textStyle,
      backgroundColor: primaryBackgroundColor,
      foregroundColor: primaryForegroundColor,
      shape: shape,
      minimumSize: minimumSize,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final secondaryButtonStyle = ButtonStyle(
      textStyle: textStyle,
      backgroundColor: secondaryBackground,
      foregroundColor: secondaryForeground,
      shape: shape,
      side: outlinedSideStateResolved,
      minimumSize: minimumSize,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final ghostButtonStyle = ButtonStyle(
      textStyle: textStyle,
      backgroundColor: secondaryBackground,
      foregroundColor: secondaryForeground,
      shape: shape,
      minimumSize: minimumSize,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    final textButtonStyle = ButtonStyle(
      textStyle: textButtonTextStyle,
      backgroundColor: transparentColor,
      foregroundColor: textButtonForeground,
      shape: shape,
      minimumSize: smallerMinSize,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return ChessButtonStyle(
      primaryButtonStyle: primaryButtonStyle,
      secondaryButtonStyle: secondaryButtonStyle,
      ghostButtonStyle: ghostButtonStyle,
      textButtonStyle: textButtonStyle,
    );
  }

  static ChessButtonStyle of(BuildContext context) {
    return ChessButtonStyleScope.of(context).chessButtonStyle;
  }
}

class ChessButtonStyleScope extends InheritedWidget {
  const ChessButtonStyleScope({
    super.key,
    required this.chessButtonStyle,
    required super.child,
  });

  final ChessButtonStyle chessButtonStyle;

  static ChessButtonStyleScope of(BuildContext context) {
    final ChessButtonStyleScope? result =
        context.dependOnInheritedWidgetOfExactType<ChessButtonStyleScope>();
    assert(result != null, 'No ChessButtonStyleScope found in context');

    return result!;
  }

  @override
  bool updateShouldNotify(ChessButtonStyleScope oldWidget) {
    return oldWidget.chessButtonStyle != chessButtonStyle;
  }
}

extension ChessButtonCustomStyle on ButtonStyle {
  ButtonStyle copy(
    Color? background,
    Color? foreground,
    TextStyle? textStyle,
    bool isSizeByContent,
    EdgeInsetsGeometry? contentPadding,
    double? borderRadius,
    ButtonType typeButton,
    Color? borderColor,
  ) {
    final backgroundColor = background != null
        ? MaterialStateProperty.all(background)
        : this.backgroundColor;
    final foregroundColor = foreground == null
        ? this.foregroundColor
        : MaterialStateProperty.all(foreground);
    final customTextStyle = textStyle == null
        ? this.textStyle
        : MaterialStateProperty.all(textStyle);
    final padding = contentPadding == null
        ? this.padding
        : MaterialStateProperty.all(contentPadding);

    final shape = borderRadius == null
        ? this.shape
        : MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          );

    final resolvedSide = background != null || borderColor != null
        ? MaterialStateProperty.all(
            side?.resolve({})?.copyWith(color: borderColor ?? background),
          )
        : side;

    if (isSizeByContent) {
      return ButtonStyle(
        textStyle: customTextStyle,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        overlayColor: overlayColor,
        shadowColor: shadowColor,
        surfaceTintColor: surfaceTintColor,
        elevation: elevation,
        padding: padding,
        fixedSize: fixedSize,
        maximumSize: maximumSize,
        minimumSize: MaterialStateProperty.all(Size.zero),
        iconColor: iconColor,
        iconSize: iconSize,
        side: resolvedSide,
        shape: shape,
        mouseCursor: mouseCursor,
        visualDensity: visualDensity,
        tapTargetSize: tapTargetSize,
        animationDuration: animationDuration,
        enableFeedback: enableFeedback,
        alignment: alignment,
        splashFactory: splashFactory,
      );
    }

    return copyWith(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      textStyle: customTextStyle,
      padding: padding,
      side: resolvedSide,
      shape: shape,
    );
  }
}

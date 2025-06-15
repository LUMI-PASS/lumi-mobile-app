import 'package:flutter/material.dart';

class ChessDynamicSize {
  final BuildContext context;
  final BoxConstraints constraints;
  final double expandedHeight;

  ChessDynamicSize(
    this.context, {
    required this.constraints,
    required this.expandedHeight,
  });

  double padding({double? maxPadding, double? minPadding}) {
    double kMinPadding = minPadding ?? 24;
    double kMaxPadding = maxPadding ?? 48;

    double ratio = (kMaxPadding - kMinPadding) / (_minHeight - _maxHeight);

    double padding =
        ratio * (constraints.biggest.height - _minHeight) + kMaxPadding;

    return padding;
  }

  double fontSize({double? minTextSize, double? maxTextSize}) {
    double kMinTextSize = minTextSize ?? 24;
    double kMaxTextSize = maxTextSize ?? 32;

    double ratio = (kMinTextSize - kMaxTextSize) / (_minHeight - _maxHeight);

    double textSize =
        ratio * (constraints.biggest.height - _maxHeight) + kMinTextSize;

    return textSize;
  }

  double get _minHeight => MediaQuery.paddingOf(context).top + kToolbarHeight;

  double get _maxHeight => expandedHeight + kToolbarHeight;
}

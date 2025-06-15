import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/widgets.dart';

extension ChessThemeExtension on BuildContext {
  ChessTextTheme get textTheme => ChessTextTheme.of(this);
}

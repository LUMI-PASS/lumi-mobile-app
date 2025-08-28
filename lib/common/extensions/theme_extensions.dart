import 'package:flexobo/data/base_model/default_theme_colors.dart';
import 'package:flexobo/di/injection.dart';
import 'package:flutter/cupertino.dart';


extension ThemeContextExtensions on BuildContext {
  DefaultThemeColors get colors => getIt<DefaultThemeColors>();
}

import 'package:lumi_pass/data/base_model/default_theme_colors.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:flutter/cupertino.dart';


extension ThemeContextExtensions on BuildContext {
  DefaultThemeColors get colors => getIt<DefaultThemeColors>();
}

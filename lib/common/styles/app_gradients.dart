import 'package:flutter/material.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';

/// Brand gradients from the Figma design.
class AppGradients {
  AppGradients._();

  /// Primary button / gradient icon badge — left→right pink → purple.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.brandPink, AppColors.brandPurple],
  );

  /// Active bottom-nav chip / "Образование" category badge — indigo → blue.
  static const LinearGradient indigo = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF6F5ED0), Color(0xFF1326B1)],
  );

  /// Partner / provider tag — light green → deep green.
  static const LinearGradient green = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7FB846), Color(0xFF547F2A)],
  );
}

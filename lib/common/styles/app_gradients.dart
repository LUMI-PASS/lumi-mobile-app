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

  /// Frosted light control — hero back/share/heart buttons and the carousel
  /// dots pill. Top→bottom pale-lavender → off-white (Figma `#f2f4ff` →
  /// `#f8f8f8`). Reads as a raised light chip over the hero image.
  static const LinearGradient frostedControl = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF2F4FF), Color(0xFFF8F8F8)],
  );

  /// Partner / provider tag — light green → deep green.
  static const LinearGradient green = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7FB846), Color(0xFF547F2A)],
  );
}

import 'package:flutter/material.dart';

abstract final class AppColors {
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF15141A);

  static const brandPurple = Color(0xFFA752C7);
  static const brandPink = Color(0xFFFC6F95);
  static const onBrand = Color(0xFFFFFFFF);

  static const link = Color(0xFF5735FF);

  /// The muted indigo of inline text actions ("Добавить фото").
  static const lightPurple = Color(0xFF6F5ED0);
  static const error = Color(0xFFFF4B55);

  static const green = Color(0xFF2CBE88);
  static const tagGreen = Color(0xFF7FB846);
  static const warning = Color(0xFFF6B53D);

  static const inkMuted = Color(0xFFA5A6BB);
  static const inkChip = Color(0xFFEFEEF5);
  static const greeting = Color(0xFF717386);

  /// Coupon accent — the discount tile and the usage bar. Theme-invariant: it
  /// always carries dark ink on top.
  static const lime = Color(0xFFAFF26E);

  /// Neutral status pill (white label on grey). Theme-invariant by design.
  static const chipGrey = Color(0xFF4B4B55);

  // light
  static const lightScaffold = Color(0xFFF9F9FA);
  static const lightCanvas = Color(0xFFEFEEF5);
  static const lightControl = Color(0xFFF2F1F6);
  static const lightControlBorder = Color(0xFFE6E5EC);
  static const lightTextSecondary = Color(0xFF6E6D78);
  static const lightPlaceholder = Color(0xFFB9B8C2);
  static const lightBorder = Color(0xFFD5D7DA);
  static const lightDivider = Color(0xFFE5E7EA);

  // dark
  static const darkCanvas = Color(0xFF1D1C23);
  static const darkSurface = Color(0xFF202024);
  static const darkSurfaceRaised = Color(0xFF26252B);
  static const darkControl = Color(0xFF313039);
  static const darkControlBorder = Color(0xFF4C4C54);
  static const darkTextSecondary = Color(0xFFA5A6BB);
  static const darkPlaceholder = Color(0xFF4B4B55);
  static const darkBorder = Color(0xFF3D3D46);
  static const darkDivider = Color(0xFF2D2E33);
  static const textMuted = Color(0xFF85848C);
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Design tokens for the redesigned auth / onboarding flow.
///
/// Values come straight from the Figma variables (dark theme) and a derived
/// light theme. Both themes are always supported: [AppColors.of] resolves the
/// active set from the current platform brightness, so every auth screen looks
/// correct in light and dark mode without changing the rest of the app.
@immutable
class AppColors {
  const AppColors({
    required this.bg,
    required this.surface,
    required this.control,
    required this.controlBorder,
    required this.tabBar,
    required this.tabInactive,
    required this.textPrimary,
    required this.textSecondary,
    required this.textPlaceholder,
    required this.textMuted,
    required this.badgeBorder,
  });

  /// Scaffold background — Figma `Color/BG`.
  final Color bg;

  /// Cards / list items / unselected chips — Figma `Color/Shape`.
  final Color surface;

  /// Header icon buttons / avatar tiles — Figma `Color/Shape 2` (#313039).
  final Color control;

  /// Hairline border around [control] surfaces — Figma `#4C4C54`.
  final Color controlBorder;

  /// Bottom navigation bar background — Figma `#26252B`.
  final Color tabBar;

  /// Inactive bottom-nav icon chip — Figma `#4B4B55`.
  final Color tabInactive;

  /// Greeting label ("Привет,") — Figma `Primary/Dark Grey`.
  static const Color greeting = Color(0xFF717386);

  /// Primary text (headings, phone number). Figma `Primary/White`.
  final Color textPrimary;

  /// Secondary / subtitle text. Figma `Primary/Grey`.
  final Color textSecondary;

  /// Placeholder digits inside the phone / code fields. Figma `Color/Grey`.
  final Color textPlaceholder;

  /// Muted text (timer). Figma `Color/Text`.
  final Color textMuted;

  /// Border that cuts the little colored icon badges out of the background.
  final Color badgeBorder;

  // ── Brand palette (identical in both themes) ──────────────────────────────
  /// Gradient start — Figma button `from`.
  static const Color brandPink = Color(0xFFFC6F95);

  /// Gradient end / selected chip — Figma `Color/Pink`.
  static const Color brandPurple = Color(0xFFA752C7);

  /// Text on top of brand surfaces.
  static const Color onBrand = Color(0xFFFFFFFF);

  static const Color badgeBlue = Color(0xFF0F98FF); // Figma `Color/Blue`
  static const Color badgeGreen = Color(0xFF2CBE88); // Figma `Secondary/Green`
  static const Color badgePink = Color(0xFFA752C7); // Figma `Color/Pink`

  /// Partner / provider tag — Figma `Color/LightGreen`.
  static const Color green = Color(0xFF7FB846);

  /// Underlined "public offer" link — Figma `Color/Purple1`.
  static const Color link = Color(0xFF5735FF);

  /// Error text / invalid code — Figma `Secondary/Red`.
  static const Color error = Color(0xFFFF4B55);

  // ── Dark theme (the reference design) ─────────────────────────────────────
  static const AppColors dark = AppColors(
    bg: Color(0xFF15141A),
    surface: Color(0xFF202024),
    control: Color(0xFF313039),
    controlBorder: Color(0xFF4C4C54),
    tabBar: Color(0xFF26252B),
    tabInactive: Color(0xFF4B4B55),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFA5A6BB),
    textPlaceholder: Color(0xFF4B4B55),
    textMuted: Color(0xFF85848C),
    badgeBorder: Color(0xFF15141A),
  );

  // ── Light theme (derived to mirror the dark reference) ────────────────────
  static const AppColors light = AppColors(
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFF2F1F6),
    control: Color(0xFFF2F1F6),
    controlBorder: Color(0xFFE6E5EC),
    tabBar: Color(0xFFFFFFFF),
    tabInactive: Color(0xFFF2F1F6),
    textPrimary: Color(0xFF15141A),
    textSecondary: Color(0xFF6E6D78),
    textPlaceholder: Color(0xFFB9B8C2),
    textMuted: Color(0xFF85848C),
    badgeBorder: Color(0xFFFFFFFF),
  );

  bool get isDark => bg == dark.bg;

  /// Resolve the active token set from the current platform brightness.
  static AppColors of(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark
          ? dark
          : light;

  /// Status-bar / navigation-bar overlay style matching this theme.
  SystemUiOverlayStyle get overlayStyle => SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      );
}

extension AppColorsX on BuildContext {
  /// Brightness-aware auth design tokens. Use inside the auth/onboarding flow.
  AppColors get appColors => AppColors.of(this);
}

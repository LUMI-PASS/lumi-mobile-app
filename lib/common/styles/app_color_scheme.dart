import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';

class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.brightness,
    required this.primary,
    required this.onPrimary,
    required this.scaffoldBg,
    required this.canvas,
    required this.surface,
    required this.control,
    required this.controlBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textPlaceholder,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.disabled,
    required this.error,
    required this.success,
    required this.info,
    required this.badgeBorder,
  });

  /// Which table this is. Drives [isDark] and [overlayStyle].
  final Brightness brightness;

  // ── Brand ─────────────────────────────────────────────────────────────────
  /// Primary actions, active states, selected chips.
  final Color primary;

  /// Content on top of [primary].
  final Color onPrimary;

  // ── Surfaces ──────────────────────────────────────────────────────────────
  /// Scaffold background.
  final Color scaffoldBg;

  /// Tinted backdrop for screens built out of frosted cards (booking), where
  /// [scaffoldBg] would leave the pale cards with no contrast.
  final Color canvas;

  /// Cards, list items, sheets, unselected chips.
  final Color surface;

  /// Header icon buttons / avatar tiles.
  final Color control;

  /// Hairline around a [control].
  final Color controlBorder;

  // ── Text ──────────────────────────────────────────────────────────────────
  /// Headings and body copy. Absorbs the old `black`, `label`, `display` and
  /// `primary01`, which were four barely-distinguishable dark inks.
  final Color textPrimary;

  /// Subtitles and captions. Absorbs the old `title`.
  final Color textSecondary;

  /// Empty-field placeholders.
  final Color textPlaceholder;

  /// Timers and de-emphasised metadata.
  final Color textMuted;

  // ── Lines ─────────────────────────────────────────────────────────────────
  /// Input and card outlines. The old `grey`.
  final Color border;

  /// Row separator inside a card or list.
  final Color divider;

  /// Fill of a disabled button.
  final Color disabled;

  // ── Status ────────────────────────────────────────────────────────────────
  /// Errors, invalid input, destructive actions. Absorbs the old `primary2`,
  /// `errorColor` and `warningDark`.
  final Color error;

  /// Confirmed / complete. The old `greenHeadline`.
  final Color success;

  /// Informational accent. The old `differ` (which was a raw `Colors.blue`).
  final Color info;

  /// Border that cuts the little coloured icon badges out of the background.
  final Color badgeBorder;

  static const light = AppColorScheme(
    brightness: Brightness.light,
    primary: AppColors.brandPurple,
    onPrimary: AppColors.onBrand,
    scaffoldBg: AppColors.lightScaffold,
    canvas: AppColors.lightCanvas,
    surface: AppColors.white,
    control: AppColors.lightControl,
    controlBorder: AppColors.lightControlBorder,
    textPrimary: AppColors.ink,
    textSecondary: AppColors.lightTextSecondary,
    textPlaceholder: AppColors.lightPlaceholder,
    textMuted: AppColors.textMuted,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    disabled: AppColors.lightBorder,
    error: AppColors.error,
    success: AppColors.green,
    info: AppColors.blue,
    badgeBorder: AppColors.white,
  );

  static const dark = AppColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.brandPurple,
    onPrimary: AppColors.onBrand,
    scaffoldBg: AppColors.ink,
    canvas: AppColors.darkCanvas,
    surface: AppColors.darkSurface,
    control: AppColors.darkControl,
    controlBorder: AppColors.darkControlBorder,
    textPrimary: AppColors.white,
    textSecondary: AppColors.darkTextSecondary,
    textPlaceholder: AppColors.darkPlaceholder,
    textMuted: AppColors.textMuted,
    border: AppColors.darkBorder,
    divider: AppColors.darkDivider,
    disabled: AppColors.darkControl,
    error: AppColors.error,
    success: AppColors.green,
    info: AppColors.blue,
    badgeBorder: AppColors.ink,
  );

  bool get isDark => brightness == Brightness.dark;

  /// Status-bar / navigation-bar overlay style matching this theme.
  SystemUiOverlayStyle get overlayStyle => SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: scaffoldBg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      );

  @override
  AppColorScheme copyWith({
    Brightness? brightness,
    Color? primary,
    Color? onPrimary,
    Color? scaffoldBg,
    Color? canvas,
    Color? surface,
    Color? control,
    Color? controlBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textPlaceholder,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? disabled,
    Color? error,
    Color? success,
    Color? info,
    Color? badgeBorder,
  }) {
    return AppColorScheme(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      control: control ?? this.control,
      controlBorder: controlBorder ?? this.controlBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      disabled: disabled ?? this.disabled,
      error: error ?? this.error,
      success: success ?? this.success,
      info: info ?? this.info,
      badgeBorder: badgeBorder ?? this.badgeBorder,
    );
  }

  @override
  AppColorScheme lerp(AppColorScheme? other, double t) {
    if (other is! AppColorScheme) return this;
    return AppColorScheme(
      brightness: t < 0.5 ? brightness : other.brightness,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      control: Color.lerp(control, other.control, t)!,
      controlBorder: Color.lerp(controlBorder, other.controlBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
      info: Color.lerp(info, other.info, t)!,
      badgeBorder: Color.lerp(badgeBorder, other.badgeBorder, t)!,
    );
  }
}

extension AppColorSchemeX on BuildContext {
  /// The active colour roles. The single colour accessor in the app — the old
  /// `context.colors` and the injectable `DefaultThemeColors` both folded
  /// into this.
  AppColorScheme get colors =>
      Theme.of(this).extension<AppColorScheme>() ?? AppColorScheme.light;
}

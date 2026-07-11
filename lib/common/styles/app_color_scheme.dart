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
    required this.pageBg,
    required this.surface,
    required this.bottomBar,
    required this.progressTrack,
    required this.control,
    required this.controlBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textSection,
    required this.textPlaceholder,
    required this.textMuted,
    required this.border,
    required this.divider,
    required this.disabled,
    required this.error,
    required this.success,
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

  /// Backdrop for card-on-canvas screens (coupons). Tinted like [canvas] in
  /// light; the deepest ink in dark, so a raised [surface] card reads against
  /// it — [canvas]'s dark value sits too close to [surface] to separate.
  final Color pageBg;

  /// Cards, list items, sheets, unselected chips.
  final Color surface;

  /// Sticky bottom action bars — one step above [surface] in dark so the bar
  /// lifts off the page.
  final Color bottomBar;

  /// Unfilled part of a progress bar sitting on a card.
  final Color progressTrack;

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

  /// Section headers above a group of cards ("Купоны", "Как это работает").
  /// Recedes to grey in light, but goes full white in dark.
  final Color textSection;

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

  /// Border that cuts the little coloured icon badges out of the background.
  final Color badgeBorder;

  static const light = AppColorScheme(
    brightness: Brightness.light,
    primary: AppColors.brandPurple,
    onPrimary: AppColors.onBrand,
    scaffoldBg: AppColors.lightScaffold,
    canvas: AppColors.lightCanvas,
    pageBg: AppColors.lightCanvas,
    surface: AppColors.white,
    bottomBar: AppColors.white,
    progressTrack: AppColors.inkChip,
    control: AppColors.lightControl,
    controlBorder: AppColors.lightControlBorder,
    textPrimary: AppColors.ink,
    textSecondary: AppColors.lightTextSecondary,
    textSection: AppColors.inkMuted,
    textPlaceholder: AppColors.lightPlaceholder,
    textMuted: AppColors.textMuted,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    disabled: AppColors.lightBorder,
    error: AppColors.error,
    success: AppColors.green,
    badgeBorder: AppColors.white,
  );

  static const dark = AppColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.brandPurple,
    onPrimary: AppColors.onBrand,
    scaffoldBg: AppColors.ink,
    canvas: AppColors.darkCanvas,
    pageBg: AppColors.ink,
    surface: AppColors.darkSurface,
    bottomBar: AppColors.darkSurfaceRaised,
    progressTrack: AppColors.chipGrey,
    control: AppColors.darkControl,
    controlBorder: AppColors.darkControlBorder,
    textPrimary: AppColors.white,
    textSecondary: AppColors.darkTextSecondary,
    textSection: AppColors.white,
    textPlaceholder: AppColors.darkPlaceholder,
    textMuted: AppColors.textMuted,
    border: AppColors.darkBorder,
    divider: AppColors.darkDivider,
    disabled: AppColors.darkControl,
    error: AppColors.error,
    success: AppColors.green,
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
    Color? pageBg,
    Color? surface,
    Color? bottomBar,
    Color? progressTrack,
    Color? control,
    Color? controlBorder,
    Color? textPrimary,
    Color? textSecondary,
    Color? textSection,
    Color? textPlaceholder,
    Color? textMuted,
    Color? border,
    Color? divider,
    Color? disabled,
    Color? error,
    Color? success,
    Color? badgeBorder,
  }) {
    return AppColorScheme(
      brightness: brightness ?? this.brightness,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      canvas: canvas ?? this.canvas,
      pageBg: pageBg ?? this.pageBg,
      surface: surface ?? this.surface,
      bottomBar: bottomBar ?? this.bottomBar,
      progressTrack: progressTrack ?? this.progressTrack,
      control: control ?? this.control,
      controlBorder: controlBorder ?? this.controlBorder,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textSection: textSection ?? this.textSection,
      textPlaceholder: textPlaceholder ?? this.textPlaceholder,
      textMuted: textMuted ?? this.textMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      disabled: disabled ?? this.disabled,
      error: error ?? this.error,
      success: success ?? this.success,
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
      pageBg: Color.lerp(pageBg, other.pageBg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      bottomBar: Color.lerp(bottomBar, other.bottomBar, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      control: Color.lerp(control, other.control, t)!,
      controlBorder: Color.lerp(controlBorder, other.controlBorder, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textSection: Color.lerp(textSection, other.textSection, t)!,
      textPlaceholder: Color.lerp(textPlaceholder, other.textPlaceholder, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      error: Color.lerp(error, other.error, t)!,
      success: Color.lerp(success, other.success, t)!,
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

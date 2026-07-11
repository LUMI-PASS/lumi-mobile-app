/// `context.colors` used to resolve the injectable `DefaultThemeColors`, a
/// light-only bag of paints. It now resolves [AppColorScheme] — the same
/// accessor, but theme-aware.
///
/// Kept as a re-export so existing `theme_extensions.dart` imports keep
/// working. New code should import `common/styles/app_color_scheme.dart`
/// directly.
export 'package:lumi_pass/common/styles/app_color_scheme.dart';

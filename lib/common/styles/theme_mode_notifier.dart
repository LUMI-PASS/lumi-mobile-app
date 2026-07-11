import 'package:flutter/material.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';

/// User-selected theme override for the redesigned (`context.colors`)
/// screens. Overrides `MediaQuery.platformBrightness` at the app root, so every
/// screen built on the design system follows it. `system` defers to the OS.
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.system);

ThemeMode _parse(String? v) {
  switch (v) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
}

String _serialize(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.light:
      return 'light';
    case ThemeMode.system:
      return 'system';
  }
}

/// Load the persisted preference into the notifier. Call once after DI is up.
void initThemeMode() {
  try {
    themeModeNotifier.value = _parse(getIt<Storage>().themeMode.call());
  } catch (_) {}
}

/// Update + persist the theme override.
void setThemeMode(ThemeMode mode) {
  themeModeNotifier.value = mode;
  try {
    getIt<Storage>().themeMode.set(_serialize(mode));
  } catch (_) {}
}

/// Resolve the brightness the app should render at for [mode], given the OS one.
Brightness resolveBrightness(ThemeMode mode, Brightness platform) {
  switch (mode) {
    case ThemeMode.dark:
      return Brightness.dark;
    case ThemeMode.light:
      return Brightness.light;
    case ThemeMode.system:
      return platform;
  }
}

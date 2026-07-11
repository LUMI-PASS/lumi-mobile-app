import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Typography for the redesigned auth flow — Figma uses **SF Pro Rounded**.
///
/// The family renders natively on iOS; on other platforms it falls back to the
/// app's bundled `Onest`. Drop `SF-Pro-Rounded.*` into `assets/fonts` and
/// declare it in `pubspec.yaml` to get a pixel match everywhere.
class AppText {
  AppText._();

  static const String family = 'SF Pro Rounded';
  static const List<String> _fallback = ['Onest'];

  static TextStyle _s(
    double size,
    FontWeight weight, {
    double height = 1.4,
    double letterSpacing = 0,
  }) =>
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: _fallback,
        fontSize: size.sp,
        fontWeight: weight,
        height: height,
        letterSpacing: letterSpacing,
      );

  // ── Figma named text styles ───────────────────────────────────────────────
  /// B1 / Semibold / 20 — large screen headings.
  static TextStyle get heading20 => _s(20, FontWeight.w700);

  /// B2 / Bold / 18 — section titles ("Все категории").
  static TextStyle get bold18 => _s(18, FontWeight.w700);

  /// B3 / Semibold / 16 — card titles, prices.
  static TextStyle get semibold16 => _s(16, FontWeight.w600);

  /// B3 / Medium / 16 — buttons, list labels.
  static TextStyle get medium16 => _s(16, FontWeight.w500);

  /// B3 / Regular / 16 — text-field values and placeholders.
  static TextStyle get regular16 => _s(16, FontWeight.w400);

  /// B4 / Regular / 14 — subtitles / descriptions.
  static TextStyle get regular14 => _s(14, FontWeight.w400);

  /// B4 / Semibold / 14 — card prices, emphasised subtitle text.
  static TextStyle get semibold14 => _s(14, FontWeight.w600);

  /// B4 / Medium / 14 — medium body / links.
  static TextStyle get medium14 => _s(14, FontWeight.w500);

  /// B5 / Regular / 13 — greeting label, tab labels.
  static TextStyle get regular13 => _s(13, FontWeight.w400);

  /// B5 / Medium / 13 — category labels.
  static TextStyle get medium13 => _s(13, FontWeight.w500);

  /// B6 / Regular / 12 — addresses, agreement text.
  static TextStyle get regular12 => _s(12, FontWeight.w400);

  /// B6 / Medium / 12 — subtitles, values in list rows.
  static TextStyle get medium12 => _s(12, FontWeight.w500);

  /// B6 / Semibold / 12 — price chips, small emphasised labels.
  static TextStyle get semibold12 => _s(12, FontWeight.w600);

  /// B7 / Medium / 10 — pill badges (category / provider tags).
  static TextStyle get medium10 => _s(10, FontWeight.w500);

  // ── Larger display styles used by the auth screens ────────────────────────
  /// Section title ("Авторизация" / "Подтверждение").
  static TextStyle get title24 =>
      _s(24, FontWeight.w700, height: 1.1, letterSpacing: -0.5);

  /// Phone number entry.
  static TextStyle get phone32 =>
      _s(32, FontWeight.w700, height: 1.1, letterSpacing: -0.5);

  /// OTP code display.
  static TextStyle get code56 =>
      _s(56, FontWeight.w700, height: 1.1, letterSpacing: 1);
}

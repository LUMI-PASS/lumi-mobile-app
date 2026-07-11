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

  /// The oversized "01 / 02 / 03" watermark on the coupon how-it-works cards —
  /// a grey that fades out downwards. Painted through the glyphs with a
  /// `ShaderMask`, so it needs opaque→transparent stops, not a flat tint.
  static final LinearGradient stepNumeral = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.inkMuted.withValues(alpha: 0.38),
      AppColors.inkMuted.withValues(alpha: 0.06),
    ],
  );

  /// Purple bloom straddling the top edge of the ticket receipt stub (Figma
  /// `Ellipse 1269`) — a wide, heavily blurred ellipse that tints the branded
  /// half of the ticket and fades out before it reaches the ticket number.
  static const RadialGradient ticketStubGlow = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.1,
    colors: [Color(0x8FA752C7), Color(0x00A752C7)],
  );

  /// Soft green wash bleeding in from behind the coupon banner's ticket art
  /// (Figma `star`) — sits on top of [frostedControl], fading to transparent
  /// before it reaches the copy.
  static const RadialGradient greenGlow = RadialGradient(
    center: Alignment.center,
    radius: 0.65,
    colors: [Color(0x8FB4E882), Color(0x00B4E882)],
  );
}

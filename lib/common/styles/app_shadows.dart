import 'package:flutter/material.dart';

/// Elevation tokens from the Figma design — soft, low-contrast drop shadows
/// that lift a surface off what sits behind it.
///
/// Reference these instead of inlining a `BoxShadow` so raised surfaces read
/// the same across screens. Shadows are tinted with [AppColors.ink] rather
/// than pure black so they stay warm on the light background.
class AppShadows {
  AppShadows._();

  /// Content card resting on the page background (the class-detail cards).
  /// Two layers: a wide ambient halo plus a tight contact shadow.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0F15141A),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A15141A),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Chip floating over imagery — hero back/share/heart controls and the
  /// carousel dots pill. Deeper than [card]: it has to hold up over a photo.
  static const List<BoxShadow> control = [
    BoxShadow(
      color: Color(0x2915141A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Bar pinned to the bottom of the screen — casts upward so scrolling
  /// content passes beneath it.
  static const List<BoxShadow> bottomBar = [
    BoxShadow(
      color: Color(0x1415141A),
      blurRadius: 20,
      offset: Offset(0, -6),
    ),
  ];
}

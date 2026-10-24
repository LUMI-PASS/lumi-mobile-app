import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// A flag across a card's top-right corner: a slim band pinned at 30°.
///
/// Drawn as a band whose ends deliberately overshoot the card and are cut off
/// by the clip around it — the card must clip its content to its rounded
/// inside and put this in a [Stack] over it — which is what makes it read as a
/// ribbon wrapped over the corner rather than a label sitting on top of one.
///
/// 30° rather than 45°: closer to level, so the word reads without tilting
/// your head. The band is cut close around the word — a small corner, a
/// legible label — so it covers as little of the photo as it can.
class CornerRibbon extends StatelessWidget {
  const CornerRibbon({
    super.key,
    required this.label,
    this.gradient = AppGradients.brand,
  });

  final String label;
  final Gradient gradient;

  /// The tilt, measured down from the card's top edge.
  static const double _angle = math.pi / 6;

  /// Band length. Long enough that both ends clear the corner once it is
  /// turned — see [_run].
  static const double _length = 124;

  /// Barely more than the text: the word fills the band edge to edge.
  static const double _thickness = 15;

  /// How far along the TOP edge the band's centre line meets it, measured in
  /// from the corner. It meets the right edge `_run · tan30° ≈ 36` down, so
  /// the visible chord is ≈ 72 long against a band of [_length]: both ends
  /// overshoot the edges and get clipped.
  static const double _run = 62;

  @override
  Widget build(BuildContext context) {
    // Rotation does not move a box's centre, so the band's centre is placed
    // on the middle of that chord — half the run in from the right, half the
    // drop down from the top — and the box is offset from it by half its own
    // size.
    final drop = _run * math.tan(_angle);
    return Positioned(
      top: drop / 2 - _thickness / 2,
      right: _run / 2 - _length / 2,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: _angle,
          child: Container(
            width: _length,
            height: _thickness,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1.5),
                ),
              ],
            ),
            // The padding keeps the word clear of the ends the corner cuts
            // off; a word that will not fit shrinks instead of losing its last
            // letter to the card's edge.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  // A fixed diagonal across a corner: a larger accessibility
                  // step would push the word past its ends.
                  textScaler: TextScaler.noScaling,
                  style: AppText.semibold12.copyWith(
                    fontSize: 10.5,
                    color: AppColors.onBrand,
                    letterSpacing: 0.2,
                    height: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

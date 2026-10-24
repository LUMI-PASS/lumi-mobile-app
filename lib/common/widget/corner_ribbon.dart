import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';

/// A flag across a card's top-right corner: a band pinned at 45°.
///
/// Drawn as a band whose ends deliberately overshoot the card and are cut off
/// by the clip around it — the card must clip its content to its rounded
/// inside and put this in a [Stack] over it — which is what makes it read as a
/// ribbon wrapped over the corner rather than a label sitting on top of one.
class CornerRibbon extends StatelessWidget {
  const CornerRibbon({
    super.key,
    required this.label,
    this.gradient = AppGradients.brand,
  });

  final String label;
  final Gradient gradient;

  /// Band length. Long enough that both ends clear the corner once it is
  /// turned — see [_offset].
  static const double _length = 120;

  static const double _thickness = 24;

  /// How far from the corner the band's centre sits, along both edges.
  ///
  /// Rotation does not move a box's centre, so the band's centre is simply
  /// placed on the corner's diagonal: its ends then land at
  /// ±`_length / 2 · cos45° ≈ ±42` from that centre. Keeping [_offset] under
  /// that is what makes them overshoot the edges and get clipped.
  static const double _offset = 32;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Both measured to put the centre at (corner − _offset, _offset): the
      // top is the centre less half the thickness, and the negative right
      // hangs the box over the edge by the same half-length the rotation then
      // tucks back in.
      top: _offset - _thickness / 2,
      right: _offset - _length / 2,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: math.pi / 4,
          child: Container(
            width: _length,
            height: _thickness,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: gradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // The padding keeps the word clear of the ends the corner cuts
            // off; a word that will not fit shrinks instead of losing its last
            // letter to the card's edge.
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  // A fixed diagonal across a corner: a larger accessibility
                  // step would push the word past its ends.
                  textScaler: TextScaler.noScaling,
                  style: AppText.semibold14.copyWith(
                    color: AppColors.onBrand,
                    letterSpacing: 0.3,
                    height: 1.1,
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

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';

/// The "Obunaga kiradi" container is a GOLD fill carrying the feed's ordinary
/// cards, which paint their text in `textPrimary`. That pairing is chosen, not
/// inherited — every other row sits on the scaffold — so the contrast is
/// asserted here. A gold nudged a few steps darker would leave dark ink on a
/// mid-tone with nothing to warn anyone.
///
/// The container has NO border, so the fill is the only thing that draws it.
/// In light that fill is close to the scaffold in luminance and separates by
/// HUE instead — which is the intended look, but it means a "is it visible"
/// check cannot be a contrast ratio. It is a check that the colour is still
/// recognisably yellow and still differs from the page, which is what would
/// actually break if someone lightened it again.
void main() {
  double ratio(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    return la > lb ? (la + 0.05) / (lb + 0.05) : (lb + 0.05) / (la + 0.05);
  }

  for (final (name, scheme) in [
    ('light', AppColorScheme.light),
    ('dark', AppColorScheme.dark),
  ]) {
    group('the coin band in $name', () {
      test('carries card text at better than 4.5:1', () {
        // The cards inside the container use `textPrimary` for the title and
        // `textSecondary` for the address beneath it. Both sit on the band.
        expect(
          ratio(scheme.coinBand, scheme.textPrimary),
          greaterThan(4.5),
          reason: 'card titles on the band',
        );
        expect(
          ratio(scheme.coinBand, scheme.textSecondary),
          greaterThan(3.0),
          reason: 'the address line, which is secondary text',
        );
      });

      test('is still recognisably yellow', () {
        // Yellow is blue held down while red and green stay up. Lighten the
        // fill by raising blue and the block stops being gold and becomes an
        // off-white rectangle for no reason — which is the one way this can
        // be "lightened" into meaninglessness.
        final band = scheme.coinBand;
        // Proportional, not an absolute gap: the dark value is a deep brown,
        // where every channel is small and so is the space between them. A
        // fixed margin that suited the pale light gold would reject it for
        // being dark rather than for being the wrong hue.
        final brightest = band.r > band.g ? band.r : band.g;
        expect(
          band.b,
          lessThan(brightest * 0.85),
          reason: 'blue has caught up with red/green; the gold is gone',
        );
      });

      test('still differs from the page behind it', () {
        // With no border the fill is the ONLY thing separating the container
        // from the feed, so it has to differ from the scaffold somewhere —
        // by channel, since in light the two are close in luminance.
        final band = scheme.coinBand;
        final page = scheme.scaffoldBg;
        final delta = [
          (band.r - page.r).abs(),
          (band.g - page.g).abs(),
          (band.b - page.b).abs(),
        ].reduce((a, b) => a > b ? a : b);
        expect(
          delta,
          greaterThan(0.08),
          reason: 'the band would disappear into the scaffold',
        );
      });
    });
  }
}

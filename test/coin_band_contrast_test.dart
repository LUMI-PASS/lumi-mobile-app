import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';

/// The "Obunaga kiradi" container is a tinted fill — the brand violet, pale
/// in light and deep in dark — whose header paints in `textPrimary`. That
/// pairing is chosen, not inherited (every other row sits on the scaffold),
/// so the contrast is asserted here.
///
/// The container has NO border, so the fill is the only thing that draws it.
/// In light that fill is close to the scaffold in luminance and separates by
/// HUE instead — the intended look, but it means "is it visible" cannot be a
/// contrast ratio. It is a check that the colour is still the violet and
/// still differs from the page.
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

      test('is the brand violet, not a neutral or another hue', () {
        // ONE hue in both themes, pale in light and deep in dark: blue leads
        // and green trails. Pull the channels together and the panel becomes
        // one more grey surface; swap their order and light and dark stop
        // looking like the same section — which is how it once ended up gold
        // in one theme and purple in the other.
        final band = scheme.coinBand;
        expect(band.b, greaterThan(band.r));
        expect(band.g, lessThan(band.r));
        expect(band.b - band.g, greaterThan(0.08));
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

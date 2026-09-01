import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/common/widget/distance_label.dart';

/// The distance line on an activity/course/centre card.
///
/// Two things are being pinned here. The arithmetic — a card that says "1.2 km"
/// has to be measuring, not guessing. And the silence: the card shows a number
/// only when there is an honest one, because a distance from the Tashkent
/// fallback, or to a centre with no coordinates, reads exactly as authoritative
/// as a real one.
void main() {
  // Amir Temur square and a point ~2.2 km north-east of it.
  const here = UserLocation.precise(41.3111, 69.2797);

  setUp(() {
    EasyLocalization.logger.enableLevels = const [];
    currentUserLocation.value = null;
  });

  tearDown(() => currentUserLocation.value = null);

  group('metersTo', () {
    test('measures a real separation', () {
      // 0.01° of latitude is ~1111 m anywhere on Earth.
      final metres = here.metersTo(41.3211, 69.2797);
      expect(metres, isNotNull);
      expect(metres!, closeTo(1111, 5));
    });

    test('is zero to itself', () {
      expect(here.metersTo(here.lat, here.lng), closeTo(0, 0.001));
    });

    test('is symmetric', () {
      const there = UserLocation.precise(41.35, 69.31);
      expect(
        here.metersTo(there.lat, there.lng),
        closeTo(there.metersTo(here.lat, here.lng)!, 0.001),
      );
    });

    test('refuses coordinates it cannot trust', () {
      // Null, half-set, out of range, and the unset-pair-coerced-to-numbers
      // 0,0 — each of which would otherwise produce a confident wrong number.
      expect(here.metersTo(null, null), isNull);
      expect(here.metersTo(41.3, null), isNull);
      expect(here.metersTo(0, 0), isNull);
      expect(here.metersTo(91, 69.3), isNull);
      expect(here.metersTo(41.3, 181), isNull);
    });
  });

  group('isUsableCoords', () {
    test('accepts a real Tashkent pair', () {
      expect(isUsableCoords(41.3111, 69.2797), isTrue);
    });

    test('rejects null, 0/0 and out-of-range', () {
      expect(isUsableCoords(null, 69.2797), isFalse);
      expect(isUsableCoords(41.3111, null), isFalse);
      expect(isUsableCoords(0, 0), isFalse);
      expect(isUsableCoords(-91, 0.1), isFalse);
      expect(isUsableCoords(0.1, 181), isFalse);
      expect(isUsableCoords(double.nan, 69.2797), isFalse);
    });
  });

  group('parts', () {
    // Asserted before localisation: which unit the distance falls into and the
    // figure printed in it. The wording is the translators' business.
    String unitOf(double metres) => DistanceLabel.parts(metres).$1;
    String figureOf(double metres) => DistanceLabel.parts(metres).$2;

    test('rounds metres to the nearest ten', () {
      expect(figureOf(317), '320');
      expect(figureOf(94), '90');
    });

    test('switches to kilometres just under one', () {
      expect(unitOf(940), 'distance_m');
      expect(unitOf(960), 'distance_km');
    });

    test('keeps one decimal below ten kilometres', () {
      expect(figureOf(1240), '1.2');
      expect(figureOf(9440), '9.4');
    });

    test('drops the decimal past ten kilometres', () {
      expect(figureOf(12400), '12');
      expect(figureOf(12600), '13');
    });
  });

  group('labelFor', () {
    test('says nothing before the location is known', () {
      expect(DistanceLabel.labelFor(41.35, 69.31), isNull);
    });

    test('says nothing from the Tashkent fallback', () {
      // The fallback orders a list fine, but it is not where the user is —
      // quoting a distance from it would be a confident lie.
      currentUserLocation.value = kTashkentCentre;
      expect(DistanceLabel.labelFor(41.35, 69.31), isNull);
    });

    test('says nothing for a centre with no coordinates', () {
      currentUserLocation.value = here;
      expect(DistanceLabel.labelFor(null, null), isNull);
      expect(DistanceLabel.labelFor(0, 0), isNull);
    });

    test('answers once there is a precise fix and real coordinates', () {
      currentUserLocation.value = here;
      expect(DistanceLabel.labelFor(41.3211, 69.2797), isNotNull);
    });
  });
}

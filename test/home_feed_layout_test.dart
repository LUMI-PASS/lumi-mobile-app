import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/home_feed_layout.dart';

/// The longest unbroken run of near cards in [slots].
int _longestRun(List<HomeFeedSlot> slots) {
  var longest = 0;
  var run = 0;
  for (final slot in slots) {
    run = slot is HomeNearSlot ? run + 1 : 0;
    if (run > longest) longest = run;
  }
  return longest;
}

List<int> _nearIndexes(List<HomeFeedSlot> slots) =>
    [for (final s in slots) if (s is HomeNearSlot) s.index];

List<HomeInsert> _dealt(List<HomeFeedSlot> slots) =>
    [for (final s in slots) if (s is HomeInsertSlot) s.insert];

void main() {
  group('layoutNearYou', () {
    test('no run is longer than three while inserts remain', () {
      final slots = layoutNearYou(60, HomeInsert.values);
      final lastInsert = slots.lastIndexWhere((s) => s is HomeInsertSlot);
      expect(_longestRun(slots.sublist(0, lastInsert)), lessThanOrEqualTo(3));
    });

    test('keeps every card, once, in order', () {
      final slots = layoutNearYou(23, HomeInsert.values);
      expect(_nearIndexes(slots), List.generate(23, (i) => i));
    });

    test('deals each insert once, in order, then only cards', () {
      const available = [HomeInsert.inviteBanner, HomeInsert.trialBand];
      final slots = layoutNearYou(40, available);
      expect(_dealt(slots), available);
      expect(_nearIndexes(slots), List.generate(40, (i) => i));
    });

    test('ends on a card, never on an insert', () {
      for (var count = 1; count <= 30; count++) {
        final slots = layoutNearYou(count, HomeInsert.values);
        expect(slots.last, isA<HomeNearSlot>(), reason: '$count');
      }
    });

    test('a later page only appends — nothing above it moves', () {
      final before = layoutNearYou(10, HomeInsert.values);
      final after = layoutNearYou(20, HomeInsert.values);
      for (var i = 0; i < before.length; i++) {
        final a = before[i];
        final b = after[i];
        expect(a.runtimeType, b.runtimeType, reason: 'slot $i');
        if (a is HomeInsertSlot && b is HomeInsertSlot) {
          expect(a.insert, b.insert, reason: 'slot $i');
        }
      }
    });

    test('numbers a repeated insert, so each one is its own row', () {
      const shelf = HomeInsert.unclaimedShelf;
      final slots = layoutNearYou(40, const [
        shelf,
        HomeInsert.trialBand,
        shelf,
        shelf,
      ]);
      final ordinals = [
        for (final s in slots)
          if (s is HomeInsertSlot) (s.insert, s.ordinal),
      ];
      expect(ordinals, [
        (shelf, 0),
        (HomeInsert.trialBand, 0),
        (shelf, 1),
        (shelf, 2),
      ]);
    });

    test('with nothing to deal it is simply the cards', () {
      final slots = layoutNearYou(7, const []);
      expect(slots, hasLength(7));
      expect(slots.every((s) => s is HomeNearSlot), isTrue);
    });
  });

  group('weaveShelves', () {
    const shelf = HomeInsert.unclaimedShelf;
    const a = HomeInsert.inviteBanner;
    const b = HomeInsert.categoryTiles;
    const c = HomeInsert.trialBand;

    test('one after the first insert, then after every second', () {
      expect(weaveShelves(const [a, b, c], 2), [a, shelf, b, c, shelf]);
    });

    test('rows left over follow at the end, none dropped', () {
      expect(weaveShelves(const [a], 3), [a, shelf, shelf, shelf]);
      expect(weaveShelves(const [], 2), [shelf, shelf]);
    });

    test('no rows leaves the inserts as they were', () {
      expect(weaveShelves(const [a, b, c], 0), [a, b, c]);
    });
  });
}

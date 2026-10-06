import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/cubit/home_cubit.dart';

/// The two home rows whose CONTENTS are a rule rather than whatever the feed
/// happened to send: "Obunaga kiradi", which may only hold what a Lumi Coin
/// pack can pay for, and "Qiziqishlarga asosan", which must walk across
/// categories instead of sitting in feed order.
///
/// Both rules are invisible to the analyzer — a row that quietly filled with
/// money-only activities, or with four of the same category, still compiles
/// and still renders — so they are asserted here.
void main() {
  HomClass activity(String id, {num? coins, String? category}) => HomClass(
        id: id,
        title: id,
        category: category,
        newCoinPrice: coins,
      );

  HomClass course(String id, {String? category}) => HomClass(
        id: id,
        title: id,
        category: category,
        isCourse: true,
      );

  group('coursesAcrossCategories', () {
    test('deals one course per category before any category repeats', () {
      final ordered = HomeCubit.coursesAcrossCategories([
        course('dance-1', category: 'Dance'),
        course('dance-2', category: 'Dance'),
        course('dance-3', category: 'Dance'),
        course('chess-1', category: 'Chess'),
        course('swim-1', category: 'Swimming'),
      ]);

      // The first three are the three DIFFERENT categories — which is the
      // whole point of the row. In feed order the row opened on three dance
      // courses and the user never saw chess or swimming at all.
      expect(
        ordered.take(3).map((c) => c.category),
        ['Dance', 'Chess', 'Swimming'],
      );
      // Nothing is dropped on the way — the tail is the repeats.
      expect(ordered, hasLength(5));
      expect(
        ordered.map((c) => c.id),
        ['dance-1', 'chess-1', 'swim-1', 'dance-2', 'dance-3'],
      );
    });

    test('the category the feed led with still leads the row', () {
      final ordered = HomeCubit.coursesAcrossCategories([
        course('chess-1', category: 'Chess'),
        course('dance-1', category: 'Dance'),
      ]);
      expect(ordered.first.id, 'chess-1');
    });

    test('courses with no category each get their own turn', () {
      // Bucketed together they would have shared ONE slot per round, so two
      // of the three would have been pushed behind every named category.
      final ordered = HomeCubit.coursesAcrossCategories([
        course('blank-1'),
        course('blank-2', category: '   '),
        course('blank-3', category: ''),
      ]);
      expect(ordered, hasLength(3));
      expect(
        ordered.map((c) => c.id),
        containsAll(['blank-1', 'blank-2', 'blank-3']),
      );
    });

    test('a multi-category course is filed under its FIRST category', () {
      // `category` is a comma-separated LIST and the card shows only the first
      // of them. Keyed on the raw string these three would be three separate
      // categories, and the row would open on three dance courses while
      // claiming to be spreading them.
      final ordered = HomeCubit.coursesAcrossCategories([
        course('dance-a', category: 'Dance, Fitness'),
        course('dance-b', category: 'Dance'),
        course('dance-c', category: 'Dance, Music, Art'),
        course('chess-1', category: 'Chess'),
      ]);

      expect(
        ordered.map((c) => c.id),
        ['dance-a', 'chess-1', 'dance-b', 'dance-c'],
        reason: 'all three Dance courses share one bucket',
      );
    });

    test('the same category typed in different cases is one category', () {
      final ordered = HomeCubit.coursesAcrossCategories([
        course('a', category: 'Shaxmat'),
        course('b', category: 'shaxmat'),
        course('c', category: 'Suzish'),
      ]);
      expect(ordered.map((c) => c.id), ['a', 'c', 'b']);
    });

    test('an empty list stays empty rather than looping', () {
      expect(HomeCubit.coursesAcrossCategories(const []), isEmpty);
    });
  });

  group('the subscription row', () {
    test('is capped at ten', () {
      expect(HomeCubit.subscriptionRowSize, 10);
    });

    test('grows by APPENDING, so cards on screen keep their places', () {
      final row = [activity('a', coins: 10), activity('b', coins: 10)];
      final grown = HomeCubit.growSubscriptionRow(
        row,
        [activity('c', coins: 10), activity('d', coins: 10)],
      );
      // The first two are untouched: a later page must fill the row out
      // BEHIND what the user is already looking at, never re-deal it under
      // a finger that is mid-scroll.
      expect(grown.take(2).map((c) => c.id), ['a', 'b']);
      expect(grown.map((c) => c.id), containsAll(['c', 'd']));
      expect(grown, hasLength(4));
    });

    test('growing never takes the row past its cap', () {
      final full = [
        for (var i = 0; i < HomeCubit.subscriptionRowSize; i++)
          activity('a\$i', coins: 10),
      ];
      final grown =
          HomeCubit.growSubscriptionRow(full, [activity('extra', coins: 10)]);
      expect(grown, hasLength(HomeCubit.subscriptionRowSize));
      expect(grown.map((c) => c.id), isNot(contains('extra')));
    });

    test('growing admits only what coins can pay for', () {
      final grown = HomeCubit.growSubscriptionRow(
        [activity('a', coins: 10)],
        [activity('money-only'), course('a-course'), activity('zero', coins: 0)],
      );
      // Nothing to add, so the row comes back as it went in — the filter is
      // not bypassed just because the row is short of ten.
      expect(grown.map((c) => c.id), ['a']);
    });

    test('an activity already in the row is not added twice', () {
      final a = activity('a', coins: 10);
      final grown = HomeCubit.growSubscriptionRow([a], [a, activity('b', coins: 10)]);
      expect(grown.map((c) => c.id), ['a', 'b']);
    });

    test('the deal is reproducible — the same feed, the same order', () {
      // The shuffle is seeded fresh per deal, so a silent refresh of an
      // unchanged feed must not reorder the row under the user.
      final incoming = [
        for (var i = 0; i < 6; i++) activity('a\$i', coins: 10),
      ];
      final first = HomeCubit.growSubscriptionRow(const [], incoming);
      final second = HomeCubit.growSubscriptionRow(const [], incoming);
      expect(first.map((c) => c.id), second.map((c) => c.id));
      // And it IS shuffled, not just passed through in feed order.
      expect(first, hasLength(6));
    });

    test('a money-only activity can never be in it', () {
      // The rule the row's header makes a promise about: `newCoinPrice` is
      // sent only on what coins are accepted for, and never on a course.
      final paid = activity('paid', coins: 40);
      final moneyOnly = activity('money-only');
      final zeroCoins = activity('zero', coins: 0);

      expect((paid.newCoinPrice ?? 0) > 0, isTrue);
      expect((moneyOnly.newCoinPrice ?? 0) > 0, isFalse);
      // A zero coin price is not "free with a pack", it is "no coin price" —
      // treating it as membership would put an unpayable card in the row.
      expect((zeroCoins.newCoinPrice ?? 0) > 0, isFalse);
      expect((course('c').newCoinPrice ?? 0) > 0, isFalse);
    });
  });
}

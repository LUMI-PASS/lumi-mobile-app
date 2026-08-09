import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/home_model/course_price_kind.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

/// A course card shows ONE price, and the server says which one it is. The card
/// must word that verdict — and must keep rendering when the server sends a
/// verdict this build has never heard of, because the backend gains kinds
/// without waiting for the app stores.
void main() {
  group('reading price_kind off the wire', () {
    test('resolves every kind the backend sends today', () {
      expect(CoursePriceKind.fromKey('trial_free'), CoursePriceKind.trialFree);
      expect(CoursePriceKind.fromKey('trial'), CoursePriceKind.trial);
      expect(CoursePriceKind.fromKey('trial_next'), CoursePriceKind.trialNext);
      expect(CoursePriceKind.fromKey('full'), CoursePriceKind.full);
    });

    test('falls back to unknown instead of throwing on a new kind', () {
      expect(CoursePriceKind.fromKey('bundle_of_four'), CoursePriceKind.unknown);
      expect(CoursePriceKind.fromKey(null), CoursePriceKind.unknown);
      expect(CoursePriceKind.fromKey(''), CoursePriceKind.unknown);
    });

    test('only the trial kinds are still offering a single lesson', () {
      expect(CoursePriceKind.trialFree.isTrial, isTrue);
      expect(CoursePriceKind.trial.isTrial, isTrue);
      expect(CoursePriceKind.trialNext.isTrial, isTrue);
      expect(CoursePriceKind.full.isTrial, isFalse);
      expect(CoursePriceKind.unknown.isTrial, isFalse);
    });
  });

  group('a course card parsed from the discovery feed', () {
    /// The shape `mapCourseCard` sends for a 1 200 000 / 12-lesson course whose
    /// first trial lesson is 100 000, seen by someone who has never been.
    Map<String, dynamic> json({
      String priceKind = 'trial',
      num cardPrice = 100000,
      int? trialLessonNo = 1,
    }) =>
        {
          'id': 'a1',
          'title': 'English',
          'is_course': true,
          'price_kind': priceKind,
          'card_price': cardPrice,
          'trial_lesson_no': trialLessonNo,
          'trial_lessons': 3,
          'trial_lessons_left': 3,
          'course_price': 1200000,
          'lessons_count': 12,
          'per_lesson_price': 100000,
        };

    test('carries the trial figure and the whole-course figure separately', () {
      final card = HomClass.fromJson(json());
      expect(card.coursePriceKind, CoursePriceKind.trial);
      expect(card.cardPrice, 100000);
      expect(card.coursePrice, 1200000);
      expect(card.perLessonPrice, 100000);
      expect(card.lessonsCount, 12);
    });

    test('a free first lesson arrives as a real zero, not a missing price', () {
      final card = HomClass.fromJson(
        json(priceKind: 'trial_free', cardPrice: 0),
      );
      expect(card.coursePriceKind, CoursePriceKind.trialFree);
      expect(card.cardPrice, 0);
    });

    test('someone with the trial used up is quoted the course', () {
      final card = HomClass.fromJson(
        json(priceKind: 'full', cardPrice: 1200000, trialLessonNo: null),
      );
      expect(card.coursePriceKind, CoursePriceKind.full);
      expect(card.cardPrice, 1200000);
      expect(card.trialLessonNo, isNull);
    });

    test('an old response with no course pricing still parses', () {
      // A cached feed, or a server that predates the per-lesson card. Nothing
      // may throw — the card falls back to the whole-course price.
      final card = HomClass.fromJson({
        'id': 'a1',
        'title': 'English',
        'is_course': true,
        'course_price': 1200000,
      });
      expect(card.coursePriceKind, CoursePriceKind.unknown);
      expect(card.cardPrice, isNull);
      expect(card.coursePrice, 1200000);
    });
  });
}

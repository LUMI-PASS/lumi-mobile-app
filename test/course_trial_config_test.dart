import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';

/// A course's trial ladder reaches the app twice, in two different forms, and
/// on some courses only one of them is populated.
///
/// `/api/courses/:id` serves it DATED — the server pairs each configured rung
/// with the next session off the class's schedule. That is the form checkout is
/// written against. A course whose schedule hasn't been entered has no sessions
/// to pair with, so that list comes back empty and the server says
/// `not_configured`.
///
/// `/api/classes/:id` serves the same ladder as the centre CONFIGURED it: how
/// many rungs, what each costs, which are compulsory — and no dates, because
/// dates are not something anyone configures. These tests cover that form. It
/// is what lets the detail page show "4 trial lessons, first one free" for a
/// course the dated endpoint has nothing to say about.
void main() {
  /// The live shape of Arxi Neo (activity 6a904d55…): one sub-course, four
  /// configured trials with a free first rung, and no schedule anywhere.
  Map<String, dynamic> arxiNeo() => {
        '_id': '6a904d5575f9ef3af6993545',
        'is_course': true,
        'schedule': const [],
        'course': {
          'trial_lessons': const [],
          'course_price': 0,
          'subcourses': [
            {
              '_id': '6a904d5575f9ef3af6993546',
              'name': {'en': 'Arxi Neo 1'},
              'order': 1,
              'course_price': 800000,
              'trial_lessons': const [
                {'lesson_no': 1, 'price': 0, 'is_mandatory': false},
                {'lesson_no': 2, 'price': 100000, 'is_mandatory': false},
                {'lesson_no': 3, 'price': 100000, 'is_mandatory': false},
                {'lesson_no': 4, 'price': 100000, 'is_mandatory': false},
              ],
            },
          ],
        },
      };

  group('the configured trial ladder', () {
    test('is read off the sub-course that owns it', () {
      final trials = ClassFullModel.fromJson(arxiNeo())
          .trialsForGroup('6a904d5575f9ef3af6993546');

      expect(trials.length, 4);
      expect(trials.map((t) => t.lessonNo), [1, 2, 3, 4]);
      // The free first rung is the whole offer — 0 is a price, not a gap.
      expect(trials.first.price, 0);
      expect(trials.last.price, 100000);
      expect(trials.every((t) => !t.isMandatory), isTrue);
    });

    test('comes back in ladder order however it arrives', () {
      final json = arxiNeo();
      (json['course']['subcourses'] as List).first['trial_lessons'] = const [
        {'lesson_no': 3, 'price': 100000, 'is_mandatory': false},
        {'lesson_no': 1, 'price': 0, 'is_mandatory': true},
        {'lesson_no': 2, 'price': 100000, 'is_mandatory': false},
      ];

      final trials = ClassFullModel.fromJson(json)
          .trialsForGroup('6a904d5575f9ef3af6993546');

      // Trials are taken in order, so the rungs are numbered — the list has to
      // follow that number, not the order Mongo happened to return them in.
      expect(trials.map((t) => t.lessonNo), [1, 2, 3]);
      expect(trials.first.isMandatory, isTrue);
    });

    test('a course entered without sub-courses keeps its own ladder', () {
      final model = ClassFullModel.fromJson({
        '_id': 'flat',
        'is_course': true,
        'course': {
          'course_price': 500000,
          'subcourses': const [],
          'trial_lessons': const [
            {'lesson_no': 1, 'price': 0, 'is_mandatory': true},
            {'lesson_no': 2, 'price': 50000, 'is_mandatory': false},
          ],
        },
      });

      // A flat course has no sub-course id to key on, so it lives under null —
      // which is the id the page's single group carries.
      expect(model.trialsForGroup(null).length, 2);
      expect(model.trialsForGroup(null).first.isMandatory, isTrue);
    });

    test('a sub-course without its own trials falls back to the course', () {
      final model = ClassFullModel.fromJson({
        '_id': 'mixed',
        'is_course': true,
        'course': {
          'trial_lessons': const [
            {'lesson_no': 1, 'price': 0, 'is_mandatory': false},
          ],
          'subcourses': const [
            {'_id': 'level-a', 'trial_lessons': []},
          ],
        },
      });

      expect(model.trialsForGroup('level-a').length, 1);
    });

    test('an activity that is not a course reports nothing', () {
      final model = ClassFullModel.fromJson({'_id': 'plain', 'name': {}});

      expect(model.courseTrials, isEmpty);
      expect(model.trialsForGroup(null), isEmpty);
      expect(model.trialsForGroup('anything'), isEmpty);
    });

    test('survives a malformed course block rather than throwing', () {
      // The ladder is decoration on a page that must still open. Anything
      // unexpected degrades to "no trials configured".
      for (final course in <dynamic>[
        null,
        'not a map',
        {'trial_lessons': 'not a list'},
        {'subcourses': 'not a list'},
        {
          'subcourses': [
            'not a map',
            {'_id': null, 'trial_lessons': []},
          ],
        },
      ]) {
        final model = ClassFullModel.fromJson({'_id': 'x', 'course': course});
        expect(model.trialsForGroup(null), isEmpty);
      }
    });

    test('a missing price or flag reads as free and optional', () {
      final model = ClassFullModel.fromJson({
        '_id': 'sparse',
        'course': {
          'trial_lessons': const [
            {'lesson_no': 1},
          ],
        },
      });

      final trial = model.trialsForGroup(null).single;
      expect(trial.price, 0);
      expect(trial.isMandatory, isFalse);
    });
  });
}

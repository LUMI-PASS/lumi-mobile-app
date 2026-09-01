import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/utils/course_timetable.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';

/// 2026-09-07 is a Monday, so the dates below run Mon/Tue/Wed/Fri of one week.
CourseLesson _lesson(String date, {String? start, String? end}) =>
    CourseLesson(lessonNo: 1, date: date, startTime: start, endTime: end);

const _mon = '2026-09-07';
const _tue = '2026-09-08';
const _wed = '2026-09-09';
const _fri = '2026-09-11';

void main() {
  // The summary renders weekday names through easy_localization; with no bundle
  // loaded `.tr()` echoes the key back, which is exactly what these assertions
  // want — they pin the SHAPE of the line (which days group with which clock),
  // not the translations.
  setUp(() => EasyLocalization.logger.enableLevels = const []);

  test('an empty or undated list has no timetable to state', () {
    expect(courseTimetableSummary(const []), '');
    expect(courseTimetableSummary([_lesson('', start: '14:00')]), '');
  });

  test('days sharing one clock read as a single line', () {
    final summary = courseTimetableSummary([
      _lesson(_mon, start: '14:00', end: '15:00'),
      _lesson(_wed, start: '14:00', end: '15:00'),
      _lesson(_fri, start: '14:00', end: '15:00'),
    ]);

    expect(summary, 'weekday_short_1, weekday_short_3, weekday_short_5 '
        '14:00 – 15:00');
    // One clock, said once.
    expect('14:00 – 15:00'.allMatches(summary).length, 1);
  });

  test('days that differ are split out with their own clock', () {
    final summary = courseTimetableSummary([
      _lesson(_mon, start: '14:00', end: '15:00'),
      _lesson(_wed, start: '16:00', end: '17:00'),
    ]);

    expect(
      summary,
      'weekday_short_1 14:00 – 15:00 · weekday_short_3 16:00 – 17:00',
    );
  });

  test('only the day that differs is separated — the rest still group', () {
    final summary = courseTimetableSummary([
      _lesson(_mon, start: '14:00', end: '15:00'),
      _lesson(_tue, start: '14:00', end: '15:00'),
      _lesson(_fri, start: '18:00', end: '19:00'),
    ]);

    expect(
      summary,
      'weekday_short_1, weekday_short_2 14:00 – 15:00 · '
      'weekday_short_5 18:00 – 19:00',
    );
  });

  test('groups come out in week order however the dates arrive', () {
    final summary = courseTimetableSummary([
      _lesson(_fri, start: '18:00', end: '19:00'),
      _lesson(_wed, start: '14:00', end: '15:00'),
      _lesson(_mon, start: '14:00', end: '15:00'),
    ]);

    expect(
      summary,
      'weekday_short_1, weekday_short_3 14:00 – 15:00 · '
      'weekday_short_5 18:00 – 19:00',
    );
  });

  test('one weekday taught at two hours appears against both', () {
    final summary = courseTimetableSummary([
      _lesson(_mon, start: '10:00', end: '11:00'),
      _lesson('2026-09-14', start: '15:00', end: '16:00'), // the next Monday
    ]);

    expect(
      summary,
      'weekday_short_1 10:00 – 11:00 · weekday_short_1 15:00 – 16:00',
    );
  });

  test('a missing end time shows the start alone', () {
    expect(
      courseTimetableSummary([_lesson(_mon, start: '14:00')]),
      'weekday_short_1 14:00',
    );
  });

  test('a lesson with no clock keeps its day, timeless', () {
    expect(courseTimetableSummary([_lesson(_mon)]), 'weekday_short_1');
    expect(
      courseTimetableSummary([
        _lesson(_mon),
        _lesson(_wed, start: '14:00', end: '15:00'),
      ]),
      'weekday_short_1 · weekday_short_3 14:00 – 15:00',
    );
  });
}

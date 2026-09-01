/// When a course actually meets: the weekdays it runs on and the clock beside
/// them.
///
/// Both the class detail page (a group's summary line) and the purchase sheet
/// (the month being bought) word it from here, so the two screens can never
/// state the same timetable differently.
library;

import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';

/// One lesson's clock — `"14:00 – 15:00"`, or just the start where the centre
/// entered no end. Empty when there is no time on the lesson at all.
String _timeLabel(CourseLesson lesson) {
  final start = lesson.startTime?.trim() ?? '';
  if (start.isEmpty) return '';
  final end = lesson.endTime?.trim() ?? '';
  return end.isEmpty ? start : '$start – $end';
}

/// The timetable [lessons] add up to, e.g. `"Mon, Wed 14:00 – 15:00"` — or,
/// where the days don't share one clock, each set of days with its own:
/// `"Mon, Wed 14:00 – 15:00 · Fri 16:00 – 17:00"`.
///
/// Days are grouped BY TIME rather than listed one per line. A course that runs
/// at the same hour all week is the common case and deserves to read as one
/// fact; splitting it into "Mon 14:00, Wed 14:00, Fri 14:00" made a parent
/// compare three strings to find out they were identical. Only a day that
/// genuinely differs gets separated out.
///
/// In WEEK order, not the order the dates happen to arrive in: a course whose
/// first lesson falls on a Wednesday otherwise read "Wed, Fri, Mon" — a
/// timetable nobody holds in their head that way. `DateTime.weekday` is
/// Mon=1…Sun=7, so sorting the numbers is the week order, and the groups
/// themselves follow their earliest day.
///
/// Lessons with no clock keep their days, timeless — a missing hour is not a
/// reason to drop the day it runs on. Empty for an empty or undated list.
String courseTimetableSummary(List<CourseLesson> lessons) {
  // time label → the weekdays it is taught on. A weekday taught at two
  // different hours lands in both groups, which is exactly the split a parent
  // needs to see.
  final daysByTime = <String, Set<int>>{};
  for (final lesson in lessons) {
    final date = DateTime.tryParse(lesson.date);
    if (date == null) continue;
    daysByTime.putIfAbsent(_timeLabel(lesson), () => <int>{}).add(date.weekday);
  }
  if (daysByTime.isEmpty) return '';

  final groups = daysByTime.entries
      .map((e) => (time: e.key, days: e.value.toList()..sort()))
      .toList()
    // Earliest day first, then by the clock — so two groups starting on the
    // same weekday still come out in a stable order rather than the map's.
    ..sort((a, b) {
      final byDay = a.days.first.compareTo(b.days.first);
      return byDay != 0 ? byDay : a.time.compareTo(b.time);
    });

  return groups
      .map((g) {
        final days = g.days.map((w) => 'weekday_short_$w'.tr()).join(', ');
        return g.time.isEmpty ? days : '$days ${g.time}';
      })
      .join(' · ');
}

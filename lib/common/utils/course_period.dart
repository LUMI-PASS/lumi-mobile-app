/// How long a whole-course purchase runs for.
///
/// A course is sold BY THE MONTH, so the period a parent buys is a calendar
/// month from the day it starts — 22 Sep runs to 22 Oct — regardless of where
/// the timetable's last lesson happens to fall inside it. Both the class detail
/// page (stating a group's run) and the purchase sheet (the month being bought)
/// word it from here, so the two screens can never disagree about the same
/// course by a day.
library;

/// One calendar month after [start], with the day clamped to the target month's
/// length.
///
/// Clamping is the whole reason this isn't written inline: `DateTime(y, m + 1,
/// 31)` on a 31 January start rolls forward into March, quietly selling five
/// weeks as four. 31 Jan ends 28 Feb (29 in a leap year), 31 Mar ends 30 Apr.
DateTime courseMonthEnd(DateTime start) {
  final year = start.month == 12 ? start.year + 1 : start.year;
  final month = start.month == 12 ? 1 : start.month + 1;
  // Day 0 of the month after the target is the target's own last day.
  final lastDay = DateTime(year, month + 1, 0).day;
  return DateTime(year, month, start.day > lastDay ? lastDay : start.day);
}

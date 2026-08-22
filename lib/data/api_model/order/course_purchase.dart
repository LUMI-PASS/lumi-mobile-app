/// What a course order bought.
///
/// The backend writes `course_purchase` on an order that bought a COURSE, and
/// leaves it off a normal activity booking — so "absent" is a third answer, not
/// a missing one, and is modelled as [CoursePurchase.none] rather than a null
/// this app has to remember to check everywhere.
///
/// [fromKey] never throws: a value this build has not heard of degrades to
/// [unknown], which reads as "a course, kind unspecified" — the safe half of
/// the truth, since it is only ever set on course orders.
enum CoursePurchase {
  /// Not a course at all: a normal per-session activity booking.
  none(''),

  /// ONE trial lesson, bought off the course's trial ladder.
  trial('trial'),

  /// The whole course — one enrolment, however many lessons it runs.
  full('full'),

  /// A `course_purchase` this build does not know.
  unknown('unknown');

  const CoursePurchase(this.key);

  /// The wire value.
  final String key;

  /// True for anything bought as a course, whichever way.
  bool get isCourse => this != none;

  static CoursePurchase fromKey(String? key) {
    final raw = key?.trim().toLowerCase() ?? '';
    if (raw.isEmpty) return none;
    for (final value in CoursePurchase.values) {
      if (value != none && value.key == raw) return value;
    }
    return unknown;
  }
}

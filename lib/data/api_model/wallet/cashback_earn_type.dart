/// The three server-defined ways a purchase earns cashback.
///
/// Each is configured with its own percentage in the dashboard, so which one a
/// purchase falls under decides the rate. The backend derives it from the order
/// itself — the app never sends it — and this enum only names what came back.
///
/// [unknown] is the safe fallback: a fourth earn type added server-side must
/// render as "earns cashback" without a rate label rather than throwing.
/// Resolve with [CashbackEarnType.fromKey]; switch exhaustively so a new value
/// surfaces as a compile-time warning.
enum CashbackEarnType {
  /// A one-off booking of a class that isn't a course.
  activity('activity'),

  /// One or more trial lessons of a course or sub-course.
  trialLesson('trial_lesson'),

  /// A full course or sub-course enrolment.
  course('course'),

  unknown('');

  const CashbackEarnType(this.key);

  /// The raw `earn_type` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [CashbackEarnType], returning [unknown] for
  /// null or unrecognised values. Never throws.
  static CashbackEarnType fromKey(String? key) {
    for (final type in values) {
      if (type != unknown && type.key == key) return type;
    }
    return unknown;
  }
}

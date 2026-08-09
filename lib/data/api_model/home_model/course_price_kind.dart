/// Which price a course card is showing, and why.
///
/// A card has room for ONE price, and which one belongs there depends on the
/// viewer: the first trial lesson to someone new, the next one to someone
/// part-way through the trial, the whole course to someone who has used the
/// trial up or already enrolled. The server decides — the same rules that
/// govern checkout — and sends its verdict as `price_kind`; the card only
/// words it.
///
/// [unknown] is the safe fallback for a `price_kind` this build doesn't model
/// yet. It renders as the plain price with no wording around it, which is wrong
/// in emphasis but never wrong in money.
enum CoursePriceKind {
  /// The next trial lesson costs nothing. `trial_lesson_no` says which.
  trialFree('trial_free'),

  /// They hold no trial lesson yet: this is the entry price.
  trial('trial'),

  /// They are part-way up the trial: this is the price of the NEXT lesson.
  trialNext('trial_next'),

  /// Nothing left to try — the price is the whole course.
  full('full'),

  unknown('');

  const CoursePriceKind(this.key);

  /// The raw `price_kind` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [CoursePriceKind], returning [unknown] for null
  /// or unrecognised values. Never throws.
  static CoursePriceKind fromKey(String? key) {
    for (final kind in values) {
      if (kind != unknown && kind.key == key) return kind;
    }
    return unknown;
  }

  /// True while the card is still offering a single lesson rather than the
  /// whole course — the states where the price is a taster, not a commitment.
  bool get isTrial =>
      this == trialFree || this == trial || this == trialNext;
}

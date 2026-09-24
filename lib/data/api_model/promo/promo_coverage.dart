/// How an "аксия" pass pays for a booking.
///
/// [unknown] is the safe fallback for any `coverage` string that isn't (yet)
/// modelled here — the backend can add new kinds without the app throwing.
/// Resolve with [PromoCoverage.fromKey]; switch exhaustively so a newly added
/// value surfaces as a compile-time warning rather than a runtime surprise.
enum PromoCoverage {
  /// The pass covers the WHOLE price of a visit — the flagship 99 000 bundle.
  /// Nothing is charged at checkout, because the bundle was paid for up front.
  full('full'),

  /// The pass takes a percentage off each visit and the rest is still paid.
  percent('percent'),

  unknown('');

  const PromoCoverage(this.key);

  /// The raw `coverage` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [PromoCoverage], returning [unknown] for null
  /// or unrecognised values. Never throws.
  static PromoCoverage fromKey(String? key) {
    for (final coverage in values) {
      if (coverage != unknown && coverage.key == key) return coverage;
    }
    return unknown;
  }

  /// Whether a covered visit leaves nothing to pay.
  ///
  /// [unknown] answers false on purpose: an unmodelled coverage kind must not
  /// make the app promise a free booking it cannot vouch for. It will fall back
  /// to showing the amount the server actually reports.
  bool get isFull => this == full;
}

/// Where a bought "аксия" pass stands.
///
/// [unknown] is the safe fallback for any `status` string that isn't (yet)
/// modelled here — the backend can add new states at any time. Resolve with
/// [PromoPassStatus.fromKey]; switch exhaustively so a newly added value
/// surfaces as a compile-time warning rather than a runtime surprise.
enum PromoPassStatus {
  /// Paid for, inside its window, with at least one visit left.
  active('active'),

  /// Every included visit was spent.
  used('used'),

  /// The window closed with visits unspent.
  expired('expired'),

  /// The purchase was refunded.
  canceled('canceled'),

  unknown('');

  const PromoPassStatus(this.key);

  /// The raw `status` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [PromoPassStatus], returning [unknown] for null
  /// or unrecognised values. Never throws.
  static PromoPassStatus fromKey(String? key) {
    for (final status in values) {
      if (status != unknown && status.key == key) return status;
    }
    return unknown;
  }

  /// Whether this pass is done with — spent, timed out, or refunded.
  ///
  /// [unknown] is treated as live rather than finished: the server sends
  /// `is_usable` alongside, and a state this build has never heard of is more
  /// likely a new kind of live pass than a new kind of dead one. Showing a live
  /// pass as finished would hide visits somebody paid for.
  bool get isFinished =>
      this == used || this == expired || this == canceled;
}

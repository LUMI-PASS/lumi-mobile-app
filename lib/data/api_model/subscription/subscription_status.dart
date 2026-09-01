/// Where a purchased coupon stands: still usable, run out, or called off.
///
/// The `status` field of `GET /api/transaction/subscriptions`. [unknown] is the
/// safe fallback for any string that isn't (yet) modelled here — the backend
/// can add a state without the app throwing. Resolve with [fromKey]; switch
/// exhaustively so a newly added value surfaces as a compile-time warning
/// rather than silently painting itself as expired.
enum SubscriptionStatus {
  active('active'),
  expired('expired'),
  canceled('canceled'),
  unknown('');

  const SubscriptionStatus(this.key);

  /// The raw `status` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [SubscriptionStatus], returning [unknown] for
  /// null or unrecognised values. Never throws.
  ///
  /// Case-insensitive, and the British `cancelled` resolves to [canceled]: the
  /// two spellings have both been seen on the wire, and a coupon the user
  /// called off must not read as merely expired because of an extra `l`.
  static SubscriptionStatus fromKey(String? key) {
    final k = key?.trim().toLowerCase();
    if (k == null || k.isEmpty) return unknown;
    if (k == 'cancelled') return canceled;
    for (final status in values) {
      if (status != unknown && status.key == k) return status;
    }
    return unknown;
  }

  /// Whether the coupon can still be spent — the one state worth colouring.
  bool get isUsable => this == active;
}

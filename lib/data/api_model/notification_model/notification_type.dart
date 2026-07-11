/// Server-driven notification categories.
///
/// [unknown] is the safe fallback for any `type` string that isn't (yet)
/// modelled here — the backend can add new types without the app throwing.
/// Resolve with [NotificationType.fromKey]; switch exhaustively so a newly
/// added enum value surfaces as a compile-time warning rather than a runtime
/// surprise.
enum NotificationType {
  bookingApproved('booking_approved'),
  bookingRejected('booking_rejected'),
  bookingTimeSuggestion('booking_time_suggestion'),
  bookingRequestPending('booking_request_pending'),
  unknown('');

  const NotificationType(this.key);

  /// The raw `type` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [NotificationType], returning [unknown] for
  /// null or unrecognised values. Never throws.
  static NotificationType fromKey(String? key) {
    for (final type in values) {
      if (type != unknown && type.key == key) return type;
    }
    return unknown;
  }

  /// Booking-related notifications deep-link into "My bookings".
  bool get isBooking =>
      this == bookingApproved ||
      this == bookingRejected ||
      this == bookingTimeSuggestion ||
      this == bookingRequestPending;
}

/// Server-driven promocode rejection reasons, sent as `error_code` on the 400
/// from `promocodes/validate`.
///
/// [unknown] is the safe fallback for any code that isn't (yet) modelled here —
/// the backend can add reasons at any time without the app throwing, and the
/// caller degrades to the server's own `message`. Resolve with
/// [PromoErrorCode.fromKey]; switch exhaustively so a newly added value surfaces
/// as a compile-time warning rather than a runtime surprise.
enum PromoErrorCode {
  /// The order subtotal is above the code's ceiling. Carries `max_order_amount`.
  maxOrder('promo_max_order'),

  /// The class's partner share is too thin to fund any discount.
  notApplicable('promo_not_applicable'),

  /// Promocodes fund one-time activities only, never courses.
  courseOnly('promo_course_only'),

  /// Nothing left to redeem — the code's pool, or this buyer's share of it, is
  /// spent.
  alreadyUsed('promo_already_used'),

  /// Uses remain, but fewer than the tickets in this order. Carries
  /// `ticket_limit`: how many tickets the code still covers.
  ticketLimit('promo_ticket_limit'),

  unknown('');

  const PromoErrorCode(this.key);

  /// The raw `error_code` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [PromoErrorCode], returning [unknown] for null
  /// or unrecognised values. Never throws.
  static PromoErrorCode fromKey(String? key) {
    for (final code in values) {
      if (code != unknown && code.key == key) return code;
    }
    return unknown;
  }
}

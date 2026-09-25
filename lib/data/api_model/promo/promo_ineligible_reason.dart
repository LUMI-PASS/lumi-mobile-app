/// Why an "аксия" pass cannot pay for a particular booking.
///
/// The server decides this — the app never re-derives it, because the rules
/// (the deadline, the "three DIFFERENT activities" rule, the price ceiling)
/// live where the pass lives. This enum exists only to turn the server's answer
/// into a sentence the buyer can act on.
///
/// [unknown] is the safe fallback for any `reason` string that isn't (yet)
/// modelled here. Resolve with [PromoIneligibleReason.fromKey]; switch
/// exhaustively so a newly added value surfaces as a compile-time warning
/// rather than a runtime surprise.
enum PromoIneligibleReason {
  /// Nothing to spend — the buyer holds no live pass.
  noPass('no_pass'),

  /// The five days ran out.
  expired('expired'),

  /// All the included visits are spent.
  exhausted('exhausted'),

  /// The pass already paid for a visit to THIS activity. It covers three
  /// different places, so the second visit here is on the buyer.
  alreadyUsedHere('already_used_here'),

  /// The chosen date falls past the pass's deadline.
  dateAfterExpiry('date_after_expiry'),

  /// This activity is not part of the promo.
  outOfScope('out_of_scope'),

  /// Dearer than a single visit of the bundle covers.
  tooExpensive('too_expensive'),

  /// A course enrolment. A visit slot buys one visit, not a whole term.
  course('course'),

  /// More than one ticket on the booking. A packet is N visits and each visit
  /// is ONE ticket — three bookings, three tickets, three different places.
  tooManyTickets('too_many_tickets'),

  /// A promocode was entered alongside the packet. They never stack.
  withPromocode('with_promocode'),

  unknown('');

  const PromoIneligibleReason(this.key);

  /// The raw `reason` string as sent by the backend.
  final String key;

  /// Maps a backend string to a [PromoIneligibleReason], returning [unknown]
  /// for null or unrecognised values. Never throws.
  static PromoIneligibleReason fromKey(String? key) {
    for (final reason in values) {
      if (reason != unknown && reason.key == key) return reason;
    }
    return unknown;
  }

  /// The localization key for the sentence shown to the buyer.
  ///
  /// [unknown] falls back to the generic line rather than showing a raw key —
  /// the reason is cosmetic, the refusal is not.
  String get messageKey {
    switch (this) {
      case PromoIneligibleReason.noPass:
        return 'aksiya_why_no_pass';
      case PromoIneligibleReason.expired:
        return 'aksiya_why_expired';
      case PromoIneligibleReason.exhausted:
        return 'aksiya_why_exhausted';
      case PromoIneligibleReason.alreadyUsedHere:
        return 'aksiya_why_already_used_here';
      case PromoIneligibleReason.dateAfterExpiry:
        return 'aksiya_why_date_after_expiry';
      case PromoIneligibleReason.outOfScope:
        return 'aksiya_why_out_of_scope';
      case PromoIneligibleReason.tooExpensive:
        return 'aksiya_why_too_expensive';
      case PromoIneligibleReason.course:
        return 'aksiya_why_course';
      case PromoIneligibleReason.tooManyTickets:
        return 'aksiya_why_too_many_tickets';
      case PromoIneligibleReason.withPromocode:
        return 'aksiya_why_with_promocode';
      case PromoIneligibleReason.unknown:
        return 'aksiya_why_generic';
    }
  }

  /// Whether the buyer could fix this by changing something on this screen.
  ///
  /// A date past the deadline is fixable by picking an earlier one, so the row
  /// stays visible and explains itself. Having no pass at all is not a refusal
  /// to explain — it is a reason to hide the row and show the offer instead.
  bool get isFixableHere =>
      this == dateAfterExpiry ||
      this == alreadyUsedHere ||
      // Take a ticket off, or remove the code — both are one tap away on the
      // sheet that is showing the message.
      this == tooManyTickets ||
      this == withPromocode;

  /// Resolves the `error_code` a refused checkout returns.
  ///
  /// The server namespaces them (`promo_pass_too_many_tickets`) so they cannot
  /// collide with the bare promocode codes; this strips that prefix and reads
  /// the rule. Anything unrecognised — including a code from a newer server —
  /// lands on [unknown] and shows the generic line rather than a raw key.
  static PromoIneligibleReason? fromErrorCode(String? code) {
    const prefix = 'promo_pass_';
    if (code == null || !code.startsWith(prefix)) return null;
    return fromKey(code.substring(prefix.length));
  }
}

/// Which endpoint a booking must be sent to, and what a card payment has to
/// carry with it.
///
/// Both rules exist because the backend enforces them and answers with a 400
/// that reads like a client bug rather than a routing mistake:
///
///  • an activity checkout requires at least one `items[]` entry — a course has
///    none, because it is sold as a package rather than per ticket, so sending
///    a course to the activity endpoint fails with
///    "items must contain at least 1 elements";
///  • a `card` checkout requires the card with it — provider alone fails with
///    "Card number, expire date, and amount are required for card checkout".
///
/// These are pulled out of the booking screens so they can be tested without a
/// widget, and so the two screens cannot drift apart on them.
library;

/// The checkout endpoint a purchase belongs to.
enum CheckoutTarget {
  /// `POST /api/orders/checkout` — priced per ticket, needs `items[]`.
  activity,

  /// `POST /api/courses/:id/checkout` — sold as a package, has no `items[]`.
  course,
}

/// Courses are sold through their own endpoint. Getting this wrong is not a
/// silent mismatch: the activity endpoint rejects an empty `items[]`.
CheckoutTarget checkoutTargetFor({required bool isCourse}) =>
    isCourse ? CheckoutTarget.course : CheckoutTarget.activity;

/// Whether a checkout about to be sent carries what the card rail needs.
///
/// A card is paid either by its number (typed this session) or by a saved
/// card's id — never by naming the rail alone. Returns true for every other
/// provider, which carries no card at all.
bool cardCheckoutIsComplete({
  required String? provider,
  required String? cardNumber,
  required String? expireDate,
  required String? savedCardId,
}) {
  if (provider != 'card') return true;
  if (savedCardId != null && savedCardId.trim().isNotEmpty) return true;
  return (cardNumber != null && cardNumber.trim().isNotEmpty) &&
      (expireDate != null && expireDate.trim().isNotEmpty);
}

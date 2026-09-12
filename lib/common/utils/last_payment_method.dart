import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:lumi_pass/presentation/app/home/class_detail/widgets/payment_sheets.dart';

/// The buyer's last-used payment method, remembered across checkouts.
///
/// Everything that charges money in this app pre-selects whatever was used
/// last, so paying a second time is one tap rather than a trip through the
/// chooser. The booking, course and coupon screens each grew their own copy of
/// this; the shop's is this one, shared, so a fifth screen does not have to
/// write a fifth.
///
/// Both halves read the SAME storage keys the other screens use — a card added
/// at a booking and a card picked in the shop are one choice, not two that
/// disagree.

/// Restores the remembered method, or null when there is nothing usable.
///
/// Returns null rather than a half-built selection in every doubtful case: an
/// unknown rail, card payments switched off, a card rail whose card is no
/// longer saved. A pre-selected method the gateway would reject is worse than
/// no pre-selection, because the buyer only finds out at the moment of paying.
Future<PaymentSelection?> restoreLastPaymentMethod() async {
  final storage = getIt<Storage>();

  final railKey = storage.lastPaymentRail();
  if (railKey == null || railKey.isEmpty) return null;

  PaymentRail? rail;
  for (final r in PaymentRail.values) {
    if (r.name == railKey) {
      rail = r;
      break;
    }
  }
  if (rail == null) return null;

  // The redirect rails carry nothing but themselves, so they restore as-is.
  if (rail != PaymentRail.card) return PaymentSelection(rail: rail);

  if (!kCardPaymentsEnabled) return null;

  // A card rail with no card behind it cannot pay for anything, so it is
  // restored only once the card is confirmed to still be on the account.
  final savedId = storage.lastSavedCardId();
  if (savedId == null || savedId.isEmpty) return null;
  try {
    final cards = await getIt<OrdersApi>().getSavedCards();
    for (final c in cards) {
      if (c.id == savedId) {
        return PaymentSelection(
          rail: PaymentRail.card,
          card: PaymentCard.saved(c),
        );
      }
    }
  } catch (_) {
    // Offline, or the lookup failed. Non-fatal: the buyer picks a method.
  }
  return null;
}

/// Remembers [sel] as the method to pre-select next time.
///
/// Called when the method is CHOSEN rather than after a payment succeeds: a
/// buyer who picked Click and then abandoned the basket still meant Click.
void rememberPaymentMethod(PaymentSelection sel) {
  final storage = getIt<Storage>();
  storage.lastPaymentRail.set(sel.rail.name);
  // Null for a redirect rail, which also clears a stale card id — otherwise a
  // later card restore could pair the card rail with somebody else's token.
  storage.lastSavedCardId.set(sel.card?.savedCardId);
}

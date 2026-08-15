/// Client-side cashback preview math.
///
/// Cashback is credited by the backend when an order is paid; nothing here
/// moves money. These helpers exist so the "you'll earn ~X" line the buyer
/// reads before paying matches what actually lands in their wallet.
///
/// **The rate is never computed here.** A configured percentage is only a
/// ceiling request: what is actually credited is capped by the partner's
/// commission on that specific class, which the app doesn't know. Always take
/// `percent` from `GET /api/cashback/preview` ([CashbackPreview.percent]) —
/// which is already ceiling-clamped — and only do the arithmetic around it
/// locally, so changing a ticket count doesn't cost a request.
///
/// Mirrors `CashbackService.quote` on the backend. **Keep the two in step**:
/// the same floor, the same cap order, the same threshold.
library;

import 'package:lumi_pass/data/api_model/wallet/cashback_preview.dart';

/// What [orderAmount] earns at [preview]'s rate, in whole soum.
///
/// [orderAmount] is what the buyer actually pays with money — the total after
/// any discount. Returns 0 whenever nothing is earned, so callers can key
/// their whole cashback UI on `> 0`.
num cashbackFor(CashbackPreview preview, num orderAmount) {
  if (preview.percent <= 0 || orderAmount <= 0) return 0;
  // Below the rule's threshold the order earns nothing at all — not a smaller
  // amount.
  if (orderAmount < preview.minOrderAmount) return 0;

  // Floor, never round: the backend floors too, and a preview that rounded up
  // would promise a soum the accrual doesn't pay.
  var amount = (orderAmount * preview.percent / 100).floor();

  final cap = preview.maxCashbackAmount;
  if (cap != null && amount > cap) amount = cap.floor();

  return amount < 0 ? 0 : amount;
}

/// A rate for display: drops the decimal when there isn't one, so 3.5% reads
/// "3.5%" and 1% reads "1%" rather than "1.0%".
String formatCashbackPercent(num percent) =>
    percent == percent.roundToDouble() ? '${percent.round()}' : '$percent';

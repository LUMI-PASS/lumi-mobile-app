import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';
import 'package:lumi_pass/data/api_model/promo/promo_ineligible_reason.dart';

/// Whether an "аксия" pass can pay for the booking being put together, and what
/// it would cover.
///
/// A PREVIEW — nothing is reserved by asking. The visit is only spent at
/// checkout, which re-tests every rule, so this answer can go stale between the
/// two and the checkout's verdict is the one that counts.
class PromoEligibility {
  final bool eligible;

  /// Why not, when [eligible] is false. Null on a positive answer.
  final PromoIneligibleReason? reason;

  /// Soum the pass would take off this order.
  final num covered;

  /// The pass that would be spent — or, on a refusal the buyer could fix, the
  /// pass that refused, so the row can still show what is left on it.
  final PromoPassSummary? pass;

  const PromoEligibility({
    this.eligible = false,
    this.reason,
    this.covered = 0,
    this.pass,
  });

  /// Nothing to offer and nothing to explain — the buyer holds no pass at all.
  static const none = PromoEligibility(
    reason: PromoIneligibleReason.noPass,
  );

  /// Whether the booking sheet should show the promo row.
  ///
  /// Shown when the pass can pay, and also when it refused for a reason the
  /// buyer can do something about on this screen — a date past the deadline, or
  /// an activity the pass has already been used at. Hidden when they simply
  /// have no pass: that is a job for the offer screen, not the booking sheet.
  bool get shouldShowRow =>
      eligible || (reason?.isFixableHere ?? false);

  factory PromoEligibility.fromJson(Map<String, dynamic> json) {
    final passJson = json['pass'];
    final reasonKey = json['reason']?.toString();
    return PromoEligibility(
      eligible: json['eligible'] == true,
      reason: (reasonKey == null || reasonKey.isEmpty)
          ? null
          : PromoIneligibleReason.fromKey(reasonKey),
      covered: (json['covered'] as num?) ?? 0,
      pass: passJson is Map
          ? PromoPassSummary.fromJson(Map<String, dynamic>.from(passJson))
          : null,
    );
  }
}

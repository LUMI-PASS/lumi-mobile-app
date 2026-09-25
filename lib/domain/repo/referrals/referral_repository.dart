import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';

abstract class ReferralRepository {
  /// Throws on failure — the screens that show it decide how to degrade.
  Future<ReferralMe> getMe();

  /// Never throws: null when the lookup could not be made at all. An invalid
  /// code is a [ReferralLookup] with `valid: false`. Signed-in only — see
  /// `ReferralsApi.lookup`.
  Future<ReferralLookup?> lookup(String code);

  /// Never throws: a refusal or a network failure is a failed
  /// [ReferralApplyOutcome], so each caller chooses whether it is shown.
  Future<ReferralApplyOutcome> apply(
    String code, {
    required ReferralApplySource source,
  });

  /// Never throws: an empty list when the fetch fails. A checkout must never
  /// break because the voucher strip could not load.
  Future<List<ReferralVoucher>> getVouchers({
    num? subtotal,
    String? activityId,
  });

  /// Fire-and-forget. Never throws, never awaited for anything that matters.
  Future<void> logEvent(
    ReferralEventType type, {
    String? channel,
    String? code,
  });
}

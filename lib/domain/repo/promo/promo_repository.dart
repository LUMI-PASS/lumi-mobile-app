import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';
import 'package:lumi_pass/data/api_model/promo/promo_eligibility.dart';
import 'package:lumi_pass/data/api_model/promo/promo_pass.dart';

abstract class PromoRepository {
  /// The bundles on sale, best offer first.
  Future<List<PromoCampaign>> getCampaigns();

  /// One bundle, by id or slug.
  Future<PromoCampaign> getCampaign(String idOrSlug);

  /// Buys a bundle.
  ///
  /// Returns the same [CheckoutResult] a booking does — deliberately, because
  /// the payment tail is the same code: a redirect URL for Payme/Click/Uzum, a
  /// transaction to confirm for a card, and neither of those for a saved card,
  /// which is charged by its own call afterwards.
  Future<CheckoutResult> purchase(
    String idOrSlug, {
    String? lang,
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  });

  /// Every pass the buyer has ever bought, live ones first.
  Future<List<PromoPass>> getPasses();

  Future<PromoPass> getPass(String id);

  /// Whether a pass can pay for the booking being put together.
  ///
  /// Never throws for the caller to handle: a booking sheet that cannot answer
  /// this simply does not offer the row, so a failed lookup resolves to
  /// [PromoEligibility.none] rather than breaking the screen a buyer is trying
  /// to pay on.
  Future<PromoEligibility> eligibility({
    required String activityId,
    String? ticketDate,
    num? subtotal,
    int? seats,
    bool isTrial = false,
  });
}

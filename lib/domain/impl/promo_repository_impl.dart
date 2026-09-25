import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';
import 'package:lumi_pass/data/api_model/promo/promo_eligibility.dart';
import 'package:lumi_pass/data/api_model/promo/promo_pass.dart';
import 'package:lumi_pass/domain/repo/promo/promo_api.dart';
import 'package:lumi_pass/domain/repo/promo/promo_repository.dart';

@Injectable(as: PromoRepository)
class PromoRepositoryImpl extends PromoRepository {
  final PromoApi _api;

  PromoRepositoryImpl(this._api);

  /// The `data:` envelope is not applied consistently across this backend —
  /// some endpoints wrap, some don't. Unwrap defensively rather than assuming,
  /// the same way `shop_repository_impl.dart` does.
  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is Map && raw['data'] is Map) {
      return Map<String, dynamic>.from(raw['data'] as Map);
    }
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  List<Map<String, dynamic>> _list(dynamic raw) {
    final List rows;
    if (raw is Map && raw['data'] is List) {
      rows = raw['data'] as List;
    } else if (raw is List) {
      rows = raw;
    } else {
      rows = const [];
    }
    return rows
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  @override
  Future<List<PromoCampaign>> getCampaigns() {
    return _api.getCampaigns().then(
          (res) => _list(res.data).map(PromoCampaign.fromJson).toList(),
        );
  }

  @override
  Future<PromoCampaign> getCampaign(String idOrSlug) {
    return _api
        .getCampaign(idOrSlug)
        .then((res) => PromoCampaign.fromJson(_unwrap(res.data)));
  }

  @override
  Future<CheckoutResult> purchase(
    String idOrSlug, {
    String? lang,
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  }) {
    return _api
        .purchase(
          idOrSlug,
          lang: lang,
          paymentProvider: paymentProvider,
          returnUrl: returnUrl,
          cardNumber: cardNumber,
          expireDate: expireDate,
          savedCardId: savedCardId,
          test: test,
        )
        .then((res) => CheckoutResult.fromJson(_unwrap(res.data)));
  }

  @override
  Future<List<PromoPass>> getPasses() {
    return _api
        .getPasses()
        .then((res) => _list(res.data).map(PromoPass.fromJson).toList());
  }

  @override
  Future<PromoPass> getPass(String id) {
    return _api
        .getPass(id)
        .then((res) => PromoPass.fromJson(_unwrap(res.data)));
  }

  @override
  Future<PromoEligibility> eligibility({
    required String activityId,
    String? ticketDate,
    num? subtotal,
    int? seats,
    bool isTrial = false,
  }) async {
    try {
      final res = await _api.eligibility(
        activityId: activityId,
        ticketDate: ticketDate,
        subtotal: subtotal,
        seats: seats,
        isTrial: isTrial,
      );
      return PromoEligibility.fromJson(_unwrap(res.data));
    } catch (_) {
      // A booking sheet that cannot answer this just doesn't offer the row.
      // Signed-out callers 401 here, and an older backend 404s — neither is a
      // reason to break a screen someone is trying to pay on.
      return PromoEligibility.none;
    }
  }
}

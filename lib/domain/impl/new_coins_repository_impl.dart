import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';
import 'package:lumi_pass/domain/repo/new_coins/new_coins_api.dart';
import 'package:lumi_pass/domain/repo/new_coins/new_coins_repository.dart';

@Injectable(as: NewCoinsRepository)
class NewCoinsRepositoryImpl extends NewCoinsRepository {
  final NewCoinsApi _api;

  NewCoinsRepositoryImpl(this._api);

  /// The `data:` envelope is not applied consistently across this backend —
  /// unwrap defensively rather than assuming, the same way
  /// `promo_repository_impl.dart` does.
  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is Map && raw['data'] is Map) {
      return Map<String, dynamic>.from(raw['data'] as Map);
    }
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  @override
  Future<NewCoinCatalogue> getCatalogue() {
    return _api
        .getPacks()
        .then((res) => NewCoinCatalogue.fromJson(_unwrap(res.data)));
  }

  @override
  Future<NewCoinBalance> getBalance() {
    return _api
        .getBalance()
        .then((res) => NewCoinBalance.fromJson(_unwrap(res.data)));
  }

  @override
  Future<NewCoinTransactionPage> getTransactions({
    int page = 1,
    int limit = 20,
  }) {
    // NOT unwrapped: here `data` is the list and `meta` sits beside it.
    return _api.getTransactions(page: page, limit: limit).then((res) {
      final raw = res.data;
      return NewCoinTransactionPage.fromJson(
        raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{},
      );
    });
  }

  @override
  Future<NewCoinPurchaseResult> purchasePack(
    String packId, {
    String? lang,
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  }) {
    return _api
        .purchasePack(
          packId,
          lang: lang,
          paymentProvider: paymentProvider,
          returnUrl: returnUrl,
          cardNumber: cardNumber,
          expireDate: expireDate,
          savedCardId: savedCardId,
          test: test,
        )
        .then((res) => NewCoinPurchaseResult.fromJson(_unwrap(res.data)));
  }

  @override
  Future<NewCoinPurchaseResult> purchaseSingle({
    required int quantity,
    String? lang,
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  }) {
    return _api
        .purchaseSingle(
          quantity: quantity,
          lang: lang,
          paymentProvider: paymentProvider,
          returnUrl: returnUrl,
          cardNumber: cardNumber,
          expireDate: expireDate,
          savedCardId: savedCardId,
          test: test,
        )
        .then((res) => NewCoinPurchaseResult.fromJson(_unwrap(res.data)));
  }
}

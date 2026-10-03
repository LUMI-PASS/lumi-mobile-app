import 'package:lumi_pass/data/api_model/new_coins/new_coin_models.dart';

abstract class NewCoinsRepository {
  /// The packs on sale, the loose-coin price and the activity rate.
  Future<NewCoinCatalogue> getCatalogue();

  /// The coins the signed-in user holds, lot by lot.
  Future<NewCoinBalance> getBalance();

  /// One page of the coin ledger, newest first.
  Future<NewCoinTransactionPage> getTransactions(
      {int page = 1, int limit = 20});

  /// Buys a pack.
  ///
  /// The payment tail is the one every other purchase runs: a redirect URL for
  /// Payme/Click/Uzum, a transaction to confirm for a card, and neither of
  /// those for a saved card, which is charged by its own call afterwards.
  Future<NewCoinPurchaseResult> purchasePack(
    String packId, {
    String? lang,
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  });

  /// Buys [quantity] loose coins at the unit price.
  Future<NewCoinPurchaseResult> purchaseSingle({
    required int quantity,
    String? lang,
    String? paymentProvider,
    String? returnUrl,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  });
}

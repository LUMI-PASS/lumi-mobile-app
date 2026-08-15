import 'package:lumi_pass/data/api_model/wallet/cashback_config.dart';
import 'package:lumi_pass/data/api_model/wallet/cashback_preview.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_transaction.dart';

/// One page of the wallet ledger.
class WalletTransactionsPage {
  final List<WalletTransactionModel> items;
  final int page;
  final int totalPages;
  final int total;

  const WalletTransactionsPage({
    required this.items,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
  });

  bool get hasMore => page < totalPages;

  static const empty = WalletTransactionsPage(items: []);
}

abstract class WalletRepository {
  Future<WalletBalance> getWallet();

  Future<WalletTransactionsPage> getTransactions({
    int page = 1,
    int limit = 20,
    String? kind,
  });

  Future<CashbackConfig> getCashbackConfig();

  /// What buying [activityId] for [amount] would earn.
  ///
  /// Never throws: a failed preview resolves to [CashbackPreview.none], which
  /// every earn surface reads as "show nothing". Promising cashback the server
  /// then declines to pay is worse than showing no badge at all.
  Future<CashbackPreview> getCashbackPreview({
    required String activityId,
    String? purchase,
    num? amount,
  });
}

import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/wallet/cashback_config.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_balance.dart';
import 'package:lumi_pass/data/api_model/wallet/wallet_transaction.dart';
import 'package:lumi_pass/domain/repo/wallet/wallet_api.dart';
import 'package:lumi_pass/domain/repo/wallet/wallet_repository.dart';

@Injectable(as: WalletRepository)
class WalletRepositoryImpl extends WalletRepository {
  final WalletApi _api;

  WalletRepositoryImpl(this._api);

  /// The `data:` envelope isn't applied consistently across this backend —
  /// some endpoints wrap, some don't. Unwrap defensively rather than assuming,
  /// the same way `orders_api.dart` does.
  Map<String, dynamic> _unwrap(dynamic raw) {
    if (raw is Map && raw['data'] is Map) {
      return Map<String, dynamic>.from(raw['data'] as Map);
    }
    if (raw is Map) return Map<String, dynamic>.from(raw);
    return <String, dynamic>{};
  }

  @override
  Future<WalletBalance> getWallet() {
    return _api.getWallet().then((res) => WalletBalance.fromJson(_unwrap(res.data)));
  }

  @override
  Future<WalletTransactionsPage> getTransactions({
    int page = 1,
    int limit = 20,
    String? kind,
  }) {
    return _api
        .getTransactions(page: page, limit: limit, kind: kind)
        .then((res) {
      final raw = res.data;
      // This endpoint puts pagination at the root and the rows under `data`,
      // like `GET /orders` — but tolerate a bare list too.
      final List list;
      if (raw is Map && raw['data'] is List) {
        list = raw['data'] as List;
      } else if (raw is List) {
        list = raw;
      } else {
        list = const [];
      }

      int readInt(String key, int fallback) {
        final v = raw is Map ? raw[key] : null;
        if (v is int) return v;
        if (v is num) return v.toInt();
        return int.tryParse('$v') ?? fallback;
      }

      return WalletTransactionsPage(
        items: list
            .whereType<Map>()
            .map((e) =>
                WalletTransactionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        page: readInt('page', page),
        totalPages: readInt('pages', 1),
        total: readInt('total', 0),
      );
    });
  }

  @override
  Future<CashbackConfig> getCashbackConfig() {
    return _api
        .getCashbackConfig()
        .then((res) => CashbackConfig.fromJson(_unwrap(res.data)));
  }
}

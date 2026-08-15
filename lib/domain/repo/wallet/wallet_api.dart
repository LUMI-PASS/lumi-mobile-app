import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';

@injectable
class WalletApi {
  final Dio _dio;

  WalletApi(this._dio);

  /// Balance snapshot for the signed-in user.
  Future<Response> getWallet() {
    return _dio.get('wallet', queryParameters: {'lang': currentLang});
  }

  /// Paginated ledger, newest first. [kind] filters to one entry type; an
  /// unrecognised value is ignored server-side rather than rejected.
  Future<Response> getTransactions({int page = 1, int limit = 20, String? kind}) {
    return _dio.get('wallet/transactions', queryParameters: {
      'page': page,
      'limit': limit,
      if (kind != null && kind.isNotEmpty) 'kind': kind,
      'lang': currentLang,
    });
  }

  /// Public cashback rates. No auth required.
  Future<Response> getCashbackConfig() {
    return _dio.get('cashback/config', queryParameters: {'lang': currentLang});
  }
}

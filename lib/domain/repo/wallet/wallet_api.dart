import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class WalletApi {
  final Dio _dio;

  WalletApi(this._dio);

  /// Balance snapshot for the signed-in user.
  Future<Response> getWallet() {
    return _dio.get('wallet');
  }

  /// Paginated ledger, newest first. [kind] filters to one entry type; an
  /// unrecognised value is ignored server-side rather than rejected.
  Future<Response> getTransactions({int page = 1, int limit = 20, String? kind}) {
    return _dio.get('wallet/transactions', queryParameters: {
      'page': page,
      'limit': limit,
      if (kind != null && kind.isNotEmpty) 'kind': kind,
    });
  }

  /// Public cashback rates. No auth required.
  Future<Response> getCashbackConfig() {
    return _dio.get('cashback/config');
  }

  /// What one specific purchase would earn on [activityId].
  ///
  /// Separate from [getCashbackConfig] because the configured percentage is
  /// only a ceiling request — the real rate depends on the partner's margin on
  /// that class, which only the server knows. [purchase] is `trial` or `full`
  /// on a course and omitted on a plain activity. No auth required: the class
  /// detail screen renders the badge before anyone signs in.
  Future<Response> getCashbackPreview({
    required String activityId,
    String? purchase,
    num? amount,
  }) {
    return _dio.get('cashback/preview', queryParameters: {
      'activity_id': activityId,
      if (purchase != null) 'purchase': purchase,
      if (amount != null) 'amount': amount.round(),
    });
  }
}

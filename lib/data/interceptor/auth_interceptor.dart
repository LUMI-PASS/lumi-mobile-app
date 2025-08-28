import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flexobo/data/base_model/token/tokens.dart';
import 'package:flexobo/data/storage/storage.dart';
import 'package:flexobo/main.dart';
import 'package:injectable/injectable.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/web.dart';

import '../../common/constants/constants.dart';

@lazySingleton
class AuthInterceptor extends QueuedInterceptor {
  final Storage _storage;
  final Logger log;

  AuthInterceptor(this._storage, this.log);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = _storage.tokens.call();

    if (tokens == null) return handler.next(options);

    String? access = tokens.access;
    print("access ::: $access");
    if (access == null) {
      return handler.reject(DioException(requestOptions: options), true);
    }

    options.headers.addAll({'Authorization': 'Bearer $access'});
    options.headers.addAll({
      'x-language-code': navigatorContext.currentContext!.locale.languageCode,
      'x-currency-code': _storage.currencyCode.call() ?? 'usd' ,
    });
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    return handler.next(err);
  }
}

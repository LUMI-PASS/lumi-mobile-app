import 'package:dio/dio.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/web.dart';

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
      // 'x-language-code': navigatorContext.currentContext!.locale.languageCode,
      // 'x-currency-code': _storage.currencyCode.call() ?? 'usd' ,
    });
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await _storage.logout();
      getIt<AppRouter>().replaceAll([LoginRoute()]);
    }
    return handler.next(err);
  }
}

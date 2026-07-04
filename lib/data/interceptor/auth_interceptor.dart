import 'package:dio/dio.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/web.dart';

const _reviewToken =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiNjlmOWZiZDM2Y2M2NTAyNmU2MDBkM2YyIiwiaWF0IjoxNzc4MDQ1OTg5fQ.k4J3TY35bsbk-XZ9QOYxTYFBnx2j0T1zNMe3hmUGyj8';

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
    String? access = tokens?.access;

    if (access == null && RemoteConfigService.instance.isInReview) {
      access = _reviewToken;
    }

    if (access == null) return handler.next(options);

    print("access ::: $access");
    options.headers.addAll({'Authorization': 'Bearer $access'});
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !RemoteConfigService.instance.isInReview) {
      await _storage.logout();
      getIt<AppRouter>().replaceAll([LoginRoute()]);
    }
    return handler.next(err);
  }
}

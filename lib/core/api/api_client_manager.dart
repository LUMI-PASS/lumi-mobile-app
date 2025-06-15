import 'package:lumi_pass/core/api/environment/environment_manager.dart';
import 'package:lumi_pass/core/api/http_inspector.dart';
import 'package:lumi_pass/core/api/interceptor/parse_json_interceptor.dart';
import 'package:lumi_pass/core/api/interceptor/user_session_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@lazySingleton
class ApiClientManager {
  final UserSessionInterceptor _userSessionInterceptor;
  final BaseHttpInspector _httpInspector;
  final EnvironmentManager _environmentManager;

  late final Dio unauthorizedClient = _initUnauthorizedClient();
  late final Dio authorizedClient = _initAuthorizedClient();

  ApiClientManager(
    this._userSessionInterceptor,
    this._httpInspector,
    this._environmentManager,
  );

  Dio _initDioClient() {
    final inspectorInterceptor = _httpInspector.dioInterceptor;
    final baseUrl = _environmentManager.baseUrl;

    return Dio(BaseOptions(baseUrl: baseUrl))
      ..interceptors.addAll([
        if (inspectorInterceptor != null) inspectorInterceptor,
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
        ),
        ParseJsonInterceptor(),
      ]);
  }

  Dio _initAuthorizedClient() {
    return _initDioClient()..interceptors.add(_userSessionInterceptor);
  }

  Dio _initUnauthorizedClient() {
    return _initDioClient();
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/data/interceptor/auth_interceptor.dart';
import 'package:lumi_pass/data/interceptor/connectivity_interceptor.dart';
import 'package:lumi_pass/data/interceptor/interest_source_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@module
abstract class NetworkModule {
  Dio dio(
    AuthInterceptor authInterceptor,
    ConnectivityInterceptor connectivityInterceptor,
    InterestSourceInterceptor interestSourceInterceptor,
  ) {
    final dio = Dio();

    dio.options.baseUrl = RuntimeEnv.baseUrl;

    // Strip U+FFFD (replacement character) at the raw-bytes level — before
    // JSON parsing and before PrettyDioLogger touches the string, so Flutter's
    // debug stdout never encounters the character that crashes it.
    dio.options.responseDecoder = (bytes, _, __) {
      final raw = utf8.decode(bytes, allowMalformed: true);
      return raw.replaceAll('�', '');
    };

    // Order matters: errors this one forwards (e.g. a 401 on a retried
    // request) must still reach AuthInterceptor.onError, which runs after it.
    dio.interceptors.add(connectivityInterceptor);
    dio.interceptors.add(authInterceptor);
    // After auth, so a request retried with a refreshed token still carries the
    // screen it was made from — the backend records interest off these GETs.
    dio.interceptors.add(interestSourceInterceptor);

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: kDebugMode,
        requestBody: kDebugMode,
        responseBody: kDebugMode,
        responseHeader: kDebugMode,
        error: kDebugMode,
        compact: true,
        maxWidth: 90,
      ),
    );

    return dio;
  }
}

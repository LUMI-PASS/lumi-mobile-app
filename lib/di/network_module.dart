import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/data/interceptor/auth_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

@module
abstract class NetworkModule {
  Dio dio(AuthInterceptor authInterceptor) {
    final dio = Dio();

    dio.options.baseUrl = RuntimeEnv.baseUrl;

    // Strip U+FFFD (replacement character) at the raw-bytes level — before
    // JSON parsing and before PrettyDioLogger touches the string, so Flutter's
    // debug stdout never encounters the character that crashes it.
    dio.options.responseDecoder = (bytes, _, __) {
      final raw = utf8.decode(bytes, allowMalformed: true);
      return raw.replaceAll('�', '');
    };

    dio.interceptors.add(authInterceptor);

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

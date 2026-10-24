import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:lumi_pass/common/env/runtime_env.dart';
import 'package:lumi_pass/data/interceptor/auth_interceptor.dart';
import 'package:lumi_pass/data/interceptor/connectivity_interceptor.dart';
import 'package:lumi_pass/data/interceptor/interest_source_interceptor.dart';
import 'package:lumi_pass/data/interceptor/lang_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Longest response body the debug log prints before cutting it off.
const _maxLoggedBody = 4000;

@module
abstract class NetworkModule {
  Dio dio(
    AuthInterceptor authInterceptor,
    ConnectivityInterceptor connectivityInterceptor,
    InterestSourceInterceptor interestSourceInterceptor,
    LangInterceptor langInterceptor,
  ) {
    final dio = Dio();

    dio.options.baseUrl = RuntimeEnv.baseUrl;

    // Strip U+FFFD (replacement character) at the raw-bytes level — before
    // JSON parsing and before PrettyDioLogger touches the string, so Flutter's
    // debug stdout never encounters the character that crashes it.
    dio.options.responseDecoder = (bytes, options, __) {
      final raw = utf8.decode(bytes, allowMalformed: true).replaceAll('�', '');
      // PrettyDioLogger's responseBody is off (see below), so the body is
      // logged here instead, in debug only: the raw string is already in hand,
      // and capping it costs nothing, unlike pretty-printing the parsed map.
      if (kDebugMode) {
        final body = raw.length > _maxLoggedBody
            ? '${raw.substring(0, _maxLoggedBody)}… (${raw.length} chars)'
            : raw;
        debugPrint('[HTTP body] ${options.method} ${options.uri}\n$body');
      }
      return raw;
    };

    // Order matters: errors this one forwards (e.g. a 401 on a retried
    // request) must still reach AuthInterceptor.onError, which runs after it.
    dio.interceptors.add(connectivityInterceptor);
    dio.interceptors.add(authInterceptor);
    // After auth, so a request retried with a refreshed token still carries the
    // screen it was made from — the backend records interest off these GETs.
    dio.interceptors.add(interestSourceInterceptor);
    dio.interceptors.add(langInterceptor);

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: kDebugMode,
        requestBody: kDebugMode,
        // Some detail responses contain hundreds of expanded course lessons.
        // Pretty-printing those maps is synchronous and can block Flutter's
        // UI isolate for multiple frames on a phone. Status, URL and timing
        // remain logged; error responses still include their body.
        responseBody: false,
        responseHeader: kDebugMode,
        error: kDebugMode,
        compact: true,
        maxWidth: 90,
      ),
    );

    return dio;
  }
}

import 'dart:convert';

import 'package:lumi_pass/core/logging/logger.dart';
import 'package:dio/dio.dart';

class ParseJsonInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final responseData = response.data.toString();

    if (responseData.contains('\\"')) {
      // Replace \" with just " to avoid decoding errors
      String sanitizedJsonString = responseData.replaceAll(r'\"', '"');
      // Decode the sanitized JSON string
      try {
        response.data = jsonDecode(sanitizedJsonString);
      } catch (e) {
        logger.e(e);
      }
    }

    super.onResponse(response, handler);
  }
}

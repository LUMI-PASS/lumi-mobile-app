import 'package:dio/dio.dart';

/// Strips U+FFFD (replacement character) from all string values in API
/// responses. The backend occasionally sends corrupted emoji bytes that Dart
/// decodes to �, which triggers a Flutter debug-mode assertion.
class SanitizeInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    response.data = _sanitize(response.data);
    handler.next(response);
  }

  dynamic _sanitize(dynamic value) {
    if (value is String) return value.replaceAll('�', '');
    if (value is Map) {
      return <String, dynamic>{
        for (final e in value.entries) e.key.toString(): _sanitize(e.value),
      };
    }
    if (value is List) return value.map(_sanitize).toList();
    return value;
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/di/injection.dart';

/// Turns a lost connection into a blocking full-screen state instead of a
/// failed request: on a connection error the user sees `ConnectionErrorPage`,
/// and tapping "retry" re-fires the original request — as many times as it
/// takes. The caller's `Future` stays pending across all of that, so cubits
/// need no no-internet branch; a request either eventually succeeds or fails
/// for some reason other than connectivity.
///
/// Must be registered *before* [AuthInterceptor] so that errors it forwards
/// (including a 401 on a retried request) still reach the auth handling.
@lazySingleton
class ConnectivityInterceptor extends Interceptor {
  /// Retries go out on a bare [Dio] rather than the app's instance, which would
  /// be a DI cycle (the app's Dio owns this interceptor). Nothing is lost:
  /// [RequestOptions] already carries the base URL, the response decoder and
  /// the `Authorization` header applied on the first attempt.
  final Dio _retryClient = Dio();

  /// Result of the connection error screen that is currently visible (or being
  /// pushed).
  ///
  /// Several requests failing at once collapse onto a single screen instead of
  /// stacking duplicates; they all retry together once the user taps "retry".
  Future<bool>? _pendingErrorResult;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    var error = err;

    while (_isConnectivityError(error)) {
      final retry = await _showConnectionError();
      if (!retry) break;

      try {
        final response = await _retryClient.fetch<dynamic>(
          _replayable(error.requestOptions),
        );
        return handler.resolve(response);
      } on DioException catch (e) {
        // Still offline — loop and show the screen again. Any other failure is
        // a real error and belongs to the caller.
        error = e;
      }
    }

    return handler.next(error);
  }

  /// Pushes the error screen, or joins the one already on screen. A `null`
  /// result (system back rather than the retry button) counts as a retry.
  Future<bool> _showConnectionError() {
    final pending = _pendingErrorResult;
    if (pending != null) return pending;

    final future = getIt<AppRouter>()
        .push<bool>(const ConnectionErrorRoute())
        .then((value) => value ?? true);
    _pendingErrorResult = future;

    return future.whenComplete(() => _pendingErrorResult = null);
  }

  /// A [FormData] body is a one-shot stream — the failed attempt consumed it,
  /// so a replay needs a fresh clone.
  RequestOptions _replayable(RequestOptions options) {
    final data = options.data;
    if (data is! FormData) return options;
    return options.copyWith(data: data.clone());
  }

  bool _isConnectivityError(DioException err) =>
      err.type == DioExceptionType.connectionError ||
      err.type == DioExceptionType.connectionTimeout ||
      err.error is SocketException;
}

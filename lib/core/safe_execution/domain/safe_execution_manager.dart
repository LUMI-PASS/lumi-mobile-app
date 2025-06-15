import 'dart:async';

import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/connectivity_handler.dart';
import 'package:injectable/injectable.dart';

typedef ExecutiveFunction<DomainModel> = Future<DomainModel> Function();

@Injectable()
class SafeExecutionManager {
  final ConnectivityHandler _connectivityHandler;

  SafeExecutionManager(this._connectivityHandler);

  Future<T> makeAsyncSafeExecution<T>({
    required ExecutiveFunction<T> function,
  }) async {
    Future<T> repeatSafeExecution() {
      return makeAsyncSafeExecution(
        function: function,
      );
    }

    try {
      return await function();
    } on NoInternetConnectionChessException catch (e) {
      // Here we can add any specific Exceptions to catch
      await _connectivityHandler.handleConnectivityException(e);

      return repeatSafeExecution();
    } on UnauthorizedChessException catch (e) {
      throw _connectivityHandler.handleUnauthorizedException(e);
    }
  }
}

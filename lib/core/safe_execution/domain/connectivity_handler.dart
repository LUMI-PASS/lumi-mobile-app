import 'package:lumi_pass/core/error/chess_exception.dart';

abstract interface class ConnectivityHandler {
  Future<bool> handleConnectivityException(
    NoInternetConnectionChessException exception,
  );

  Future<void> handleUnauthorizedException(
    UnauthorizedChessException exception,
  );
}

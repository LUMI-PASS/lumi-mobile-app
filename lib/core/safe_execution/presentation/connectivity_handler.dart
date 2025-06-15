import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/connectivity_handler.dart';
import 'package:founders_academy/feature/auth/domain/user_session_manager.dart';
import 'package:founders_academy/routing/app_router.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: ConnectivityHandler)
class AutoRouteConnectivtyHandler implements ConnectivityHandler {
  final AppRouter _appRouter;
  final UserSessionManager _userSessionManager;

  AutoRouteConnectivtyHandler(this._appRouter, this._userSessionManager);

  @override
  Future<bool> handleConnectivityException(
    NoInternetConnectionChessException exception,
  ) async {
    final result =
        await _appRouter.push<bool>(const ConnectionErrorRoute()) ?? true;

    return result;
  }

  @override
  Future<void> handleUnauthorizedException(
      UnauthorizedChessException exception) async {
    await _userSessionManager.clearUserSession();
    _appRouter.replaceAll([const UnauthorizedContainerRoute()]);
  }
}

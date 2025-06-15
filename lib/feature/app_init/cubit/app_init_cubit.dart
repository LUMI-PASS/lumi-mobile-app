
import 'package:lumi_pass/core/version/version_manager.dart';
import 'package:lumi_pass/feature/auth/domain/user_session_manager.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

import 'app_init_state.dart';

@Injectable()
class AppInitCubit extends ChessCubit<AppInitState> {
  final UserSessionManager _userSessionManager;
  final VersionManager _versionManager;

  AppInitCubit(
    this._userSessionManager,
    this._versionManager,
  ) : super(const AppInitLoadingState());

  Future<void> checkAuth() async {
    // await _versionManager.init();
    await Future.delayed(const Duration(seconds: 2));
    final isFirstRun = await _userSessionManager.isFirstRun();

    if (isFirstRun) {
      await _userSessionManager.clearUserSession();
    }

    final loggedIn = await _userSessionManager.isUserLoggedIn();
    final userId = await _userSessionManager.getUserId();

    // if (_versionManager.isNavigateToNotificationPage()) {
    //   safeEmit(const NeedForceUpdateState());
    //   return;
    // }

    if (loggedIn && userId != null) {
      safeEmit(const AuthorizedState());
    } else {
      safeEmit(const UnauthorizedState());
    }
  }
}

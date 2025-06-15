import 'package:founders_academy/core/push_notification/push_notification_manager.dart';
import 'package:founders_academy/core/version/version_manager.dart';
import 'package:flutter/material.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'main_state.dart';

@Injectable()
class MainCubit extends ChessCubit<MainState> {
  final VersionManager _versionManager;
  final PushNotificationManager _notificationManager;

  MainCubit(
    this._versionManager,
    this._notificationManager,
  ) : super(const MainInitialState());

  Future<void> init(BuildContext context, VoidCallback onBackTap) async {
    await _notificationManager.initializeNotification();
    await _versionManager.init().then((value) {
      _checkForUpdates(context, onBackTap);
    });
  }

  Future<void> _checkForUpdates(
      BuildContext context, VoidCallback onBackTap) async {
    _versionManager.checkUpdateAndShowIfNeeded(context, onBackTap);
  }
}

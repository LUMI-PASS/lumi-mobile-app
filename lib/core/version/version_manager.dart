import 'package:lumi_pass/core/firebase/firebase_remote_config_keys.dart';
import 'package:lumi_pass/core/firebase/firebase_remote_config_manager.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

@Injectable()
class VersionManager {
  final FirebaseRemoteConfigManager _firebaseRemoteConfigManager;

  VersionManager(this._firebaseRemoteConfigManager);

  Version? localVersion;
  Version? minimumSupportedVersion;
  Version? currentAppVersion;

  bool isNotificationBottomSheetShowed = false;

  Future<void> init() async {
    _firebaseRemoteConfigManager.fetchRemoteConfigurations();
    _getAppVersions();
  }

  Future<void> _getAppVersions() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    localVersion = Version.parse(packageInfo.version);

    minimumSupportedVersion = _getVersion(
      _firebaseRemoteConfigManager.firebaseRemoteConfig
          .getString(FirebaseRemoteConfigKeys.minimumSupportedAppVersion),
    );
    currentAppVersion = _getVersion(
      _firebaseRemoteConfigManager.firebaseRemoteConfig
          .getString(FirebaseRemoteConfigKeys.currentAppVersion),
    );
  }

  bool isNavigateToNotificationPage() {
    return localVersion != null && minimumSupportedVersion != null
        ? localVersion! < minimumSupportedVersion
        : true;
  }

  bool isShowNotificationBottomSheet() {
    return localVersion != null &&
            minimumSupportedVersion != null &&
            currentAppVersion != null
        ? localVersion! > minimumSupportedVersion &&
            localVersion! < currentAppVersion &&
            !isNotificationBottomSheetShowed
        : true;
  }

  Future<void> onUpdateTap() async {
    final storeLink = _firebaseRemoteConfigManager.firebaseRemoteConfig
        .getString(FirebaseRemoteConfigKeys.applicationStoreLink);
    // redirect to store
    ChessUrlLauncher.launch(
      url: storeLink,
      onError: (_) {
        throw 'Could not launch $storeLink';
      },
    );
  }

  void checkUpdateAndShowIfNeeded(
      BuildContext context, VoidCallback onBackTap) {
    if (isShowNotificationBottomSheet()) {
      isNotificationBottomSheetShowed = true;

      ChessNativeDialog.showNotificationDialog(
        context: context,
        title: "Ilovani yangilang",
        message:
            "Qulaylik yaratish maqsadida biz yangi xususiyatlarni qo'shdik va ba'zi muammolarni to'g'irladik",
        onConfirm: onUpdateTap,
        onBackTap: onBackTap,
      );
    }
  }

  Version _getVersion(String versionString) {
    return versionString.isEmpty
        ? Version.parse('0')
        : Version.parse(versionString);
  }
}

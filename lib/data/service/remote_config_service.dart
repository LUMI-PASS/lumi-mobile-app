import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService _instance = RemoteConfigService._();
  static RemoteConfigService get instance => _instance;

  FirebaseRemoteConfig? _remoteConfig;
  String _currentVersion = '';
  bool _initialized = false;

  bool get isInReview {
    if (!_initialized || _remoteConfig == null) return false;
    final reviewVersion = _remoteConfig!.getString('is_in_review').trim();
    return reviewVersion.isNotEmpty && reviewVersion == _currentVersion;
  }

  Future<void> init() async {
    if (_initialized) return;

    final packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig?.setDefaults({'is_in_review': ''});

      await _remoteConfig?.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 5),
      ));

      await _remoteConfig?.fetchAndActivate();
    } catch (_) {}

    _initialized = true;
  }
}

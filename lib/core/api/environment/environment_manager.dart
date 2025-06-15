import 'package:founders_academy/core/firebase/firebase_remote_config_keys.dart';
import 'package:founders_academy/core/firebase/firebase_remote_config_manager.dart';
import 'package:injectable/injectable.dart';

const _defaultBaseUrl = 'https://api.sg.glmv.dev';

@Injectable()
class EnvironmentManager {
  // final FirebaseRemoteConfigManager _firebaseRemoteConfigManager;

  // EnvironmentManager(
  //   this._firebaseRemoteConfigManager,
  // );

  // Future<void> init() async {
  //   await _firebaseRemoteConfigManager.fetchRemoteConfigurations();
  // }

  String get baseUrl {
    // final baseUrl = _firebaseRemoteConfigManager.firebaseRemoteConfig
    //     .getString(FirebaseRemoteConfigKeys.baseUrl);

    // if (baseUrl.isNotEmpty) {
      return "https://api.sg-academy.qisqa.link";
    // } else {
    //   return _defaultBaseUrl;
    // }
  }
}

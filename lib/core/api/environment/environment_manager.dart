
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
      return "http://35.209.62.223:80";
    // } else {
    //   return _defaultBaseUrl;
    // }
  }
}

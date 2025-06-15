import 'package:founders_academy/core/logging/logger.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class FirebaseRemoteConfigManager {
  @LazySingleton()
  FirebaseRemoteConfig get firebaseRemoteConfig =>
      FirebaseRemoteConfig.instance;

  FirebaseRemoteConfigManager();

  Future<void> fetchRemoteConfigurations() async {
    await firebaseRemoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    await firebaseRemoteConfig.fetchAndActivate().onError((error, stackTrace) {
      logger.e(error.toString(), stackTrace: stackTrace);

      return false;
    });
  }
}

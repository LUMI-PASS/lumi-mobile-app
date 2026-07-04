import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/service/deeplink_service.dart';
import 'package:lumi_pass/data/service/push_notification_manager.dart';
import 'package:lumi_pass/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
  getIt.registerLazySingleton(() => AppRouter());
  getIt.registerLazySingleton(() => PushNotificationManager(getIt<AppRouter>()));
  getIt.registerLazySingleton(() => DeeplinkService(getIt<AppRouter>()));
}

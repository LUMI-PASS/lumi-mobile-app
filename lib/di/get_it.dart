import 'package:founders_academy/di/get_it.config.dart';
import 'package:founders_academy/routing/app_router.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final getIt = GetIt.instance;

@InjectableInit(
  asExtension: true,
)
Future configureDependencies() async {
  await getIt.init();
  // getIt.registerLazySingleton(() => AppRouter());
}

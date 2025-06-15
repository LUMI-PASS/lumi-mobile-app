import 'package:lumi_pass/di/get_it.config.dart';
import 'package:lumi_pass/routing/app_router.dart';
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

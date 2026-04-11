import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/fixed_csv_asset_loader.dart';
import 'package:lumi_pass/common/widget/display/display_widget.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/firebase_options.dart';

import 'common/base/base_page.dart';
import 'common/router/app_router.dart';
import 'data/base_model/material_colors.dart';
import 'presentation/app/cubit/app_cubit.dart';
import 'presentation/app/cubit/app_state.dart';

final navigatorContext = getIt<AppRouter>().navigatorKey;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await RemoteConfigService.instance.init();
  await configureDependencies();
  // Initialize language for API calls if not yet set
  initLangIfNeeded('en');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then(
    (value) => runApp(
      EasyLocalization(
        supportedLocales: Strings.supportedLocales,
        path: 'assets/localization/translations.csv',
        assetLoader: FixedCsvAssetLoader(),
        startLocale: const Locale('uz', 'UZ'),
        fallbackLocale: const Locale('uz', 'UZ'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends BasePage<AppCubit, AppBuildable, AppListenable> {
  const MyApp({super.key});

  @override
  void init(BuildContext context) {
    super.init(context);
  }

  @override
  Widget builder(BuildContext context, state) {
    return DisplayWidget(
      child: ScreenUtilInit(
        designSize: const Size(414, 896),
        child: MaterialApp.router(
          title: 'lumi_pass',
          debugShowCheckedModeBanner: false,
          routerConfig: getIt<AppRouter>().config(),
          color: context.colors.primary,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: ThemeData(
            fontFamily: 'Onest',
            useMaterial3: false,
            primarySwatch: MaterialColors.vividCerulean,
            primaryColor: context.colors.primary,
            scaffoldBackgroundColor: context.colors.window,
            shadowColor: context.colors.onPrimary,
            highlightColor: context.colors.onPrimary,
          ),
        ),
      ),
    );
  }
}

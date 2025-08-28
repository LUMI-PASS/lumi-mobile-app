import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexobo/common/extensions/theme_extensions.dart';
import 'package:flexobo/common/widget/display/display_widget.dart';
import 'package:flexobo/di/injection.dart';
import 'package:flexobo/presentation/app/main/subscreens/search/provider/search_provider.dart';
import 'package:flexobo/presentation/profile/language/lang/language_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'common/base/base_page.dart';
import 'common/gen/assets.gen.dart';
import 'common/gen/strings.dart';
import 'common/router/app_router.dart';
import 'common/utils/fixed_csv_asset_loader.dart';
import 'data/base_model/material_colors.dart';
import 'firebase_options.dart';
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
  await configureDependencies();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => SearchProvider()),
        ],
        child: Phoenix(
          child: EasyLocalization(
            supportedLocales: Strings.supportedLocales,
            path: Assets.localization.translations,
            fallbackLocale: Strings.supportedLocales.first,
            startLocale: Strings.supportedLocales.first,
            assetLoader: FixedCsvAssetLoader(),

            child: const MyApp(),
            // ),
          ),
        ),
        // )
      )));
}

class MyApp extends BasePage<AppCubit, AppBuildable, AppListenable> {
  const MyApp({super.key});

  @override
  void init(BuildContext context) {
    Future.delayed(Duration.zero).then((value) {
      context.read<AppCubit>().firebaseInit();
    });

    super.init(context);
  }

  @override
  Widget builder(BuildContext context, state) {
    return DisplayWidget(
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        child: StreamBuilder<Locale>(
            stream: LanguageService().localeStream,
            builder: (context, snapshot) {
              return MaterialApp.router(
                key: ValueKey<String>(state.language?.name ?? ''),
                title: 'Flexobo',
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
              );
            }),
      ),
    );
  }
}

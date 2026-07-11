import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/fixed_csv_asset_loader.dart';
import 'package:lumi_pass/common/widget/display/display_widget.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/data/service/deeplink_service.dart';
import 'package:lumi_pass/data/service/push_notification_manager.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/common/styles/theme_mode_notifier.dart';
import 'package:lumi_pass/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/base/base_page.dart';
import 'common/env/app_env.dart';
import 'common/env/runtime_env.dart';
import 'common/router/app_router.dart';
import 'common/widget/theme_transition_overlay.dart';
import 'data/base_model/material_colors.dart';
import 'presentation/app/cubit/app_cubit.dart';
import 'presentation/app/cubit/app_state.dart';

// Ensures EasyLocalization defaults to uz_UZ on first launch instead of
// picking up the device locale (which may be English on test/dev devices).
Future<void> _seedDefaultLocale() async {
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('locale')) {
    await prefs.setString('locale', 'uz_UZ');
  }
}

// ─── FCM background handler (must be top-level, annotated vm:entry-point) ────

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // ignore: avoid_print
  print(
      '[FCM] background — title:${message.notification?.title} data:${message.data}');
}

// ─── Native deep-link interceptor ────────────────────────────────────────────
// Prevents auto_route from processing lumi:// and /share/class/ URLs itself.
// DeeplinkService handles the actual navigation; auto_route just sees the normal
// root route so the InitialGuard runs and the app starts cleanly.

DeepLink _nativeDeepLink(PlatformDeepLink link) {
  final uri = link.uri;
  if (uri.scheme == 'lumi' ||
      (uri.host == 'mobile-api.lumipass.uz' &&
          uri.path.contains('/share/class/'))) {
    return DeepLink.single(EmptyRouterRoute());
  }
  return link;
}

// ─── Web deep-link helper ─────────────────────────────────────────────────────

bool _webInitialNavDone = false;

DeepLink _initialWebDeepLink(PlatformDeepLink link) {
  // ignore: avoid_print
  print('[lumi] deepLink uri: ${link.uri}');
  if (_webInitialNavDone) return link;
  _webInitialNavDone = true;
  try {
    final storage = getIt<Storage>();
    final showOnboard = storage.showOnboard();
    final token = storage.tokens();
    final inReview = RemoteConfigService.instance.isInReview;
    if (showOnboard != false) return DeepLink.single(OnboardingRoute());
    if (token != null || inReview) return DeepLink.single(const MainRoute());
    return DeepLink.single(LoginRoute());
  } catch (e) {
    // ignore: avoid_print
    print('[lumi] deepLink resolve error: $e');
    return DeepLink.single(LoginRoute());
  }
}

// ─── Entry points ─────────────────────────────────────────────────────────────

void main() async {
  if (kIsWeb) {
    await _runWeb();
  } else {
    await _runNative();
  }
}

Future<void> _runWeb() async {
  runZonedGuarded(() async {
    // ignore: avoid_print
    void log(String msg) => print('[lumi] $msg');

    FlutterError.onError = (d) {
      // ignore: avoid_print
      print('[lumi] FlutterError: ${d.exceptionAsString()}');
    };

    try {
      log('1 binding');
      WidgetsFlutterBinding.ensureInitialized();

      log('2 localization');
      await EasyLocalization.ensureInitialized();
      await _seedDefaultLocale();

      log('3 firebase');
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      log('4 remoteconfig');
      await RemoteConfigService.instance.init();

      log('5 runtime env');
      await RuntimeEnv.load();

      log('6 di');
      await configureDependencies();
      initThemeMode();

      log('7 locale');
      initLangIfNeeded('uz');

      log('8 runApp');
      runApp(
        EasyLocalization(
          supportedLocales: Strings.supportedLocales,
          path: 'assets/localization/translations.csv',
          assetLoader: FixedCsvAssetLoader(),
          startLocale: const Locale('uz', 'UZ'),
          fallbackLocale: const Locale('uz', 'UZ'),
          child: const MyApp(),
        ),
      );
      log('done');
    } catch (e, st) {
      // ignore: avoid_print
      print('[lumi] CRASH at step: $e');
      // ignore: avoid_print
      print('[lumi] STACK: $st');
    }
  }, (e, st) {
    // ignore: avoid_print
    print('[lumi] ZONE ERROR: $e');
    // ignore: avoid_print
    print('[lumi] ZONE STACK: $st');
  });
}

Future<void> _runNative() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await _seedDefaultLocale();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await RemoteConfigService.instance.init();
  await RuntimeEnv.load();
  await configureDependencies();
  initThemeMode();

  // Do NOT await — getInitialMessage() inside requires the Flutter plugin to
  // be registered, which only happens after runApp() with
  // FlutterImplicitEngineDelegate. Fire and forget; all listeners are wired
  // up synchronously before runApp returns, so no messages are missed.
  unawaited(getIt<PushNotificationManager>().initializeNotification());
  unawaited(getIt<DeeplinkService>().init());

  initLangIfNeeded('uz');
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    EasyLocalization(
      supportedLocales: Strings.supportedLocales,
      path: 'assets/localization/translations.csv',
      assetLoader: FixedCsvAssetLoader(),
      startLocale: const Locale('uz', 'UZ'),
      fallbackLocale: const Locale('uz', 'UZ'),
      child: const MyApp(),
    ),
  );
}

// ─── App widget ───────────────────────────────────────────────────────────────

class _LumiScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
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
        // The user's theme override drives `themeMode`; `AppColorScheme` rides
        // along on `ThemeData.extensions`, so every `context.colors` lookup —
        // and its lerp on switch — follows from here.
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) => MaterialApp.router(
            title: AppEnv.isDev ? 'Lumi [DEV]' : 'lumi_pass',
            debugShowCheckedModeBanner: AppEnv.isDev,
            routerConfig: getIt<AppRouter>().config(
              deepLinkBuilder: kIsWeb ? _initialWebDeepLink : _nativeDeepLink,
            ),
            scrollBehavior: _LumiScrollBehavior(),
            // Innermost wrapper on purpose: the theme flips above it, so the
            // tree under its RepaintBoundary repaints with the new colors while
            // the stale snapshot is still being clipped away on top.
            builder: (context, child) => Listener(
              // Translucent so the tap still reaches whatever was hit; this only
              // rides along to drop the keyboard on any pointer down.
              behavior: HitTestBehavior.translucent,
              onPointerDown: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              child: ThemeTransitionOverlay(
                child: child ?? const SizedBox.shrink(),
              ),
            ),
            color: AppColorScheme.light.primary,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            theme: _themeFrom(AppColorScheme.light),
            darkTheme: _themeFrom(AppColorScheme.dark),
            themeMode: mode,
          ),
        ),
      ),
    );
  }

  ThemeData _themeFrom(AppColorScheme colors) => ThemeData(
        fontFamily: 'Onest',
        useMaterial3: false,
        brightness: colors.brightness,
        primarySwatch: MaterialColors.vividCerulean,
        primaryColor: colors.primary,
        scaffoldBackgroundColor: colors.scaffoldBg,
        shadowColor: colors.onPrimary,
        highlightColor: colors.onPrimary,
        extensions: [colors],
      );
}

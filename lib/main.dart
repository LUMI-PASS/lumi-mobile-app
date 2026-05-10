import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/fixed_csv_asset_loader.dart';
import 'package:lumi_pass/common/widget/display/display_widget.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/firebase_options.dart';

import 'common/base/base_page.dart';
import 'common/router/app_router.dart';
import 'data/base_model/material_colors.dart';
import 'presentation/app/cubit/app_cubit.dart';
import 'presentation/app/cubit/app_state.dart';

final navigatorContext = getIt<AppRouter>().navigatorKey;

// ─── Push notification helpers ──────────────────────────────────────────────

const _kChannelId = 'lumi_channel';
const _kChannelName = 'Lumi Notifications';

final _localNotifications = FlutterLocalNotificationsPlugin();

Future<void> _initLocalNotifications() async {
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  const ios = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  await _localNotifications.initialize(
    const InitializationSettings(android: android, iOS: ios),
    onDidReceiveNotificationResponse: _onLocalNotificationTap,
  );
  await _localNotifications
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        _kChannelId,
        _kChannelName,
        importance: Importance.high,
      ));
}

void _onLocalNotificationTap(NotificationResponse response) {
  _navigateForNotification(response.payload ?? '');
}

void _navigateForNotification(String type) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final ctx = navigatorContext.currentContext;
    if (ctx == null) return;
    ctx.router.navigate(const CalendarRoute());
  });
}

Future<void> _showForegroundNotification(RemoteMessage message) async {
  final n = message.notification;
  if (n == null) return;
  await _localNotifications.show(
    n.hashCode,
    n.title,
    n.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        _kChannelId,
        _kChannelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: message.data['type'] as String? ?? '',
  );
}

// One-shot flag: override the first (Telegram launch) URL with the correct
// app route; pass all subsequent URL changes through unchanged.
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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

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

      log('3 firebase');
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      log('4 remoteconfig');
      await RemoteConfigService.instance.init();

      log('5 di');
      await configureDependencies();

      log('6 locale');
      initLangIfNeeded('en');

      log('7 runApp');
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initLocalNotifications();

  // iOS: show notification banner even when app is in foreground
  if (Platform.isIOS) {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Android: show a local notification when message arrives in foreground
  FirebaseMessaging.onMessage.listen((message) async {
    if (Platform.isAndroid) {
      await _showForegroundNotification(message);
    }
  });

  // Navigate to Calendar when user taps a notification (app was in background)
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    _navigateForNotification(message.data['type'] as String? ?? '');
  });

  await RemoteConfigService.instance.init();
  await configureDependencies();
  initLangIfNeeded('en');
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
        child: MaterialApp.router(
          title: 'lumi_pass',
          debugShowCheckedModeBanner: false,
          routerConfig: getIt<AppRouter>().config(
            deepLinkBuilder: kIsWeb ? _initialWebDeepLink : null,
          ),
          scrollBehavior: _LumiScrollBehavior(),
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

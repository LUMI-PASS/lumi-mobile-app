import 'dart:async';

import 'package:flutter/services.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/di/get_it.dart';
import 'package:chess_ui_kit/chess_ui_kit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ),
  );
  runGuardedApp(const App());
}

void runGuardedApp(Widget app) async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      // await Firebase.initializeApp(
      //   options: DefaultFirebaseOptions.currentPlatform,
      // );
      // FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
      await ChessIntl.initialize();
      await configureDependencies();
    } catch (e) {
      logger.e(e);
    }

    // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    runApp(app);
  }, (exception, stackTrace) async {
    // if (!kDebugMode) {
    //   FirebaseCrashlytics.instance.recordError(
    //     exception,
    //     stackTrace,
    //     fatal: true,
    //   );
    // }
  });
}

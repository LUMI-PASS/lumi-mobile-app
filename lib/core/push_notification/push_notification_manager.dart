import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/feature/shared/data/data_source/local_data_source/fcm_data_source.dart';
import 'package:founders_academy/routing/app_router.dart';
import 'package:founders_academy/routing/app_router.gr.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

@Injectable()
class PushNotificationManager {
  final AppRouter _appRouter;
  final FcmDataSource _fcmDataSource;

  PushNotificationManager(this._fcmDataSource, this._appRouter);

  @LazySingleton()
  FirebaseMessaging get _firebaseMessaging => FirebaseMessaging.instance;

  @LazySingleton()
  FlutterLocalNotificationsPlugin get _notification =>
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotification() async {
    try {
      await _requestPermissions();
      await _initializeFirebaseToken();
      await _initializeLocalNotifications();
      await _initializeNotificationRoute();
      _setupMessageHandlers();
    } on UnknownChessException catch (exception) {
      throw UnknownChessException(exception.message);
    } catch (e) {
      throw Exception('Failed to initialize notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    final PermissionStatus status = await Permission.notification.status;

    if (!status.isGranted) {
      await _firebaseMessaging.requestPermission();
    }
  }

  Future<void> _initializeFirebaseToken() async {
    try {
      final String? storedToken = await _fcmDataSource.getToken();
      String? apnsToken;

      if (Platform.isIOS) {
        while (apnsToken == null) {
          apnsToken = await _firebaseMessaging.getAPNSToken();
          if (apnsToken == null) {
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }

      final String? fcmToken = await _firebaseMessaging.getToken();

      if (fcmToken != null && storedToken != fcmToken) {
        await _fcmDataSource.saveToken(fcmToken);
      }

      _firebaseMessaging.onTokenRefresh.listen((String newToken) async {
        if (newToken != storedToken) {
          await _fcmDataSource.saveToken(newToken);
        }
      });
    } on ChessException catch (e) {
      logger.e(e);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    final initializationSettings = _getInitializationSettings();

    await _notification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (message) {
        final payload = message.payload;
        if (payload != null) {
          final data = jsonDecode(payload) as Map<String, dynamic>;
          _handleMessage(RemoteMessage(data: data));
        }
      },
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _setupMessageHandlers() {
    FirebaseMessaging.onBackgroundMessage(_onDidReceiveNotification);
    FirebaseMessaging.onMessage.listen(_onDidReceiveNotification);
  }

  InitializationSettings _getInitializationSettings() {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher_round',
    );

    final iosSettings = DarwinInitializationSettings(
      // onDidReceiveLocalNotification: (id, title, body, payload) {
      //   _onDidReceiveNotification(
      //     RemoteMessage(
      //       messageId: id.toString(),
      //       notification: RemoteNotification(
      //         title: title,
      //         body: body,
      //       ),
      //     ),
      //   );
      // },
    );

    return InitializationSettings(
      android: Platform.isAndroid ? androidSettings : null,
      iOS: Platform.isIOS ? iosSettings : null,
    );
  }

  @pragma('vm:entry-point')
  Future<void> _onDidReceiveNotification(RemoteMessage message) async {
    final notificationDetails = _getPlatformChannelSpecifics();

    await _notification.show(
      message.messageId.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  NotificationDetails _getPlatformChannelSpecifics() {
    const androidDetails = AndroidNotificationDetails(
      'startupgarage_notification_channel',
      'Startup Garage',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );

    const iosDetails = DarwinNotificationDetails();

    return NotificationDetails(
      android: Platform.isAndroid ? androidDetails : null,
      iOS: Platform.isIOS ? iosDetails : null,
    );
  }

  Future<void> _initializeNotificationRoute() async {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    _firebaseMessaging.getInitialMessage().then((value) {
      if (value != null) _handleMessage(value);
    });
  }

  void _handleMessage(RemoteMessage message) {
    String? type = message.data['type'];

    if (type != null) {
      _navigateToRoute(type: type, data: message.data);
    }
  }

  void _navigateToRoute({required String type, Map<String, dynamic>? data}) {
    if (data == null) return;

    final id = data["entity_id"];

    switch (type) {
      case 'afisha':
        _appRouter.push(AfishaDetailsRoute(id: id));
        break;
      case 'review':
        _appRouter.push(ReviewMatchDetailsRoute(id: id));
        break;
      case 'news':
        _appRouter.push(NewsDetailsRoute(id: id));
        break;
      case 'grandmaster':
        _appRouter.push(GrandmasterDetailsRoute(id: id));
        break;
      case 'book':
        _appRouter.push(BookDetailsRoute(id: id));
        break;

      default:
    }
  }
}

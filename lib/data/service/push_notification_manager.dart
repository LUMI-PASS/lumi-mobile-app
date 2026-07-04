import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lumi_pass/common/router/app_router.dart';

const _kBookingTypes = {
  'booking_approved',
  'booking_rejected',
  'booking_time_suggestion',
  'booking_request_pending',
};

class PushNotificationManager {
  PushNotificationManager(this._appRouter);

  final AppRouter _appRouter;

  final _notification = FlutterLocalNotificationsPlugin();

  static const _kChannelId = 'lumi_channel';
  static const _kChannelName = 'Lumi Notifications';

  bool _isNavigating = false;
  DateTime? _lastNavigationTime;
  static const _navigationDebounceMs = 500;

  // ─── Public API ──────────────────────────────────────────────────────────

  Future<void> initializeNotification() async {
    try {
      log('[Push] Starting initialization');
      await _initializeLocalNotifications();
      await _initializeNotificationRoute();

      FirebaseMessaging.instance.getToken().then((t) {
        log('[Push] FCM token: $t');
        // ignore: avoid_print
        print('[FCM] device token: $t');
      }).catchError((Object e) { log('[Push] token error: $e'); return null; });

      FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        log('[Push] token refreshed: $t');
      });

      log('[Push] Initialization completed ✓');
    } catch (e) {
      log('[Push] Initialization error: $e');
    }
  }

  /// Show an immediate local notification — use from a debug button or at
  /// startup to verify the full display pipeline without needing FCM/APNs.
  Future<void> showTestNotification() async {
    log('[Push] Showing test notification');
    await _notification.show(
      99999,
      'Push test ✓',
      'If you see this, local notifications are working',
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
    );
  }

  // ─── Private ─────────────────────────────────────────────────────────────

  Future<void> _initializeLocalNotifications() async {
    try {
      // Android notification channel
      const channel = AndroidNotificationChannel(
        _kChannelId,
        _kChannelName,
        description: 'Lumi push notifications',
        importance: Importance.high,
        playSound: true,
      );
      final androidPlugin = _notification.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.deleteNotificationChannel(_kChannelId);
        await androidPlugin.createNotificationChannel(channel);
      }

      await _notification.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            // Don't re-request permission here — PushNotificationService
            // already calls FirebaseMessaging.requestPermission() which
            // covers both FCM and local notifications on iOS.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            // These three MUST be true so that when _notification.show() is
            // called while the app is in the foreground, iOS actually
            // presents the banner. Without them the notification is
            // delivered silently and the user sees nothing.
            defaultPresentAlert: true,
            defaultPresentBadge: true,
            defaultPresentSound: true,
          ),
        ),
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          log('[Push] local notification tapped: ${response.payload}');
          Map<String, dynamic> data = {};
          try {
            if (response.payload != null && response.payload!.isNotEmpty) {
              data = Map<String, dynamic>.from(
                jsonDecode(response.payload!) as Map,
              );
            }
          } catch (_) {}
          _handleMessage(RemoteMessage(
            data: Map<String, String>.from(
              data.map((k, v) => MapEntry(k, v.toString())),
            ),
          ));
        },
      );

      // flutter_local_notifications.initialize() replaces the
      // UNUserNotificationCenterDelegate, which breaks Firebase's
      // willPresentNotification swizzle. setForegroundNotificationPresentationOptions
      // therefore becomes unreliable on iOS. Instead we show a local
      // notification explicitly via flutter_local_notifications on both
      // platforms — this is the same path that the showTestNotification()
      // self-test confirmed works.
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        log('[Push] foreground message: title="${message.notification?.title}" '
            'body="${message.notification?.body}" data=${message.data}');
        // ignore: avoid_print
        print('[FCM] foreground — title:${message.notification?.title} '
            'body:${message.notification?.body} data:${message.data}');

        if (kIsWeb) return;

        final n = message.notification;
        if (n == null) return;
        await _notification.show(
          DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF,
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
          payload: jsonEncode(message.data),
        );
      });

      log('[Push] Local notifications ready');
    } catch (e) {
      log('[Push] Local notification init error: $e');
    }
  }

  Future<void> _initializeNotificationRoute() async {
    try {
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log('[Push] opened from background tap: title="${message.notification?.title}"');
        // ignore: avoid_print
        print('[FCM] bg-tap: title:${message.notification?.title} data:${message.data}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 300), () {
            _handleMessage(message);
          });
        });
      });

      // Timeout prevents an infinite hang on iOS with FlutterImplicitEngineDelegate:
      // getInitialMessage() waits for the plugin channel, which isn't ready until
      // after runApp(). Since initializeNotification() is fire-and-forget
      // (unawaited), the engine starts shortly after — 5 s is a safe upper bound.
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (initialMessage != null) {
        log('[Push] cold-start notification: title="${initialMessage.notification?.title}"');
        // ignore: avoid_print
        print('[FCM] cold-start: title:${initialMessage.notification?.title} '
            'data:${initialMessage.data}');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            _handleMessage(initialMessage);
          });
        });
      }

      log('[Push] Notification routing set up');
    } catch (e) {
      log('[Push] Notification routing error: $e');
    }
  }

  Future<void> _handleMessage(RemoteMessage message, {int retryCount = 0}) async {
    try {
      final now = DateTime.now();
      if (_lastNavigationTime != null &&
          now.difference(_lastNavigationTime!).inMilliseconds < _navigationDebounceMs) {
        return;
      }
      if (_isNavigating) return;

      if (_appRouter.stack.isEmpty) {
        if (retryCount < 5) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            _handleMessage(message, retryCount: retryCount + 1);
          });
        }
        return;
      }

      _isNavigating = true;
      _lastNavigationTime = now;

      final type = message.data['type'] as String? ?? '';
      log('[Push] navigating for type: "$type"');

      try {
        _appRouter.popUntilRoot();
        if (_kBookingTypes.contains(type)) {
          _appRouter.navigate(const MyBookingsRoute());
        } else {
          _appRouter.navigate(const CalendarRoute());
        }
      } finally {
        Future.delayed(const Duration(milliseconds: 300), () {
          _isNavigating = false;
        });
      }
    } catch (e) {
      _isNavigating = false;
      log('[Push] Navigation error: $e');
    }
  }
}

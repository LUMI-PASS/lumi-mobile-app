import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';
import 'package:lumi_pass/data/base_model/token/tokens.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/auth/auth_api.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl(this._api, this._storage);

  final AuthApi _api;
  final Storage _storage;

  @override
  Future<void> logout() async {
    await _storage.tokens.set(null);
    await _storage.deviceToken.set(null);
  }

  @override
  Future<int?> sendOtp(String phone) async {
    final response = await _api.sendOtp(phone);
    final data = response.data['data'];
    if (data is Map<String, dynamic>) {
      final code = data['code'];
      if (code is int) return code;
      if (code is String) return int.tryParse(code);
      if (code is num) return code.toInt();
    }
    return null;
  }

  @override
  Future<VerifyOtpResult> verifyOtp(String phone, String code) async {
    final response = await _api.verifyOtp(phone, code);
    final data = response.data['data'] as Map<String, dynamic>;
    final isNewUser = data['is_new_user'] as bool? ?? false;
    final token = data['access_token'] as String?;
    if (token != null) {
      await _storage.tokens.set(Tokens(access: token));
    }
    final userJson = data['user'];
    return VerifyOtpResult(
      isNewUser: isNewUser,
      accessToken: token,
      user: userJson is Map<String, dynamic>
          ? ProfileModel.fromJson(userJson)
          : null,
    );
  }

  @override
  Future<ProfileModel> register({
    required String phone,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _api.register(
      phone: phone,
      firstName: firstName,
      lastName: lastName,
    );
    final data = response.data['data'] as Map<String, dynamic>;
    final token = data['access_token'] as String?;
    if (token != null) {
      await _storage.tokens.set(Tokens(access: token));
    }
    final userJson = data['user'] as Map<String, dynamic>?;
    if (userJson != null) {
      final userId = (userJson['_id'] ?? userJson['id'])?.toString();
      if (userId != null) await _storage.userId.set(userId);
    }
    return userJson != null ? ProfileModel.fromJson(userJson) : const ProfileModel();
  }

//
// @override
// Future<void> getFirebaseToken() async {
//   try {
//     await _firebaseMessaging.requestPermission();
//
//     String? firebaseToken = await _firebaseMessaging.getToken();
//
//     if (firebaseToken != null && firebaseToken.isNotEmpty) {
//       print("Firebase device token: $firebaseToken");
//       _storage.deviceToken.set(firebaseToken);
//     } else {
//       print("Failed to retrieve FCM token");
//     }
//
//     if (Platform.isIOS) {
//       try {
//         String? apnsToken = await _firebaseMessaging.getAPNSToken();
//         print("APNs token (iOS only): $apnsToken");
//       } catch (e) {
//         print("Error in getAPNSToken: $e");
//       }
//     }
//   } catch (e) {
//     print("Error in sendDeviceToken: $e");
//   }
// }
//
// Future<void> initLocalNotifications(
//   RemoteMessage message,
// ) async {
//   var androidInitialization =
//       const AndroidInitializationSettings('@drawable/notificaation');
//   var iodInitialization = const DarwinInitializationSettings();
//
//   var initializationSettings = InitializationSettings(
//     android: androidInitialization,
//     iOS: iodInitialization,
//   );
//
//   await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//     print("notification pressed on playload");
//     final String? payload = response.payload;
//     if (payload != null) {
//       _navigateToScreen(remoteMessage ??
//           const RemoteMessage(data: {
//             "type": "order",
//           }));
//     }
//   });
// }
//
// Future<void> showNotification(RemoteMessage message) async {
//   AndroidNotificationChannel channel = AndroidNotificationChannel(
//     Random.secure().nextInt(100000).toString(),
//     'High Importance Notifications',
//     importance: Importance.max,
//   );
//
//   AndroidNotificationDetails androidNotificationDetails =
//       AndroidNotificationDetails(channel.id, channel.name,
//           channelDescription: 'lumi_pass',
//           importance: Importance.high,
//           priority: Priority.high,
//           ticker: 'ticker',
//           color: const Color(0xFF082031));
//
//   const DarwinNotificationDetails darwinNotificationDetails =
//       DarwinNotificationDetails(
//     presentAlert: true,
//     presentBadge: true,
//     presentSound: true,
//   );
//
//   NotificationDetails notificationDetails = NotificationDetails(
//     android: androidNotificationDetails,
//     iOS: darwinNotificationDetails,
//   );
//
//   Future.delayed(Duration.zero, () {
//     _flutterLocalNotificationsPlugin.show(
//       0,
//       message.notification?.title,
//       message.notification?.body,
//       notificationDetails,
//     );
//   });
// }
//
// Future foregroundMessage() async {
//   await FirebaseMessaging.instance
//       .setForegroundNotificationPresentationOptions(
//     alert: true,
//     badge: true,
//     sound: true,
//   );
// }
//
// @override
// Future<void> firebaseInit() async {
//   FirebaseMessaging.onMessage.listen((message) async {
//     print("Notification came :::: \n :::: \n  \n");
//     RemoteNotification? notification = message.notification;
//     AndroidNotification? android = message.notification!.android;
//     remoteMessage = message;
//     if (kDebugMode) {
//       print('notifications:${notification!}');
//       print('notifications title:${notification.title}');
//       print('notifications body:${notification.body}');
//       print('data:${message.data.toString()}');
//       print('message:${message.toString()}');
//     }
//
//     if (Platform.isIOS) {
//       foregroundMessage();
//     }
//
//     if (Platform.isAndroid) {
//       try {
//         await initLocalNotifications(message);
//         showNotification(message);
//       } catch (e) {
//         print("error in initializing ::$e ");
//       }
//     }
//   });
//
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     print("Message opened app :: \n :: ");
//     _navigateToScreen(message);
//   });
// }
//
// @override
// void initializeFirebaseMessaging() {
//   _firebaseMessaging.onTokenRefresh.listen((fcmToken) {
//     print("FCM Token refreshed: $fcmToken");
//     _storage.deviceToken.set(fcmToken);
//     // _api.sendDeviceToken(fcmToken);
//   });
// }
//
// @override
// Future<void> sendDeviceToken() async {
//   try {
//     await _firebaseMessaging.requestPermission();
//
//     if (Platform.isIOS) {
//       try {
//         await _ensureAPNSTokenAvailable();
//       } catch (e) {
//         print("Erorr apn :: $e");
//       }
//     }
//
//     String? firebaseToken = await _firebaseMessaging.getToken();
//
//     if (firebaseToken != null && firebaseToken.isNotEmpty) {
//       print("Firebase device token: $firebaseToken");
//       _storage.deviceToken.set(firebaseToken);
//       await _api.sendDeviceToken(firebaseToken);
//     } else {
//       print("Failed to retrieve FCM token");
//     }
//   } catch (e) {
//     print("Error in sendDeviceToken: $e");
//   }
// }
//
// Future<void> _ensureAPNSTokenAvailable() async {
//   String? apnsToken = await _firebaseMessaging.getAPNSToken();
//   int retryCount = 0;
//   const maxRetries = 1;
//
//   while (apnsToken == null && retryCount < maxRetries) {
//     print("Waiting for APNs token... attempt ${retryCount + 1}");
//     await Future.delayed(Duration(milliseconds: 500));
//     apnsToken = await _firebaseMessaging.getAPNSToken();
//     retryCount++;
//   }
//
//   if (apnsToken != null) {
//     print("APNs token available: $apnsToken");
//   } else {
//     throw Exception("APNs token not available after $maxRetries attempts");
//   }
// }
//
// static void _navigateToScreen(RemoteMessage message) {
//   print(
//       "🔔 NOTIFICATION: Navigation triggered for type: ${message.data['type']}");
//
//   WidgetsBinding.instance.addPostFrameCallback((_) {
//     if (navigatorContext.currentContext != null) {
//       final context = navigatorContext.currentContext!;
//       Future.delayed(const Duration(seconds: 1)).then((value) {
//         if (message.data['data']['prop_type'] == 'load') {
//           context.router.push(ShippingLoadDetailRoute(
//               id: message.data['data']['prop_id'], isMine: false));
//         } else if (message.data['type'] == 'truck') {
//           context.router.push(ShippingTruckDetailRoute(
//               id: message.data['data']['prop_id'], isMine: false));
//         } else {
//           context.router.push(const NotificationRoute());
//         }
//       });
//     } else {
//       print("❌ ERROR: Navigation context is null");
//     }
//   });
// }
//
// @override
// Future<void> deleteDeviceToken() {
//   String? deviceToken = _storage.deviceToken.call();
//   return _api.unsubscribeToken(deviceToken ?? "");
// }
}

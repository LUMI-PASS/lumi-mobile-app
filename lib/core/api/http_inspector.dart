import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@LazySingleton()
abstract interface class BaseHttpInspector {
  @factoryMethod
  factory BaseHttpInspector.fromEnvironment() {
    ///
    /// You can use HTTP_INSPECTOR_ENABLED value and enable _AliceHttpInspector for testing
    ///

    // const httpInspectorEnabled =
    //     String.fromEnvironment('HTTP_INSPECTOR_ENABLED');
    // return httpInspectorEnabled == 'true'
    //     ? _AliceHttpInspector()
    //     : _DummyHttpInspector();

    return _DummyHttpInspector();
  }

  void init(GlobalKey<NavigatorState> navigatorKey);

  Interceptor? get dioInterceptor;
}

class _DummyHttpInspector implements BaseHttpInspector {
  @override
  void init(GlobalKey<NavigatorState> navigatorKey) {}

  @override
  Interceptor? get dioInterceptor => null;
}

// class _AliceHttpInspector implements BaseHttpInspector {
//   final Alice _alice = Alice(
//     //Android-specific
//     notificationIcon: '@mipmap/ic_launcher',
//   );

//   _AliceHttpInspector();

//   @override
//   void init(GlobalKey<NavigatorState> navigatorKey) {
//     _alice.setNavigatorKey(navigatorKey);

//     if (Platform.isAndroid) {
//       final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//       flutterLocalNotificationsPlugin
//           .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin>()
//           ?.requestNotificationsPermission();
//     }
//   }

//   @override
//   Interceptor? get dioInterceptor => _alice.getDioInterceptor();
// }

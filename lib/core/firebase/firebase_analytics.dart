import 'package:founders_academy/core/logging/logger.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsHelper {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Logs an event to Firebase Analytics
  static Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      logger.i('Event logged: $eventName with parameters: $parameters');
    } catch (e, stackTrace) {
      logger.e('Failed to log event: $eventName',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Sets user properties for Firebase Analytics
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(
        name: name,
        value: value,
      );
      logger.i('User property set: $name = $value');
    } catch (e, stackTrace) {
      logger.e('Failed to set user property: $name',
          error: e, stackTrace: stackTrace);
    }
  }
}

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/notification_model/notification_model.dart';

@injectable
class NotificationsApi {
  final Dio _dio;

  NotificationsApi(this._dio);

  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      'notifications',
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = response.data;
    final List list = raw is Map && raw['data'] is List
        ? raw['data'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('notifications/unread-count');
    final raw = response.data;
    if (raw is Map && raw['data'] is Map) {
      return (raw['data']['count'] as num?)?.toInt() ?? 0;
    }
    return 0;
  }

  Future<void> markRead(String id) async {
    await _dio.patch('notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _dio.patch('notifications/read-all');
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete('notifications/$id');
  }
}

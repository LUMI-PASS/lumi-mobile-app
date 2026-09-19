import 'package:lumi_pass/data/api_model/notification_model/notification_type.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  /// The push payload the backend attached — ids and a `deep_link` naming
  /// where this notification wants to go. Values are always strings: FCM
  /// permits nothing else in a data payload.
  final Map<String, String> data;

  /// Typed view of [type] — [NotificationType.unknown] for unmodelled values.
  NotificationType get notificationType => NotificationType.fromKey(type);

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.type,
    required this.isRead,
    required this.createdAt,
    this.data = const {},
  });

  /// Where a tap on this notification should land, when it says so.
  String? get deepLink {
    final link = data['deep_link'];
    return (link == null || link.isEmpty) ? null : link;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      data: _readData(json['data']),
    );
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      data: data,
    );
  }
}

/// Reads the `data` bag defensively — a value the backend wrote as a number
/// still reads as its string here, and anything that is not a map at all is
/// simply no data rather than a crash on the notifications screen.
Map<String, String> _readData(dynamic value) {
  if (value is! Map) return const {};
  final out = <String, String>{};
  value.forEach((key, v) {
    if (v != null) out[key.toString()] = v.toString();
  });
  return out;
}

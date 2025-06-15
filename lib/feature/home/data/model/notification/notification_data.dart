import 'package:json_annotation/json_annotation.dart';

part 'notification_data.g.dart';

@JsonSerializable()
class NotificationData {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'body')
  final String body;
  @JsonKey(name: 'read')
  bool read;
  @JsonKey(name: 'image')
  final String? imageUrl;
  @JsonKey(name: 'type')
  final NotificationType? type;
  @JsonKey(name: 'entity_id')
  final String? entityId;
  @JsonKey(name: 'date')
  final String date;

  NotificationData({
    required this.id,
    required this.title,
    required this.body,
    this.read = false,
    this.imageUrl,
    this.type,
    this.entityId,
    required this.date,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) =>
      _$NotificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationDataToJson(this);
}

enum NotificationType {
  @JsonValue('afisha')
  afisha,
  @JsonValue('news')
  news,
  @JsonValue('tournament')
  tournament,
  @JsonValue('live')
  live,
  @JsonValue('grandmaster')
  grandmaster,
  @JsonValue('book')
  book,
  @JsonValue('course')
  course,
  @JsonValue('module')
  module,
  @JsonValue('review_game')
  review,
  @JsonValue('')
  unknown,
}

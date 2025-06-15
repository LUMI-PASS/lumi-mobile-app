import 'package:founders_academy/feature/home/data/model/notification/notification_data.dart';
import 'package:founders_academy/feature/home/data/model/pagination/pagination_data.dart';
import 'package:json_annotation/json_annotation.dart';

part 'notification_response.g.dart';

@JsonSerializable()
class NotificationResponse {
  @JsonKey(name: 'data')
  final List<NotificationData>? notificationList;

  @JsonKey(name: 'pagination')
  final PaginationData paginationData;

  const NotificationResponse({
    required this.paginationData,
    this.notificationList,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationResponseToJson(this);
}

@JsonSerializable()
class NotificationItemResponse {
  @JsonKey(name: 'data')
  final NotificationData? notificationData;

  const NotificationItemResponse({this.notificationData});

  factory NotificationItemResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationItemResponseToJson(this);
}

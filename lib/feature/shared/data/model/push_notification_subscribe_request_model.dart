import 'package:freezed_annotation/freezed_annotation.dart';

part 'push_notification_subscribe_request_model.g.dart';

@JsonSerializable()
class PushNotificationSubscribeRequestModel {
  final String notificationToken;

  PushNotificationSubscribeRequestModel({
    required this.notificationToken,
  });

  Map<String, dynamic> toJson() => {
        'notification_token': notificationToken,
      };
}

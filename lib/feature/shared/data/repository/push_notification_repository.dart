import 'dart:async';

import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/feature/home/data/data_source/remote_data_source/home_api_client.dart';
import 'package:founders_academy/feature/shared/data/model/push_notification_subscribe_request_model.dart';
import 'package:founders_academy/feature/shared/domain/repository/base_push_notification_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: BasePushNotifiactionRepository)
class PushNotificationRepository implements BasePushNotifiactionRepository {
  final HomeApiClient _homeApiClient;

  PushNotificationRepository(this._homeApiClient);

  @override
  Future<void> subscribe({required String token}) async {
    try {
      await _homeApiClient.subscribe(
        PushNotificationSubscribeRequestModel(
          notificationToken: token,
        ),
      );
    } on DioException catch (exception) {
      throw ChessException.fromDioException(exception);
    }
  }
}

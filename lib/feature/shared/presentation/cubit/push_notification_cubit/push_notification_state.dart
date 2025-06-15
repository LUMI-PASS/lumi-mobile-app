part of 'push_notification_cubit.dart';

sealed class PushNotificationState {
  const PushNotificationState();
}

class PushNotificationInitialState extends PushNotificationState {
  const PushNotificationInitialState();
}

class PushNotificationLoadingState extends PushNotificationState {
  const PushNotificationLoadingState();
}

class PushNotificationFailedState extends PushNotificationState {
  final ChessException exception;
  const PushNotificationFailedState(this.exception);
}

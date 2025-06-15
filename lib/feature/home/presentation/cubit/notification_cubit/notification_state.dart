import 'package:founders_academy/feature/home/data/model/notification/notification_data.dart';

sealed class NotificationState {
  const NotificationState();
}

class NotificationInitState extends NotificationState {
  const NotificationInitState();
}

class NotificationListLoadedState extends NotificationState {
  final List<NotificationData> notificationList;
  final int page;
  final bool isNextPageLoading;
  final bool isNextPageAvailable;

  NotificationListLoadedState({
    required this.notificationList,
    required this.page,
    this.isNextPageLoading = false,
    this.isNextPageAvailable = true,
  });
  NotificationListLoadedState copyWith({
    List<NotificationData>? notificationList,
    int? page,
    bool? isNextPageLoading,
    bool? isNextPageAvailable,
  }) {
    return NotificationListLoadedState(
      notificationList: notificationList ?? this.notificationList,
      page: page ?? this.page,
      isNextPageLoading: isNextPageLoading ?? this.isNextPageLoading,
      isNextPageAvailable: isNextPageAvailable ?? this.isNextPageAvailable,
    );
  }
}

class NotificationListErrorState extends NotificationState {
  const NotificationListErrorState();
}

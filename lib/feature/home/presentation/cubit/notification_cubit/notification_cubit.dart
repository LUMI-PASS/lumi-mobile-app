import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/logging/logger.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/home/data/model/notification/notification_data.dart';
import 'package:lumi_pass/feature/home/domain/repository/base_home_repository.dart';
import 'package:lumi_pass/feature/home/presentation/cubit/notification_cubit/notification_state.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class NotificationCubit extends ChessCubit<NotificationState> {
  final BaseHomeRepository _homeRepository;
  final SafeExecutionManager _safeExecutionManager;

  NotificationCubit(
    this._homeRepository,
    this._safeExecutionManager,
  ) : super(const NotificationInitState());

  void init() {
    _getNotificationList(1);
  }

  Future<void> loadNextPage() async {
    final currentState = state;
    if (currentState is! NotificationListLoadedState ||
        currentState.isNextPageLoading) {
      return;
    }
    try {
      safeEmit(currentState.copyWith(isNextPageLoading: true));
      if (currentState.isNextPageAvailable) {
        await _getNotificationList(
          currentState.page + 1,
          list: currentState.notificationList,
        );
      } else {
        safeEmit(currentState.copyWith(isNextPageLoading: false));
      }
    } on Exception catch (exception) {
      safeEmit(currentState.copyWith(isNextPageLoading: false));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> _getNotificationList(
    int page, {
    List<NotificationData>? list,
  }) async {
    try {
      final notificationResponse =
          await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getNotifications(page: page),
      );
      List<NotificationData> notificationList = [
        if (list != null && list.isNotEmpty) ...list,
        ...notificationResponse.notificationList ?? []
      ];
      final pagination = notificationResponse.paginationData;

      safeEmit(NotificationListLoadedState(
        notificationList: notificationList,
        page: page,
        isNextPageAvailable: pagination.nextPage != null,
      ));
    } on ChessException catch (exception) {
      safeEmit(const NotificationListErrorState());
      throw UnknownChessException(exception.toString());
    }
  }

  Future<String> getLiveStreamById(String id) async {
    try {
      final liveStreamById = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.getLiveStreamById(id: id),
      );
      return liveStreamById?.videoLink ?? '';
    } on ChessException catch (exception) {
      safeEmit(const NotificationListErrorState());
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> readNotification(String id) async {
    final currentState = state;
    if (currentState is! NotificationListLoadedState) return;

    try {
      final notification = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _homeRepository.readNotification(id: id),
      );
      if (notification != null) {
        final index = currentState.notificationList.indexWhere(
          (notification) => notification.id == id,
        );

        if (index != -1) {
          final updatedNotification = currentState.notificationList[index]
            ..read = true;

          final updatedList = List<NotificationData>.from(
            currentState.notificationList,
          );

          updatedList[index] = updatedNotification;

          safeEmit(currentState.copyWith(notificationList: updatedList));
        }
      } else {
        logger.e("Notification data is null");
      }
    } on ChessException catch (exception) {
      safeEmit(const NotificationListErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

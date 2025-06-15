import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/feature/shared/data/data_source/local_data_source/fcm_data_source.dart';
import 'package:lumi_pass/feature/shared/domain/repository/base_push_notification_repository.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'push_notification_state.dart';

@Injectable()
class PushNotificationCubit extends ChessCubit<PushNotificationState> {
  final FcmDataSource _fcmDataSource;

  final BasePushNotifiactionRepository _notifiactionRepository;

  PushNotificationCubit(
    this._fcmDataSource,
    this._notifiactionRepository,
  ) : super(const PushNotificationInitialState());

  Future<void> subscribe() async {
    safeEmit(const PushNotificationLoadingState());

    try {
      final fcmToken = await _fcmDataSource.getToken();
      if (fcmToken != null) {
        _notifiactionRepository.subscribe(token: fcmToken);
      }
    } on ChessException catch (exception) {
      safeEmit(PushNotificationFailedState(exception));
      throw UnknownChessException(exception.toString());
    }
  }
}

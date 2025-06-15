import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/profile/domain/repository/base_profile_repository.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/my_certificate_cubit/my_certificate_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class MyCertificateCubit extends ChessCubit<MyCertificateState> {
  final BaseProfileRepository _profileRepository;
  final SafeExecutionManager _safeExecutionManager;

  MyCertificateCubit(
    this._profileRepository,
    this._safeExecutionManager,
  ) : super(const MyCertificateInitState());
  void init() {
    getMyCertificate();
  }

  Future<void> getMyCertificate() async {
    try {
      final response = await _safeExecutionManager.makeAsyncSafeExecution(
          function: () => _profileRepository.getMyCertificate());

      final myCertificate = response?.myCertificate;

      safeEmit(MyCertificateLoadedState(myCertificate ?? []));
    } on ChessException catch (exception) {
      safeEmit(const MyCertificateErrorState());
      throw UnknownChessException(exception.toString());
    }
  }
}

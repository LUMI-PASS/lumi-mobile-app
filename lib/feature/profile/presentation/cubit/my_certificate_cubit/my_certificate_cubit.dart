import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/profile/domain/repository/base_profile_repository.dart';
import 'package:lumi_pass/feature/profile/presentation/cubit/my_certificate_cubit/my_certificate_state.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
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

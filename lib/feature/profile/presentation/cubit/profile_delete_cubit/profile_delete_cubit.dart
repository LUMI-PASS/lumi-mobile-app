import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/auth/domain/user_session_manager.dart';
import 'package:founders_academy/feature/profile/data/model/profile_delete/profile_delete_reason_data.dart';
import 'package:founders_academy/feature/profile/domain/repository/base_profile_repository.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/profile_delete_cubit/profile_delete_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ProfileDeleteCubit extends ChessCubit<ProfileDeleteState> {
  final UserSessionManager _userSessionManager;
  final SafeExecutionManager _safeExecutionManager;
  final BaseProfileRepository _profileRepository;

  ProfileDeleteCubit(
    this._userSessionManager,
    this._safeExecutionManager,
    this._profileRepository,
  ) : super(ProfileDeleteState());

  void updateSelectedValue(String value) {
    safeEmit(state.copyWith(reasonType: value));
  }

  void updateTextValue(String text) {
    safeEmit(
      state.copyWith(
        reasonTextField: state.reasonTextField.copyWith(value: text),
      ),
    );
  }

  Future<void> profileDelete(
    ProfileDeleteReasonData profileDeleteReasonData,
  ) async {
    try {
      final response = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () =>
            _profileRepository.profileDelete(profileDeleteReasonData),
      );
      final isProfileDeleted = response.isDeleted;
      if (isProfileDeleted) {
        await _userSessionManager.clearUserSession();
        await _profileRepository.clearDatabase();
        safeEmit(state.copyWith(isDeleted: true));
      }
    } on ChessException catch (exception) {
      logger.e(exception);
      throw UnknownChessException(exception.toString());
    }
  }
}

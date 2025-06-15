import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/auth/domain/user_session_manager.dart';
import 'package:founders_academy/feature/profile/data/model/profile_data.dart';
import 'package:founders_academy/feature/profile/domain/repository/base_profile_repository.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

part 'profile_creation_state.dart';

@Injectable()
class ProfileCreationCubit extends ChessCubit<ProfileCreationState> {
  final BaseProfileRepository _profileRepository;
  final UserSessionManager _userSessionManager;
  final SafeExecutionManager _safeExecutionManager;

  ProfileCreationCubit(
    this._profileRepository,
    this._userSessionManager,
    this._safeExecutionManager,
  ) : super(ProfileCreationInitialState());

  Future<void> createProfile(ProfileData profile) async {
    try {
      final profileData = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _profileRepository.createProfile(profile),
      );
      if (profileData != null) {
        await _userSessionManager.saveUserId(profileData.userId ?? "");
        safeEmit(ProfileCreationFinishedState(profileData));
      } else {
        safeEmit(
          ProfileCreationErrorState(
            UnknownChessException("Profile Data is null"),
          ),
        );
      }
    } on ChessException catch (exception) {
      safeEmit(ProfileCreationErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }
}

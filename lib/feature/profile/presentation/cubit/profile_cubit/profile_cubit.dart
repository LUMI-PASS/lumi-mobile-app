import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:founders_academy/feature/auth/domain/user_session_manager.dart';
import 'package:founders_academy/feature/profile/data/model/profile_data.dart';
import 'package:founders_academy/feature/profile/domain/repository/base_profile_repository.dart';
import 'package:founders_academy/feature/profile/presentation/cubit/profile_cubit/profile_state.dart';
import 'package:founders_academy/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ProfileCubit extends ChessCubit<ProfileState> {
  final UserSessionManager _userSessionManager;
  final BaseProfileRepository _profileRepository;
  final SafeExecutionManager _safeExecutionManager;

  ProfileCubit(
    this._userSessionManager,
    this._profileRepository,
    this._safeExecutionManager,
  ) : super(const ProfileInitState());

  void init() {
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      final ProfileData? profileData =
          await _safeExecutionManager.makeAsyncSafeExecution(
        function: _profileRepository.getProfile,
      );

      if (profileData != null) {
        safeEmit(ProfileLoadedState(profileData));
      } else {
        safeEmit(const ProfileErrorState());
      }
    } on ChessException catch (exception) {
      safeEmit(const ProfileErrorState());
      throw UnknownChessException(exception.toString());
    }
  }

  void onImageUpdated(String url) {
    final currentState = state;
    if (currentState is! ProfileLoadedState) {
      return;
    }

    ProfileData profileData = currentState.profileData;

    profileData.imageUrl = url;

    safeEmit(ProfileLoadedState(profileData));
  }

  void onSaveTap(String firstName, String lastName) {
    final currentState = state;
    if (currentState is! ProfileLoadedState) {
      return;
    }

    if (currentState.profileData.firstName == firstName &&
        currentState.profileData.lastName == lastName) {
      safeEmit(ProfileLoadedState(currentState.profileData));
    }

    final editedProfileData = ProfileData(
      firstName: firstName,
      lastName: lastName,
    );

    updateProfile(editedProfileData);
  }

  Future<void> updateProfile(ProfileData editedProfileData) async {
    try {
      final profileData = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _profileRepository.updateProfile(
          editedProfileData,
        ),
      );

      if (profileData != null) {
        safeEmit(ProfileLoadedState(profileData, isProfileUpdated: true));
      } else {
        safeEmit(const ProfileErrorState());
      }
    } on ChessException catch (exception) {
      safeEmit(const ProfileErrorState());
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> logout() async {
    await _userSessionManager.clearUserSession();
    safeEmit(const ProfileLoggedOutState());
  }
}

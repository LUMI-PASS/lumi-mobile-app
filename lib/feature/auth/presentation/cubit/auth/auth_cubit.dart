
import 'package:lumi_pass/core/error/chess_exception.dart';
import 'package:lumi_pass/core/safe_execution/domain/safe_execution_manager.dart';
import 'package:lumi_pass/feature/auth/data/model/otp_data.dart';
import 'package:lumi_pass/feature/auth/domain/repository/base_auth_repository.dart';
import 'package:lumi_pass/feature/auth/domain/user_session_manager.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_data.dart';
import 'package:lumi_pass/feature/profile/domain/repository/base_profile_repository.dart';
import 'package:lumi_pass/feature/shared/presentation/cubit/chess_cubit.dart';
import 'package:injectable/injectable.dart';

import 'auth_state.dart';

enum UserType { local, international }

@Injectable()
class AuthCubit extends ChessCubit<AuthState> {
  final BaseAuthRepository _authRepository;
  final UserSessionManager _userSessionManager;
  final BaseProfileRepository _profileRepository;
  final SafeExecutionManager _safeExecutionManager;

  AuthCubit(
    this._authRepository,
    this._userSessionManager,
    this._profileRepository,
    this._safeExecutionManager,
  ) : super(const AuthLoadingState());

  Future<void> sendOtp(
    String? phoneNumber,
    UserType type, [
    String? email,
  ]) async {
    safeEmit(const AuthLoadingState());

    try {
      if (type == UserType.local) {
        final otpData = await _safeExecutionManager.makeAsyncSafeExecution(
          function: () => _authRepository.localUserLogin(phoneNumber!),
        );

        safeEmit(AuthOtpSentState(otpData));
      } else {
        final otpData = await _safeExecutionManager.makeAsyncSafeExecution(
          function: () => _authRepository.inernationalUserLogin(email ?? ''),
        );

        final data = Map<String, dynamic>.from(otpData.toJson());
        data["phone_number"] = otpData.phoneNumber ?? phoneNumber;
        final otp = OtpData.fromJson(data);
        safeEmit(AuthOtpSentState(otp));
      }
    } on ChessException catch (exception) {
      safeEmit(AuthErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<void> login(OtpData otpData) async {
    safeEmit(const AuthLoadingState());

    try {
      final tokenData = await _safeExecutionManager.makeAsyncSafeExecution(
        function: () => _authRepository.login(otpData),
      );

      await _userSessionManager.saveUserToken(tokenData.token);
      final userData = await _getProfile();
      if (userData == null || userData.isEmpty) {
        safeEmit(const AuthSignUpRequiredState());
      } else {
        await _userSessionManager.saveUserId(userData.userId ?? "");
        safeEmit(const AuthLoadedState());
      }
    } on NotFoundChessException catch (exception) {
      safeEmit(AuthIncorrectOtpState(exception));
      throw UnknownChessException(exception.toString());
    } on ChessException catch (exception) {
      safeEmit(AuthErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }

  Future<ProfileData?> _getProfile() async {
    safeEmit(const AuthLoadingState());

    try {
      final userData = await _safeExecutionManager.makeAsyncSafeExecution(
        function: _profileRepository.getProfile,
      );
      return userData;
    } on ChessException catch (exception) {
      safeEmit(AuthErrorState(exception));
      throw UnknownChessException(exception.toString());
    }
  }
}

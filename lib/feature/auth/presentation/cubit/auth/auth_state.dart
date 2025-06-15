import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/feature/auth/data/model/otp_data.dart';

sealed class AuthState {
  const AuthState();
}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthLoadedState extends AuthState {
  const AuthLoadedState();
}

class AuthOtpSentState extends AuthState {
  final OtpData otpData;
  const AuthOtpSentState(this.otpData);
}

class AuthErrorState extends AuthState {
  final ChessException exception;

  const AuthErrorState(this.exception);
}

class AuthIncorrectOtpState extends AuthState {
  final ChessException exception;

  const AuthIncorrectOtpState(this.exception);
}

class AuthSignUpRequiredState extends AuthState {
  const AuthSignUpRequiredState();
}

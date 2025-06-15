import 'package:dio/dio.dart';
import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/feature/auth/data/data_source/auth_api_client.dart';
import 'package:founders_academy/feature/auth/data/model/international_user_login_request.dart';
import 'package:founders_academy/feature/auth/data/model/local_user_login_request.dart';
import 'package:founders_academy/feature/auth/data/model/otp_data.dart';
import 'package:founders_academy/feature/auth/data/model/token_data.dart';
import 'package:founders_academy/feature/auth/domain/repository/base_auth_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: BaseAuthRepository)
class AuthRepository implements BaseAuthRepository {
  final AuthApiClient _authApiClient;

  AuthRepository(this._authApiClient);

  @override
  Future<OtpData> localUserLogin(String phoneNumber) async {
    try {
      final response = await _authApiClient.localUserLogin(
        LocalUserLoginRequest(phoneNumber: phoneNumber),
      );

      return response.result;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<OtpData> inernationalUserLogin(String email) async {
    try {
      final response = await _authApiClient.internationalUserLogin(
        InternationalUserLoginRequest(email: email),
      );

      return response.result;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<TokenData> login(OtpData otpData) async {
    try {
      final response = await _authApiClient.login(otpData);

      return response.result;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }
}

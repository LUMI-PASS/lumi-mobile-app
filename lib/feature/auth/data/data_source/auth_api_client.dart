import 'package:dio/dio.dart';
import 'package:founders_academy/core/api/api_response.dart';
import 'package:founders_academy/di/module/api_client_module.dart';
import 'package:founders_academy/feature/auth/data/model/international_user_login_request.dart';
import 'package:founders_academy/feature/auth/data/model/local_user_login_request.dart';
import 'package:founders_academy/feature/auth/data/model/otp_data.dart';
import 'package:founders_academy/feature/auth/data/model/token_data.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_client.g.dart';

@injectable
@RestApi()
abstract class AuthApiClient {
  @factoryMethod
  factory AuthApiClient(@unauthorizedApiClient Dio dio) = _AuthApiClient;

  @POST('/api/auth/otp/phone-number')
  Future<ApiResponse<OtpData>> localUserLogin(
    @Body() LocalUserLoginRequest user,
  );

  @POST('/api/auth/otp/email')
  Future<ApiResponse<OtpData>> internationalUserLogin(
    @Body() InternationalUserLoginRequest user,
  );

  @POST('/api/auth/signin')
  Future<ApiResponse<TokenData>> login(
    @Body() OtpData otpData,
  );
}

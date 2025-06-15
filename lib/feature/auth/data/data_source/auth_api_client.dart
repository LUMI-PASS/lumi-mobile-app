import 'package:dio/dio.dart';
import 'package:lumi_pass/core/api/api_response.dart';
import 'package:lumi_pass/di/module/api_client_module.dart';
import 'package:lumi_pass/feature/auth/data/model/international_user_login_request.dart';
import 'package:lumi_pass/feature/auth/data/model/local_user_login_request.dart';
import 'package:lumi_pass/feature/auth/data/model/otp_data.dart';
import 'package:lumi_pass/feature/auth/data/model/token_data.dart';
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

  @POST('/api/v1/auth/login')
  Future<ApiResponse<TokenData>> login(
    @Body() OtpData otpData,
  );
}

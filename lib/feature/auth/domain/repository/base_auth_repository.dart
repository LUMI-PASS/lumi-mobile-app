
import 'package:founders_academy/feature/auth/data/model/otp_data.dart';
import 'package:founders_academy/feature/auth/data/model/token_data.dart';

abstract interface class BaseAuthRepository {
  Future<OtpData> localUserLogin(String phoneNumber);

  Future<OtpData> inernationalUserLogin(String email);

  Future<TokenData> login(OtpData email);
}


import 'package:lumi_pass/feature/auth/data/model/otp_data.dart';
import 'package:lumi_pass/feature/auth/data/model/token_data.dart';

abstract interface class BaseAuthRepository {
  Future<OtpData> localUserLogin(String phoneNumber);

  Future<OtpData> inernationalUserLogin(String email);

  Future<TokenData> login(OtpData email);
}

import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';

class VerifyOtpResult {
  final bool isNewUser;
  final String? accessToken;
  final ProfileModel? user;

  VerifyOtpResult({
    required this.isNewUser,
    this.accessToken,
    this.user,
  });
}

abstract class AuthRepository {
  Future<int?> sendOtp(String phone);

  Future<VerifyOtpResult> verifyOtp(String phone, String code);

  Future<ProfileModel> register({
    required String phone,
    required String firstName,
    required String lastName,
  });

  Future<void> logout();
}

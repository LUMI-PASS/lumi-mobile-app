import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';
import 'package:lumi_pass/data/api_model/register/register_model.dart';

abstract class AuthRepository {
  Future<ProfileModel> register(ProfileModel registerModel);

  Future<bool> checkNumber(String phoneNumber);

  Future<bool> verifyNumber(String phoneNumber, String code, bool isReg);

  Future<void> logout();

// Future<void> getFirebaseToken();
//
// Future<void> firebaseInit();
//
// Future<void> sendDeviceToken();
//
// Future<void> deleteDeviceToken();
//
// void initializeFirebaseMessaging();
}

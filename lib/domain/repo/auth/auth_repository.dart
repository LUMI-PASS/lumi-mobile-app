import 'package:flexobo/data/api_model/checking_response/checking_response_model.dart';
import 'package:flexobo/data/api_model/register/register_model.dart';
import 'package:flexobo/data/base_model/token/tokens.dart';
import 'package:flutter/material.dart';

abstract class AuthRepository {
  Future<void> register(RegisterModel registerModel);

  Future<CheckingResponseModel> login(String phone, String password);

  Future<void> verifyCode(
      String phoneNumber, int verificationCode, String codeHash);

  Future<CheckingResponseModel> resetPasswordSendCode(String phone);

  Future<void> resetPasswordConfirm(String phone, String code);

  Future<CheckingResponseModel> verifyPhoneNumber(String phone, bool isReg);

  Future<void> resetPassword(String phoneOrEmail, String newPassword);

  Future<void> logout();

  Future<void> getFirebaseToken();

  Future<void> firebaseInit();

  Future<void> sendDeviceToken();

  Future<void> deleteDeviceToken();

  void initializeFirebaseMessaging();
}

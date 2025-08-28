import 'package:dio/dio.dart';
import 'package:flexobo/data/api_model/register/register_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Response> register(RegisterModel registerModel) {
    final request = registerModel.toJson()
      ..removeWhere((key, value) => value == null);
    return _dio.post('auth/signup', data: request);
  }

  Future<Response> verify(String contact, int code, String codeHash) {
    final request = contact.startsWith("+")
        ? {'phone_number': contact.replaceAll("-", ""), 'code': code}
        : {'email': contact, 'code': code};
    request.addAll({'code_hash': codeHash});
    return _dio.post('auth/verify-otp/', data: request);
  }

  Future<Response> login({
    required String phone,
    required String password,
  }) {
    final request = phone.startsWith("+")
        ? {'phone_number': phone.replaceAll("-", ""), 'password': password}
        : {'email': phone.replaceAll("-", ""), 'password': password};
    return _dio.post('auth/signin/', data: request);
  }

  Future<Response> resetPasswordSendCode(String contact) {
    final request = contact.startsWith("+")
        ? {
            'phone_number': contact.replaceAll("-", ""),
            'auth_method': 'phone-number'
          }
        : {'email': contact, 'auth_method': 'email'};
    return _dio.post('auth/forgot-password', data: request);
  }

  Future<Response> createNewPassword(String newPassword, String contact) {
    final request = contact.startsWith("+")
        ? {
            'phone_number': contact.replaceAll("-", ""),
            'new_password': newPassword,
            'auth_method': 'phone-number'
          }
        : {
            'email': contact,
            'new_password': newPassword,
            'auth_method': 'email'
          };
    return _dio.post('auth/reset-password/', data: request);
  }

  Future<Response> resetVerify(String phone, String code) {
    final request = {'phone': phone.replaceAll("-", ""), 'otp_code': code};
    return _dio.post('/auth/password/reset/verify/', data: request);
  }

  Future<Response> sendDeviceToken(String token) {
    return _dio
        .post("notification/subscribe/", data: {'notification_token': token});
  }

  Future<Response> deleteToken(String token) {
    return _dio.post("notification/unsubscribe/");
  }

  Future<Response> verifyPhoneNumber(String phone, bool isReg) {
    return _dio.post("auth/otp/phone-number/", data: {
      'phone_number': phone.replaceAll("-", ""),
      'for_registration': isReg
    });
  }

  Future<Response> verifyEmail(String email, bool isReg) {
    return _dio.post("auth/otp/email/",
        data: {'email': email, 'for_registration': isReg});
  }

  Future<Response> unsubscribeToken(String deviceToken) {
    return _dio.post("notification/unsubscribe/",
        data: {'notification_token': deviceToken});
  }
}

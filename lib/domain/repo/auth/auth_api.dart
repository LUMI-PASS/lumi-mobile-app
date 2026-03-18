import 'package:dio/dio.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Response> register(ProfileModel registerModel) {
    final request = registerModel.toJson()
      ..removeWhere(
          (key, value) => value == null || (value.toString()).isEmpty);
    return _dio.post('auth/register', data: request);
  }

  Future<Response> verify(String contact, String code, bool isReg) {
    final request = {
      'phone_number': contact.replaceAll("-", ""),
      'code': int.parse(code)
    };
    return _dio.post(!isReg ? 'auth/verify-login' : 'auth/verify',
        data: request);
  }

  Future<Response> checkNumber({
    required String phone,
  }) {
    return _dio.post('auth/check-number', data: {'phone_number': phone.trim()});
  }

  Future<Response> resendOtp({required String phone}) {
    return _dio.post('auth/resend', data: {'phone_number': phone.trim()});
  }

  Future<Response> sendDeviceToken(String token) {
    return _dio
        .post("notification/subscribe", data: {'notification_token': token});
  }

  Future<Response> deleteToken(String token) {
    return _dio.post("notification/unsubscribe");
  }

  Future<Response> unsubscribeToken(String deviceToken) {
    return _dio.post("notification/unsubscribe",
        data: {'notification_token': deviceToken});
  }
}

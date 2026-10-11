import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthApi {
  final Dio _dio;

  AuthApi(this._dio);

  Future<Response> sendOtp(String phone) {
    return _dio.post('auth/send-otp', data: {'phone': phone.trim()});
  }

  Future<Response> verifyOtp(String phone, String code) {
    return _dio.post('auth/verify-otp', data: {
      'phone': phone.trim(),
      'code': code,
    });
  }

  Future<Response> register({
    required String phone,
    required String firstName,
    required String lastName,
  }) {
    return _dio.post('auth/register', data: {
      'phone': phone.trim(),
      'first_name': firstName,
      'last_name': lastName,
    });
  }

  /// Which Telegram bot the "Telegram orqali kirish" button should open. Asked
  /// of the server rather than hardcoded so the bot can be swapped (test → real)
  /// without shipping an app release.
  Future<Response> telegramLoginLink() {
    return _dio.get('auth/telegram/link');
  }

  /// Redeems the code the bot showed the user. No phone number — not having to
  /// type one is the point of this flow.
  Future<Response> telegramLogin(String code) {
    return _dio.post('auth/telegram/login', data: {'code': code.trim()});
  }
}

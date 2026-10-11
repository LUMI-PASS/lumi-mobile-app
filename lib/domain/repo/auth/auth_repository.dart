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

/// Where to send the user for a Telegram login, and what to expect back.
class TelegramLoginInfo {
  final String botUsername;
  final String url;

  /// How many digits the bot's code has. Server-driven: it is not the SMS
  /// code's four, and the length is the backend's to decide.
  final int codeLength;

  const TelegramLoginInfo({
    required this.botUsername,
    required this.url,
    required this.codeLength,
  });

  /// Every field is defended, because this is the screen's only source of
  /// truth: a missing `url` would otherwise send the user to `https://t.me/`,
  /// and a missing `code_length` would build a field the code can never fill.
  factory TelegramLoginInfo.fromJson(Map<String, dynamic> json) {
    final username = (json['bot_username'] as String?)?.trim() ?? '';
    final url = (json['url'] as String?)?.trim();
    final length = (json['code_length'] as num?)?.toInt();
    return TelegramLoginInfo(
      botUsername: username,
      url: url != null && url.isNotEmpty ? url : 'https://t.me/$username',
      // 6 matches the backend's TELEGRAM_OTP_LENGTH. It is a fallback, not a
      // second definition — the server's answer wins whenever it sends one.
      codeLength: length != null && length > 0 ? length : 6,
    );
  }
}

abstract class AuthRepository {
  Future<int?> sendOtp(String phone);

  Future<VerifyOtpResult> verifyOtp(String phone, String code);

  Future<TelegramLoginInfo> telegramLoginLink();

  /// Signs in with the code the Telegram bot showed the user. The code stays a
  /// String end to end — an OTP is a digit sequence, not a number.
  Future<VerifyOtpResult> telegramLogin(String code);

  Future<ProfileModel> register({
    required String phone,
    required String firstName,
    required String lastName,
  });

  Future<void> logout();
}

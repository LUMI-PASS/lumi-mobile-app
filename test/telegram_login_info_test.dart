import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';

/// `GET /api/auth/telegram/link` is the whole reason the app does not hardcode
/// a bot username: the test bot gets swapped for the real one server-side. That
/// makes this payload the screen's only source of truth, and every way it can
/// arrive short has a matching way for the screen to fail silently — a link to
/// nowhere, or a code field the code can never fill.
void main() {
  group('TelegramLoginInfo.fromJson', () {
    test('takes the server\'s answer when it is complete', () {
      final info = TelegramLoginInfo.fromJson(const {
        'bot_username': 'lumi_test_otp_bot',
        'url': 'https://t.me/lumi_test_otp_bot',
        'code_length': 6,
      });

      expect(info.botUsername, 'lumi_test_otp_bot');
      expect(info.url, 'https://t.me/lumi_test_otp_bot');
      expect(info.codeLength, 6);
    });

    test('honours a code length the app did not expect', () {
      // The backend owns this number. If it ever moves to 8, the field has to
      // follow without an app release — that is the point of sending it.
      final info = TelegramLoginInfo.fromJson(const {
        'bot_username': 'bot',
        'code_length': 8,
      });

      expect(info.codeLength, 8);
    });

    test('builds the link from the username when the url is missing', () {
      final info = TelegramLoginInfo.fromJson(const {
        'bot_username': 'lumi_otp_bot',
      });

      expect(info.url, 'https://t.me/lumi_otp_bot');
    });

    test('treats an empty url as missing rather than opening t.me/', () {
      final info = TelegramLoginInfo.fromJson(const {
        'bot_username': 'lumi_otp_bot',
        'url': '',
      });

      expect(info.url, 'https://t.me/lumi_otp_bot');
    });

    test('falls back to 6 digits rather than a field nothing can fill', () {
      for (final json in const [
        {'bot_username': 'bot'},
        {'bot_username': 'bot', 'code_length': 0},
        {'bot_username': 'bot', 'code_length': null},
      ]) {
        expect(TelegramLoginInfo.fromJson(json).codeLength, 6);
      }
    });

    test('survives a payload with nothing in it', () {
      // Never throw on the login screen: an exception here is a dead button
      // with no way forward.
      final info = TelegramLoginInfo.fromJson(const {});

      expect(info.botUsername, '');
      expect(info.codeLength, 6);
    });

    test('reads a code length sent as a double', () {
      // JSON numbers arrive as double often enough to be worth pinning.
      final info = TelegramLoginInfo.fromJson(const {
        'bot_username': 'bot',
        'code_length': 6.0,
      });

      expect(info.codeLength, 6);
    });
  });
}

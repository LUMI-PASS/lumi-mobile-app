// Pass --dart-define=APP_ENV=dev when running to enable dev mode.
// VS Code: use the "Run Dev" launch configuration.
// CLI:     flutter run --dart-define=APP_ENV=dev
const String _kEnv = String.fromEnvironment('APP_ENV', defaultValue: 'prod');

class AppEnv {
  static const bool isDev = _kEnv == 'dev';
  static const bool isProd = !isDev;

  static const String baseUrl = isDev
      ? 'https://dev-mobile-api.lumipass.uz/api/'
      : 'https://mobile-api.lumipass.uz/api/';

  static const String assetsUrl = isDev
      ? 'https://dev-mobile-api.lumipass.uz'
      : 'https://mobile-api.lumipass.uz';

  // Dev testers allowed to log in (enforced on the backend; mirrored here
  // so the app can show a helpful error before hitting the network).
  static const List<String> devAllowedPhones = [
    '+998940286169',
    '+998937111708',
  ];
}

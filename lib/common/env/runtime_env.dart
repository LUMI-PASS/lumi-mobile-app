import 'package:dio/dio.dart';
import 'package:lumi_pass/common/env/app_env.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kPrefKey = 'runtime_env_dev';
const _kDevBaseUrl = 'https://dev-mobile-api.lumipass.uz/api/';
const _kProdBaseUrl = 'https://mobile-api.lumipass.uz/api/';
const _kDevAssetsUrl = 'https://dev-mobile-api.lumipass.uz';
const _kProdAssetsUrl = 'https://mobile-api.lumipass.uz';

/// Runtime environment switcher. Phones in [switcherPhones] can toggle
/// between dev and prod inside the app without rebuilding.
///
/// Call [RuntimeEnv.load()] before configureDependencies() in main.dart.
/// Call [RuntimeEnv.setDev()] to switch at runtime — it also updates the
/// live Dio instance immediately so in-flight and future requests switch.
class RuntimeEnv {
  static bool _isDev = AppEnv.isDev;

  static bool get isDev => _isDev;
  static bool get isProd => !_isDev;

  static String get baseUrl => _isDev ? _kDevBaseUrl : _kProdBaseUrl;
  static String get assetsUrl => _isDev ? _kDevAssetsUrl : _kProdAssetsUrl;

  /// Phone numbers allowed to see and use the env switcher.
  static const switcherPhones = {'+998940286169', '+998937111708'};

  static bool isSwitcherPhone(String? phone) {
    if (phone == null) return false;
    final normalized = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return switcherPhones.any(
      (p) => p.replaceAll(RegExp(r'[^\d+]'), '') == normalized,
    );
  }

  /// Load persisted preference before DI starts.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isDev = prefs.getBool(_kPrefKey) ?? AppEnv.isDev;
  }

  /// Switch environment. Updates Dio immediately — caller should log the
  /// user out afterwards because their token belongs to the other server.
  static Future<void> setDev(bool dev) async {
    _isDev = dev;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefKey, dev);
    getIt<Dio>().options.baseUrl = baseUrl;
  }
}

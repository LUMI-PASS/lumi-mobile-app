import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService _instance = RemoteConfigService._();
  static RemoteConfigService get instance => _instance;

  FirebaseRemoteConfig? _remoteConfig;
  String _currentVersion = '';
  bool _initialized = false;

  bool get isInReview {
    if (!_initialized || _remoteConfig == null) return false;
    final reviewVersion = _remoteConfig!.getString('is_in_review').trim();
    return reviewVersion.isNotEmpty && reviewVersion == _currentVersion;
  }

  // ─── Support contacts ──────────────────────────────────────────────────────
  // Held in Remote Config, not in the binary: support moves to another operator
  // or another Telegram account without an app release. Both ship with a
  // default so a cold start with no fetch (or no network) still has something
  // to offer — and an empty value in the console hides that option outright.

  /// Support's Telegram, as a username (`lumipass_support`), a `@username`, or
  /// a full `https://t.me/...` link — whatever the console holds. Normalized
  /// into a URL by [supportTelegramUrl].
  static const _defaultTelegram = 'lumipass_support';

  /// Support's phone in international form.
  static const _defaultPhone = '+998957117000';

  String get _telegramRaw =>
      _string('support_telegram', _defaultTelegram);

  String get supportPhone => _string('support_phone', _defaultPhone);

  /// Empty when the console blanks the value — the caller hides the option.
  String get supportTelegramUrl {
    final raw = _telegramRaw;
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return 'https://t.me/${raw.replaceFirst('@', '')}';
  }

  /// What the Telegram row shows: `@username`, or the link itself when the
  /// console holds a full URL (a group invite, say).
  String get supportTelegramLabel {
    final raw = _telegramRaw;
    if (raw.isEmpty) return '';
    if (raw.startsWith('http')) return raw;
    return raw.startsWith('@') ? raw : '@$raw';
  }

  bool get hasSupportTelegram => supportTelegramUrl.isNotEmpty;
  bool get hasSupportPhone => supportPhone.isNotEmpty;

  /// Remote value, trimmed. [fallback] covers the case where Remote Config
  /// never initialized at all; once it has, the registered defaults already
  /// stand in until the first fetch lands — and a value the console blanks on
  /// purpose comes back empty, which is how an option gets hidden.
  String _string(String key, String fallback) {
    if (!_initialized || _remoteConfig == null) return fallback;
    return _remoteConfig!.getString(key).trim();
  }

  Future<void> init() async {
    if (_initialized) return;

    final packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = packageInfo.version;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      await _remoteConfig?.setDefaults({
        'is_in_review': '',
        'support_telegram': _defaultTelegram,
        'support_phone': _defaultPhone,
      });

      await _remoteConfig?.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 5),
      ));

      await _remoteConfig?.fetchAndActivate();
    } catch (_) {}

    _initialized = true;
  }
}

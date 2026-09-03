import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ─── Yandex MapKit key ─────────────────────────────────────────────────────
  // MapKit is handed its key natively — `MainApplication.onCreate` on Android,
  // `didFinishLaunchingWithOptions` on iOS — and both run before Dart does, so
  // no Remote Config value can reach MapKit in time for the launch it was
  // fetched on. What [init] does instead is cache the resolved key in
  // shared_preferences, where the native bootstrap reads it on the *next* cold
  // start. The MapKit locale already works this way for the same reason; see
  // docs/YANDEX_MAP_MIGRATION.md §6.3.
  //
  // So: rotating the key in the console takes effect one cold start later, but
  // without an app release.
  //
  // A non-empty console value beats the build-time key (`yandexMapkitKey` in
  // key.properties, `YANDEX_MAPKIT_KEY` in Secrets.xcconfig) — that is the
  // point of holding it here. Blank the value in the console to hand control
  // back to the build.

  /// The key compiled into the app, used until Remote Config has been read at
  /// least once. It is bound to `uz.lumi.mobileapp` and the registered iOS
  /// bundle id in the Yandex dashboard, so it is a client identifier rather
  /// than a secret — it has to ship in the binary either way.
  static const _defaultYandexMapKitKey = '17bb5f1b-73ed-4764-a574-6fb23e4079b3';

  /// The shared_preferences key the native side reads (namespaced `flutter.`
  /// there — `flutter.yandex_mapkit_key`).
  static const _yandexMapKitKeyPref = 'yandex_mapkit_key';

  /// Empty when the console blanks the value, which is how the build-time key
  /// is put back in charge.
  String get yandexMapKitKey =>
      _string('yandex_mapkit_key', _defaultYandexMapKitKey);

  // ─── App update gate ───────────────────────────────────────────────────────
  // Two version floors decide, per installed build, whether the user is shown
  // nothing, a dismissible "there is a new version" sheet, or a blocking
  // update screen. Both are plain version strings ("2.1.0") in the console:
  //
  //   installed <  min_supported_version                  → forced update
  //   min_supported_version <= installed < latest_app_version → optional update
  //   otherwise                                            → nothing
  //
  // Leaving both keys empty (the shipped default) turns the whole gate off, so
  // a console that was never filled in can never lock anyone out.

  static const _defaultStoreLinkAndroid =
      'https://play.google.com/store/apps/details?id=uz.lumi.mobileapp';
  static const _defaultStoreLinkIos =
      'https://apps.apple.com/uz/app/lumipass/id6761327966';

  /// Builds below this must update before they can use the app. Empty = off.
  String get minSupportedVersion => _string('min_supported_version', '');

  /// Newest build in the stores. Anything older (but still supported) gets the
  /// dismissible sheet. Empty = no optional prompt.
  String get latestAppVersion => _string('latest_app_version', '');

  /// Optional console-authored subtitle ("what's new"), shown in place of the
  /// built-in localized copy when set. Empty = use the app's own text.
  String get updateDescription => _string('update_description', '');

  /// Where the update button sends the user, per store.
  String get storeLink {
    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final key = isIos ? 'store_link_ios' : 'store_link_android';
    final fallback = isIos ? _defaultStoreLinkIos : _defaultStoreLinkAndroid;
    final value = _string(key, fallback);
    return value.isEmpty ? fallback : value;
  }

  /// The installed build's version ("2.0.5"), read once at [init].
  String get currentVersion => _currentVersion;

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
        'min_supported_version': '',
        'latest_app_version': '',
        'update_description': '',
        'store_link_android': _defaultStoreLinkAndroid,
        'store_link_ios': _defaultStoreLinkIos,
        'yandex_mapkit_key': _defaultYandexMapKitKey,
      });

      await _remoteConfig?.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 5),
      ));

      await _remoteConfig?.fetchAndActivate();
    } catch (_) {}

    _initialized = true;

    // Only once Remote Config actually came up: with no `_remoteConfig` every
    // read returns the compiled-in fallback, and writing that to the cache
    // would overwrite a perfectly good build-time key with a guess.
    if (_remoteConfig != null) await _cacheYandexMapKitKey();
  }

  /// Leaves the MapKit key where the native bootstrap can find it on the next
  /// cold start. Clearing it on an empty console value is what lets the
  /// build-time key take back over.
  Future<void> _cacheYandexMapKitKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = yandexMapKitKey;
      if (key.isEmpty) {
        await prefs.remove(_yandexMapKitKeyPref);
      } else if (prefs.getString(_yandexMapKitKeyPref) != key) {
        await prefs.setString(_yandexMapKitKeyPref, key);
      }
    } catch (_) {}
  }
}

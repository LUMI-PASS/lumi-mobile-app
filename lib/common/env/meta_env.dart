/// Meta (Facebook) app credentials.
///
/// Unlike [AppsFlyerEnv], these values are **also** compiled into the native
/// projects — the Facebook SDK reads its app id and client token from
/// `ios/Runner/Info.plist` and `android/app/src/main/res/values/strings.xml`
/// before any Dart code runs. The constants here exist so the Dart layer can
/// tell whether the app is configured at all, and so there is one documented
/// place naming the values. **Changing one of these means changing the native
/// file too** — see `docs/META.md`.
///
/// Both may be overridden at build time:
///
/// ```
/// flutter build ipa \
///   --dart-define=META_APP_ID=... \
///   --dart-define=META_CLIENT_TOKEN=...
/// ```
///
/// Note that a `--dart-define` override only changes what the Dart layer
/// believes; the native SDK still reads the plist/strings.xml. Overriding is
/// only useful for turning the integration *off* (pass an empty app id).
class MetaEnv {
  const MetaEnv._();

  /// The Meta app id, from App Dashboard → App settings → Basic.
  ///
  /// LumiPass, business portfolio `LumiPass` (`1047789001434658`):
  /// https://developers.facebook.com/apps/1433809481948376/
  static const String appId = String.fromEnvironment(
    'META_APP_ID',
    defaultValue: '1433809481948376',
  );

  /// The client token, from App Dashboard → App settings → Advanced →
  /// Security. Required alongside the app id since Facebook SDK v13 — without
  /// it the SDK refuses to send events.
  ///
  /// Not a secret in the "keep it out of git" sense (it ships inside every
  /// binary, same as the AppsFlyer dev key), but it does let anyone holding it
  /// post events as us, so don't publish it. Rotate via the `Reset` button on
  /// that page, which invalidates the old value immediately.
  static const String clientToken = String.fromEnvironment(
    'META_CLIENT_TOKEN',
    defaultValue: '8a66838afbeed59eef2fd54b76e57b1d',
  );

  /// Everything is priced in soʻm. Meta, like AppsFlyer, assumes USD when the
  /// currency is left off and the revenue columns come out ~12000× too high.
  static const String currency = 'UZS';

  static bool get isConfigured => appId.isNotEmpty && clientToken.isNotEmpty;
}

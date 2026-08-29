/// Meta (Facebook) App Events credentials.
///
/// These have to be compile-time constants: [MetaService.init] runs before
/// the first frame, and the native SDK reads the App ID / Client Token at
/// process start (`Info.plist` on iOS, the manifest meta-data on Android) —
/// there is no way to hand them over later.
///
/// Both values come from the app's Meta for Developers dashboard and are
/// shared by iOS and Android (Meta identifies the *app*, not the platform).
/// Overridable at build time without touching this file:
///
/// ```
/// flutter build ipa \
///   --dart-define=META_APP_ID=... \
///   --dart-define=META_CLIENT_TOKEN=...
/// ```
class MetaEnv {
  const MetaEnv._();

  /// From Meta for Developers → App settings → Basic → App ID. Empty until an
  /// app is actually registered — [MetaService.init] no-ops without it.
  static const String appId = String.fromEnvironment('META_APP_ID');

  /// From Meta for Developers → App settings → Advanced → Client token.
  /// Ships inside every binary like the AppsFlyer dev key does — not a secret
  /// in the "keep it out of git" sense, but don't publish it either.
  static const String clientToken =
      String.fromEnvironment('META_CLIENT_TOKEN');

  static bool get hasCredentials => appId.isNotEmpty && clientToken.isNotEmpty;
}

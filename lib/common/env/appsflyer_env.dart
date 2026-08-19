/// AppsFlyer credentials.
///
/// These have to be compile-time constants: [AppsFlyerService.init] runs before
/// the first frame, and the SDK needs its dev key at construction time.
///
/// The dev key is the same for both platforms (it identifies the AppsFlyer
/// *account*, not the app). The iOS App Store id is what tells AppsFlyer which
/// of the account's apps this build is — Android is identified by its package
/// name, so it needs nothing extra.
///
/// Both values may be overridden at build time without touching this file:
///
/// ```
/// flutter build ipa \
///   --dart-define=APPSFLYER_DEV_KEY=... \
///   --dart-define=APPSFLYER_IOS_APP_ID=...
/// ```
class AppsFlyerEnv {
  const AppsFlyerEnv._();

  /// AppsFlyer dev key, from Dashboard → App settings → Dev key. Not a secret
  /// in the "keep it out of git" sense — it ships inside every binary — but it
  /// does let anyone holding it post events as us, so don't publish it.
  static const String devKey = String.fromEnvironment(
    'APPSFLYER_DEV_KEY',
    defaultValue: 'ujpdsHEqmfkCV3EfnBoHsL',
  );

  /// The numeric App Store id (digits only, no `id` prefix) — AppsFlyer
  /// asserts on `^\d{8,11}$` and refuses to initialise on iOS without it.
  ///
  /// LumiPass, bundle `uz.lumipass.mobile`:
  /// https://apps.apple.com/app/lumipass/id6761327966
  static const String iosAppId = String.fromEnvironment(
    'APPSFLYER_IOS_APP_ID',
    defaultValue: '6761327966',
  );

  /// The OneLink domain campaign links are served from — Lumi uses a branded
  /// domain rather than a `*.onelink.me` subdomain.
  ///
  /// Nothing at runtime reads this: incoming links are resolved by the SDK
  /// itself. It is here because the same host is hardcoded in the two places
  /// that make the OS hand those links to the app, and they must not drift:
  /// the `autoVerify` intent filter in `android/app/src/main/AndroidManifest.xml`
  /// and `applinks:` in both `ios/Runner/*.entitlements`.
  static const String oneLinkDomain = String.fromEnvironment(
    'APPSFLYER_ONELINK_DOMAIN',
    defaultValue: 'link.lumipass.uz',
  );

  /// The OneLink *template* id — the short code from Dashboard → OneLink
  /// Management (e.g. `H5hv`), **not** a domain. The SDK takes it as
  /// `appInviteOneLink` and uses it only to build outgoing links via
  /// `generateInviteLink`.
  ///
  /// Template `redirection_profile`, subdomain `lumipass.onelink.me`.
  static const String oneLinkTemplateId = String.fromEnvironment(
    'APPSFLYER_ONELINK_TEMPLATE_ID',
    defaultValue: 'JBWe',
  );

  /// Everything is priced in soʻm; AppsFlyer needs the currency spelled out or
  /// it assumes USD and the revenue dashboards are off by ~12000×.
  static const String currency = 'UZS';

  static bool get hasDevKey => devKey.isNotEmpty;

  static final RegExp _iosAppIdPattern = RegExp(r'^\d{8,11}$');

  static bool get hasValidIosAppId => _iosAppIdPattern.hasMatch(iosAppId);
}

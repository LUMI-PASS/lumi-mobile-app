import Flutter
import UIKit
import UserNotifications
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    configureYandexMapKit()
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  /// MapKit needs its key and locale before any map exists. Both are set once
  /// per process and cannot change afterwards — see the note in
  /// `MainApplication.kt` and docs/YANDEX_MAP_MIGRATION.md §6.3.
  private func configureYandexMapKit() {
    // Skipping setApiKey is NOT an option: yandex_mapkit's plugin registration
    // calls YMKMapKit.sharedInstance(), which raises an NSAssertion ("set the
    // apikey before creating MapKit") and aborts the process before the first
    // frame. There is always a key to give it — worst case the one compiled in.
    // Mirrors MainApplication.onCreate().
    YMKMapKit.setApiKey(mapKitApiKey())
    YMKMapKit.setLocale(mapKitLocale())
  }

  /// The key to hand MapKit, most-recently-authoritative first:
  ///
  ///  1. what Firebase Remote Config resolved on a previous launch, cached by
  ///     `RemoteConfigService`;
  ///  2. `YANDEX_MAPKIT_KEY` from the gitignored Flutter/Secrets.xcconfig,
  ///     reaching us through Info.plist;
  ///  3. `defaultMapKitKey`.
  ///
  /// Remote Config outranks the build deliberately: rotating the key in the
  /// console is the whole reason it is held there, and a build that already
  /// carries a key would otherwise ignore it forever. Blanking the console
  /// value clears the cache and hands the build-time key back its job.
  ///
  /// MapKit is keyed here, before Dart runs, so a console change can only reach
  /// it on the *next* cold start — the same one-launch lag as the locale.
  private func mapKitApiKey() -> String {
    // shared_preferences namespaces every Dart key with "flutter.".
    let cached = (UserDefaults.standard.string(forKey: "flutter.yandex_mapkit_key") ?? "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    if !cached.isEmpty { return cached }

    let configured = (Bundle.main.object(forInfoDictionaryKey: "YandexMapKitKey") as? String ?? "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    if !configured.isEmpty { return configured }

    NSLog("[YandexMapKit] no key in Secrets.xcconfig and none cached from Remote Config — using the built-in key")
    return Self.defaultMapKitKey
  }

  /// The key compiled into the app, used until Remote Config has been read at
  /// least once. Bound to the registered bundle id in the Yandex dashboard, so
  /// it is a client identifier rather than a secret — it ships in the IPA
  /// whichever way it gets here.
  private static let defaultMapKitKey = "17bb5f1b-73ed-4764-a574-6fb23e4079b3"

  /// The map's language, read from the locale easy_localization persisted.
  /// Mirrors `MainApplication.mapKitLocale()` on Android.
  private func mapKitLocale() -> String {
    // shared_preferences namespaces every Dart key with "flutter.".
    switch UserDefaults.standard.string(forKey: "flutter.locale") {
    case "ru_RU": return "ru_RU"
    case "uz_UZ": return "uz_UZ"
    // The app stores "en_EN", which is not a real region tag.
    case "en_EN", "en_US": return "en_US"
    // First launch, before _seedDefaultLocale has written anything.
    default: return "uz_UZ"
    }
  }
}

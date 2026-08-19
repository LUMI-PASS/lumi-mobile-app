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
    // Fed from the gitignored Flutter/Secrets.xcconfig. Missing on a fresh
    // checkout, which must not crash the app — the map renders blank instead.
    let configured = Bundle.main.object(forInfoDictionaryKey: "YandexMapKitKey") as? String ?? ""
    if configured.isEmpty {
      NSLog("[YandexMapKit] no API key — set YANDEX_MAPKIT_KEY in ios/Flutter/Secrets.xcconfig")
    }
    // Skipping setApiKey is NOT an option: yandex_mapkit's plugin registration
    // calls YMKMapKit.sharedInstance(), which raises an NSAssertion ("set the
    // apikey before creating MapKit") and aborts the process before the first
    // frame. A syntactically valid placeholder keeps MapKit constructible —
    // its tile requests are then rejected and the map draws blank, which is
    // the intended keyless behaviour. Mirrors MainApplication.onCreate().
    YMKMapKit.setApiKey(configured.isEmpty ? Self.placeholderMapKitKey : configured)
    YMKMapKit.setLocale(mapKitLocale())
  }

  /// Stands in for a real key on a checkout without Secrets.xcconfig.
  private static let placeholderMapKitKey = "00000000-0000-0000-0000-000000000000"

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

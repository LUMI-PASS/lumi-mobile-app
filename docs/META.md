# Meta (Facebook) App Events

In-app event logging for Meta Ads attribution and campaign optimization, via
the `facebook_app_events` Flutter wrapper around Meta's native App Events SDK.

**Status: implemented but inert.** Every credential in the repo is a
placeholder. Nothing reaches Meta until the external setup below is done and
the real credentials replace the placeholders.

## Where the pieces live

| Piece | File |
| --- | --- |
| Credentials | `lib/common/env/meta_env.dart` |
| SDK wrapper | `lib/data/service/meta_service.dart` |
| Event mirroring | `lib/data/service/analytics_service.dart` |
| Startup | `lib/main.dart` (`_runNative`) |
| iOS keys | `ios/Runner/Info.plist`, `ios/Flutter/Secrets.xcconfig` (gitignored) |
| Android keys | `android/app/src/main/AndroidManifest.xml` |

Dependency: `facebook_app_events` in `pubspec.yaml`.

## Configuration

| Value | Where | Current value |
| --- | --- | --- |
| App ID | `ios/Flutter/Secrets.xcconfig` → `META_APP_ID`; `AndroidManifest.xml` → `com.facebook.sdk.ApplicationId` | placeholder `0000000000000000` |
| Client token | same files, `META_CLIENT_TOKEN` / `com.facebook.sdk.ClientToken` | placeholder `00000000000000000000000000000000` |
| Dart-side gate | `--dart-define=META_APP_ID=...` / `--dart-define=META_CLIENT_TOKEN=...` | unset → `MetaEnv.hasCredentials` is `false` |

`MetaService.init()` checks `MetaEnv.hasCredentials` (the dart-define pair,
**not** the Info.plist/manifest values — Dart can't read those) before calling
into the native SDK at all. This means two independent places have to be
updated together once a real app exists, or the app will look "set up" on the
native side while `MetaService` still silently no-ops:

1. Replace the placeholders in `Secrets.xcconfig` (and `Secrets.example.xcconfig`
   for documentation) and in `AndroidManifest.xml`.
2. Pass the same values via `--dart-define` at build time.

The Android manifest values can't be left empty like `Secrets.xcconfig` can —
the Facebook Android SDK auto-initializes at process start via its own
`ContentProvider` and can crash on a missing/empty App ID, unlike iOS's
`FBSDKCoreKit`, which just logs a warning. That's why the Android meta-data
carries a non-empty dummy value instead of an unset build variable.

## What's needed before this goes live (outside the codebase)

Codebase changes alone are not enough — none of this exists yet:

1. **Register an app** in [Meta for Developers](https://developers.facebook.com/)
   → get a real App ID and Client Token.
2. **Add platforms** in the app dashboard:
   - iOS: bundle id `uz.lumipass.mobile`, App Store id `6761327966`.
   - Android: package `uz.lumi.mobileapp` + key hashes — same two-key problem
     AppsFlyer already solved (see `docs/APPSFLYER.md`): the Play App Signing
     cert hash **and** the upload-key hash, both from Play Console → App
     signing, not the local keystore.
3. **Link the app to Meta Business Manager** (Business Settings → Accounts →
   Apps) — an unlinked app logs events into a void; nothing shows up under an
   ad account for optimization without this.
4. **Events Manager → Aggregated Event Measurement (AEM)**: configure up to 8
   priority conversion events (e.g. `Purchase`, `CompleteRegistration`,
   `InitiateCheckout`) so Meta can still optimize campaigns under iOS 14.5+
   ATT limits.
5. **Store privacy declarations** — a second tracking SDK is a disclosure
   change:
   - App Store Connect → App Privacy → "Data Used to Track You" needs Meta
     added alongside AppsFlyer.
   - Play Console → Data safety form, same idea.

No App Review is needed just to log standard/custom App Events — that only
gates things like Facebook Login, which this integration doesn't use.

## Events

Mirrored the same way AppsFlyer is: screens call `AnalyticsService.logEvent`,
which fires Firebase, AppsFlyer, and Meta from one call site.

| Ours | Meta |
| --- | --- |
| `login` | custom event `login` |
| `sign_up`, `registration_completed` | `logCompletedRegistration` |
| `class_detail_viewed`, `activity_detail_viewed`, `branch_detail_viewed` | `logViewContent` |
| `book_button_tapped` | `logAddToCart` (falls back to a plain `fb_mobile_add_to_cart` event if the call site didn't send a content id/type/price) |
| `booking_checkout_started`, `checkout_page_opened`, `plan_purchase_started`, `subscription_purchase_started` | `logInitiatedCheckout` |
| `payment_succeeded` | `logPurchase` (falls back to a plain event if `amount`/`price` is missing) |

`app_open` is deliberately not forwarded — `activateApp()` counts sessions on
its own, same reasoning as the AppsFlyer mirror.

Content id/type are derived from whichever of `class_id`/`activity_id`/
`plan_id`/`branch_id` the call site sent; `amount`/`price` → the typed
methods' `price`/`totalPrice`/`amount` params; `currency` defaults to `UZS`.

## ATT (App Tracking Transparency)

No separate prompt. `AppsFlyerService` already raises the one ATT prompt the
app needs (`docs/APPSFLYER.md` § iOS ATT); `MetaService.init()` just calls
`setAdvertiserIdCollectionEnabled(true)`, which consents to *attempting*
advertiser-id collection — the current SDK version derives the actual iOS
consent from ATT itself, so there's nothing further to wire up here. On
Android there's no OS-level gate, so this is the real switch there.

## Verifying (once real credentials are in)

1. Run a debug build with `--dart-define=META_APP_ID=... --dart-define=META_CLIENT_TOKEN=...`
   and watch for `[Meta] initialised`, then `[Meta] event:...` lines.
2. Meta Events Manager → your app → **Test Events** (turn on test mode via a
   device's advertising id, or use `adb shell setprop debug.com.facebook.sdk.AppEventsLogger.app <app_id>`
   on Android for verbose native logs).
3. Meta Business Manager → Ads Manager: confirm the linked app shows event
   volume within a few minutes of a debug session.

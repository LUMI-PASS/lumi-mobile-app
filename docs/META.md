# Meta (Facebook) app events

Install and in-app-event attribution for Meta app-install campaigns, alongside
the AppsFlyer integration in `docs/APPSFLYER.md`.

## The app

| | |
| --- | --- |
| App name | LumiPass |
| App ID | `1433809481948376` |
| Client token | `8a66838afbeed59eef2fd54b76e57b1d` |
| Business portfolio | LumiPass (`1047789001434658`) |
| Dashboard | https://developers.facebook.com/apps/1433809481948376/ |
| iOS bundle ID | `uz.lumipass.mobile` (+ iPhone Store ID `6761327966`) |
| Android package | `uz.lumi.mobileapp`, class `uz.lumi.mobileapp.MainActivity` |

The app id and client token are **not secrets in the "keep them out of git"
sense** — they ship inside every binary, same as the AppsFlyer dev key — but
anyone holding them can post events as us. Rotate the client token with the
`Reset` button on App settings → Advanced → Security; it invalidates the old
value immediately, so both native files have to be updated in the same change.

## Where the pieces live

| Piece | File |
| --- | --- |
| Credentials (Dart mirror) | `lib/common/env/meta_env.dart` |
| SDK wrapper | `lib/data/service/meta_service.dart` |
| Event mirroring | `lib/data/service/analytics_service.dart` |
| Startup | `lib/main.dart` (`_runNative`) |
| iOS keys | `ios/Runner/Info.plist` |
| Android keys | `android/app/src/main/res/values/strings.xml` |
| Android meta-data | `android/app/src/main/AndroidManifest.xml` |

Dependency: `facebook_app_events` in `pubspec.yaml`.

**The SDK is configured natively, not from Dart.** The Facebook SDK reads its
app id and client token out of `Info.plist` (iOS) and, via its own
`ContentProvider`, out of the manifest meta-data at process start — before any
Dart runs. `MetaEnv` only *mirrors* those values so the Dart layer can tell
whether the integration is configured at all. **Changing a credential means
changing all three files.**

On Android the values must be `@string/` resources, not literals: a bare
`android:value="1433809481948376"` is parsed as an integer, overflows, and the
SDK reports an invalid app id at runtime.

`MetaService.init()` degrades rather than crashes — an unsupported platform
(web) or an empty app id logs `[Meta] skipped — ...` and leaves the service
inert.

## Events

Screens keep calling `AnalyticsService.logEvent`. That method fires Firebase,
mirrors into AppsFlyer, and mirrors into Meta — there is no second call site to
keep in sync, and no `MetaService` usage outside the analytics layer.

Funnel events are translated onto Meta's standard catalogue, because only
catalogue events can be optimised against and attributed to ad spend:

| Ours | Meta |
| --- | --- |
| `sign_up`, `registration_completed` | `fb_mobile_complete_registration` |
| `class_detail_viewed`, `activity_detail_viewed`, `branch_detail_viewed` | `fb_mobile_content_view` |
| `book_button_tapped` | `fb_mobile_add_to_cart` |
| `booking_checkout_started`, `checkout_page_opened`, `plan_purchase_started`, `subscription_purchase_started` | `fb_mobile_initiated_checkout` |
| `payment_succeeded` | `fb_mobile_purchase` |

Everything else goes through under its own name as a custom event. There is
deliberately no mapping for `login` — Meta has no standard login event.

`app_open` is **not** forwarded: `FacebookAutoLogAppEventsEnabled` already makes
the SDK log its own activation, and mirroring ours would double-count sessions.

`payment_succeeded` goes through `logPurchase()` rather than
`logEvent('fb_mobile_purchase')` — only the former populates the revenue and
ROAS columns in Ads Manager.

Standard parameters are derived from whatever the call site already sends:
`class_id`/`activity_id`/`plan_id`/`branch_id` → `fb_content_id` (+
`fb_content_type`), `order_id` → `fb_order_id`, `ticket_count` →
`fb_num_items`, `amount`/`price` → the summable value (and the purchase
amount), `currency` → `fb_currency` (default `UZS`, or Meta assumes USD and
revenue is off by ~12000×).

### PII is stripped

`AnalyticsService` stamps **every** event with `user_id` and `phone_number` for
our own reporting. Meta's platform terms forbid sending personal data as event
parameters — a phone number in a parameter is exactly the case they call out —
and events carrying it are dropped, with the app at risk of being flagged.

`MetaService._piiKeys` removes both before anything is sent. The user id still
reaches Meta, but through `setUserID()`, which is the supported channel and is
hashed natively. **Anything added to the merged-params set in
`AnalyticsService` that identifies a person has to be added to `_piiKeys` too.**

## iOS ATT and SKAdNetwork

The Facebook SDK derives tracking consent from the ATT verdict on iOS 17+;
there is no separate opt-in to make. `AppsFlyerService` already raises the ATT
prompt one frame after launch, and both SDKs read the same answer — so ATT is
requested exactly once, by AppsFlyer, and Meta inherits it. Without consent the
SDK still logs events, just without the IDFA.

`SKAdNetworkItems` in `Info.plist` lists Meta's two ids
(`v9wttpbfk9.skadnetwork`, `n38lu8286q.skadnetwork`) next to AppsFlyer's. Both
Meta ids are required — postbacks are signed with one or the other depending on
placement.

Note that `NSAdvertisingAttributionReportEndpoint` points SKAdNetwork postbacks
at AppsFlyer, which is deliberate: AppsFlyer is the single source of truth for
SKAN and forwards to the networks. Meta's copy of an install comes through its
own SDK, not through SKAN.

## Connecting the app to an ad account

Registering the app is **not** enough for it to appear in Ads Manager's app
picker when creating an app-promotion campaign. The app is an asset of the
business portfolio that owns it, and it has to be shared with the ad account
that runs the campaign:

Business Settings → Accounts → Apps → LumiPass → **Connected assets / Add
people and assets** → add the ad account.

If the ad account lives in a *different* business portfolio from the app, that
sharing is the only thing that links them — the app will otherwise never show
up in the picker, no matter how the SDK is configured.

Also note the picker searches by the **store listing name**. The Play listing
is published as "Lumi" (`android:label` is `Lumi`), not "LumiPass", so
searching for "LumiPass" finds nothing.

## Verifying

1. Run a debug build and watch for `[Meta] initialised (app 1433809481948376)`,
   then `[Meta] event:fb_...` lines.
2. Events Manager → the LumiPass app dataset → **Test events**: register the
   device and events appear within seconds. This is the fastest end-to-end
   check that the app id, client token and platform settings all match.
3. Events Manager → Overview shows aggregate volume within ~20 minutes.

A missing app id or an unsupported platform logs a `[Meta] skipped — ...` line
at startup and leaves the service inert.

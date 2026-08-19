# AppsFlyer

Install attribution, in-app events and OneLink deep links for iOS and Android.

## Where the pieces live

| Piece | File |
| --- | --- |
| Credentials | `lib/common/env/appsflyer_env.dart` |
| SDK wrapper | `lib/data/service/appsflyer_service.dart` |
| Event names | `lib/data/service/analytics_event.dart` |
| Event mirroring | `lib/data/service/analytics_service.dart` |
| Startup | `lib/main.dart` (`_runNative`) |
| Deep-link routing | `lib/data/service/deeplink_service.dart` (`handleAppsFlyerLink`) |
| iOS keys | `ios/Runner/Info.plist` |
| OneLink host (iOS) | `ios/Runner/Runner.entitlements`, `ios/Runner/RunnerRelease.entitlements` |
| OneLink host (Android) | `android/app/src/main/AndroidManifest.xml` |

Dependencies: `appsflyer_sdk` and `app_tracking_transparency` in `pubspec.yaml`.
The only thing `AndroidManifest.xml` contributes is the OneLink intent filter —
permissions come from the plugin's own manifest, which merges in `INTERNET`,
`ACCESS_NETWORK_STATE` and `AD_ID`.

## Configuration

Both platforms are configured out of the box — nothing has to be passed at
build time.

| Value | Default in `AppsFlyerEnv` | Why |
| --- | --- | --- |
| Dev key | `ujpdsHEqmfkCV3EfnBoHsL` | Identifies the AppsFlyer account |
| iOS App Store id | `6761327966` | LumiPass, bundle `uz.lumipass.mobile` — AppsFlyer identifies an iOS app by this number, asserts on `^\d{8,11}$`, and cannot attribute installs without it. Android is identified by its package name and needs nothing extra. |
| OneLink domain | `link.lumipass.uz` | Branded domain campaign links are served from |
| Currency | `UZS` | Or AppsFlyer assumes USD and revenue is off by ~12000× |

Each can still be overridden per build:

| Define | Meaning |
| --- | --- |
| `APPSFLYER_DEV_KEY` | Account dev key |
| `APPSFLYER_IOS_APP_ID` | Numeric App Store id, digits only |
| `APPSFLYER_ONELINK_DOMAIN` | The branded OneLink host |
| `APPSFLYER_ONELINK_TEMPLATE_ID` | OneLink *template* id — see below |

`AppsFlyerService.init()` still degrades rather than crashes: a missing dev key
or a malformed App Store id logs `[AppsFlyer] skipped — ...` and leaves the
service inert instead of tripping the SDK's assert.

**Domain vs template id.** The SDK's `appInviteOneLink` option maps to the
native `setAppInviteOneLink(oneLinkId)`, which wants the short template id from
Dashboard → OneLink Management — *not* a domain. It is used only to build
outgoing links with `generateInviteLink`. `oneLinkDomain` is the separate,
documentation-only constant recording the host hardcoded in the manifest and
entitlements.

The account has one template, created 2026-08-19:

| | |
| --- | --- |
| Template name | `redirection_profile` |
| Template id | `JBWe` |
| OneLink subdomain | `lumipass.onelink.me` |
| Branded domain | `link.lumipass.uz` |
| Apps | LumiPass (`id6761327966`) + Lumi (`uz.lumi.mobileapp`) |
| Redirect when not installed | iOS → App Store, Android → Google Play, desktop → App Store website |

The subdomain is permanent — AppsFlyer refuses to change it once links exist on
the template.

Debug logging follows `APP_ENV`: dev builds get AppsFlyer's verbose native logs,
prod builds don't.

## Events

Screens keep calling `AnalyticsService.logEvent`. That method fires Firebase as
before and mirrors the same event into AppsFlyer — there is no second call site
to keep in sync, and no `AppsFlyerService` usage outside the analytics layer.

Events on the purchase funnel are translated onto AppsFlyer's standard `af_*`
catalogue, because only catalogue events can be attributed to ad spend:

| Ours | AppsFlyer |
| --- | --- |
| `login` | `af_login` |
| `sign_up`, `registration_completed` | `af_complete_registration` |
| `class_detail_viewed`, `activity_detail_viewed`, `branch_detail_viewed` | `af_content_view` |
| `book_button_tapped` | `af_add_to_cart` |
| `booking_checkout_started`, `checkout_page_opened`, `plan_purchase_started`, `subscription_purchase_started` | `af_initiated_checkout` |
| `payment_succeeded` | `af_purchase` |

Everything else goes through under its own name as a custom event.

Standard parameters are derived from whatever the call site already sends:
`class_id`/`activity_id`/`plan_id`/`branch_id` → `af_content_id` (+
`af_content_type`), `order_id` → `af_order_id`, `ticket_count` → `af_quantity`,
`amount`/`price` → `af_revenue` on a purchase and `af_price` everywhere else,
`currency` → `af_currency` (default `UZS`).

`app_open` is deliberately **not** forwarded — AppsFlyer counts sessions itself
and would double-count it.

Our own parameters ride along unchanged, so raw-data exports still carry
`user_id` and `phone_number`. `AnalyticsService.identify()` also pushes the
user id to AppsFlyer as the Customer User ID, which is what lets AppsFlyer's
exports be joined against the backend.

## Deep links

`AppsFlyerService` registers a Unified Deep Linking (UDL) callback and hands
the resolved target to `DeeplinkService.handleAppsFlyerLink`, which routes it
through the same code path as `lumi://class/<id>` and the `/share/class/<id>`
App Link. Deferred deep links (clicked before install, replayed on first
launch) come through the same callback with `is_deferred: true` and are treated
as a cold start.

Two OneLink shapes are understood:

* `deep_link_value` holding a whole URI — `lumi://class/<id>` or a
  `https://mobile-api.lumipass.uz/share/class/<id>` share link;
* `deep_link_value: class` with the id in `deep_link_sub1` (or `class_id`).

### Registering the OneLink domain

Links are served from **two** hosts and both are claimed by the app:

| Host | What it is |
| --- | --- |
| `lumipass.onelink.me` | The raw OneLink subdomain. AppsFlyer serves every link here regardless of branding, and its own setup snippet asks for this host. |
| `link.lumipass.uz` | The branded domain campaigns use. A CNAME alias in front of the same service. |

Both appear in the `autoVerify` intent filter in
`android/app/src/main/AndroidManifest.xml` and as `applinks:` entries in **both**
`ios/Runner/Runner.entitlements` and `ios/Runner/RunnerRelease.entitlements`.
Claiming only the branded one would break any link that went out on the
`onelink.me` host.

There is no `pathPrefix` on the Android filter, but note the iOS association
file scopes itself to `/JBWe/*` — the template id. A second OneLink template
would need its own path added by AppsFlyer.

**DNS.** `lumipass.uz` is on Cloudflare (nameservers
`syeef`/`journey.ns.cloudflare.com`):

| Type | Name | Target | Proxy | TTL |
| --- | --- | --- | --- | --- |
| CNAME | `link` | `lumipass.customlinks.appsflyer.com` | **DNS only** | Auto |

It must stay grey-cloud. Proxied, Cloudflare answers `/.well-known/*` itself
instead of AppsFlyer and verification fails on both platforms.

Beware the wizard's chicken-and-egg: AppsFlyer refuses a branded domain that
doesn't already resolve ("Domain doesn't exist"), but only reveals the CNAME
destination at the *last* step, after the domain has been accepted. And that
destination is **not** the `onelink.me` subdomain shown in step 2 — it is a
separate `*.customlinks.appsflyer.com` host. So the record has to be created
pointing anywhere resolvable, then repointed at the real target.

### App-side settings that make the association files work

`OneLink Management → redirection_profile → When app is installed` is what
populates the association files. Empty settings there produce a valid-looking
but empty `apple-app-site-association` (`"details": []`) and a 404 on
`assetlinks.json`, which is indistinguishable from "not set up" when debugging.

| Setting | Value |
| --- | --- |
| iOS | Launch via Universal Links, Team ID `3P359JC932` (→ `3P359JC932.uz.lumipass.mobile`) |
| Android | Launch via App Links, two SHA-256 fingerprints (below) |
| URI scheme fallback | `lumi://` — registered on iOS in `CFBundleURLTypes` and on Android by the `lumi`/`class` intent filter |

**Two Android fingerprints, and both are needed.** Play App Signing is enabled,
so Play re-signs every release: the certificate on a user's device is *not* the
upload key.

| Key | SHA-256 | Covers |
| --- | --- | --- |
| Play app signing | `DC:01:5D:D1:…:48:A0` | Everything installed from Google Play |
| Upload | `E8:91:65:F2:…:4D:73:10` | Release APKs built and side-loaded locally |

The Play value is in Play Console → *Protected with Play* → App signing, in the
ready-made Digital Asset Links snippet. Do not read it off the local keystore —
that gives the upload key, and App Links then silently fail to verify for every
real user while working fine on your own device.

### Verifying the link setup

```
curl https://link.lumipass.uz/.well-known/apple-app-site-association
curl https://link.lumipass.uz/.well-known/assetlinks.json
```

`applinks.details` must name `3P359JC932.uz.lumipass.mobile`, and
`sha256_cert_fingerprints` must list both fingerprints above. Repeat for
`lumipass.onelink.me`. Edits take a few minutes to reach the CDN, and the two
hosts do not update in lockstep.

On a device: `adb shell pm get-app-links uz.lumi.mobileapp` (expect `verified`).

## iOS ATT

`Info.plist` carries `NSUserTrackingUsageDescription`, and the service raises
the ATT prompt one frame after launch (the OS silently drops it if asked during
startup). `timeToWaitForATTUserAuthorization: 60` holds the install postback
until the user answers, so the IDFA — when granted — is attached to the install
rather than arriving too late to matter.

`NSAdvertisingAttributionReportEndpoint` points SKAdNetwork postbacks at
AppsFlyer. `SKAdNetworkItems` currently lists only AppsFlyer's own id; **each ad
network we buy from must have its id added there too**, copied from AppsFlyer →
Configuration → SKAdNetwork, or its installs go unattributed.

## Verifying

1. Run a debug build (`APP_ENV=dev` gives verbose SDK logs) and watch for
   `[AppsFlyer] initialised`, then `[AppsFlyer] event:af_...` lines.
2. AppsFlyer dashboard → your app → **Activity / Real-time**: installs and
   events show up within a couple of minutes.
3. For attribution end to end, register the test device in AppsFlyer
   (Settings → Test devices) using the advertising id, then click a OneLink.

A missing dev key, an unsupported platform, or an iOS build without an App
Store id all log a `[AppsFlyer] skipped — ...` line at startup and leave the
service inert.

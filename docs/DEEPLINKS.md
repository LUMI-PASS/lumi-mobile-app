# Deep links

One registry decides which link opens which screen, and it serves every
channel: banners, push payloads, share sheets, AppsFlyer campaigns.

## The three shapes

All three mean the same thing. Use whichever the channel makes easy.

| Shape | Example | Opens the app when |
| --- | --- | --- |
| Custom scheme | `lumi://class/<id>` | always (the app claims the whole `lumi` scheme) |
| App / Universal Link | `https://mobile-api.lumipass.uz/share/class/<id>` | the app is installed and the link is verified; otherwise the browser shows the share page, which offers "Open in Lumi" and a store button |
| AppsFlyer OneLink | `deep_link_value=class`, `deep_link_sub1=<id>` | via the OneLink hosts, including deferred (clicked before install) |

A destination with no id drops the id: `lumi://plans`,
`https://mobile-api.lumipass.uz/share/plans`.

Parameters ride as query string either way —
`lumi://category/<id>?title=Dance`. The id may also be written as `?id=<id>`
instead of a path segment; both resolve identically.

## Where the registry lives

| | |
| --- | --- |
| App (resolves the link) | `lib/common/router/deep_link_routes.dart` |
| Backend (validates + serves the picker) | `src/common/constants/deep-link-targets.ts` |

**These two lists are maintained by hand and must stay in step.** A key in the
backend list that the app does not have is a link the adminka will happily save
and the phone will silently ignore. Adding a destination means one entry in each
file — and a release, because a key the installed build does not know is a
no-op on that build.

## Destinations

| Key | Opens | Needs an id |
| --- | --- | --- |
| `home` `shorts` `calendar` `search` `profile` | the bottom-nav tab | no |
| `class` / `course` / `activity` | class or course detail | yes |
| `branch` | venue detail | yes |
| `category` | discovery filtered to a category | yes |
| `discovery` | discovery search, keyboard up | no |
| `map` | venues map | no |
| `plans` `coupons` `wallet` `cards` `payment-history` | the money screens | no |
| `my-bookings` `notifications` `faq` | account screens | no |
| `referral` | the referral programme screen | no |

## Referral invites are not destinations

An invite link carries a friend's code, and must never open a screen on its
own. `classifyLink` (`lib/common/router/referral_link.dart`) checks for one
before the registry is consulted, so a code can never be mistaken for a key
(`lumi://referral?code=PLANS` stores `PLANS`; it does not open the plans
screen). Recognised shapes:

| Shape | Example |
| --- | --- |
| OneLink (UDL) | `deep_link_value=referral`, code in `deep_link_sub1` / `af_sub1` |
| Raw OneLink URL | `https://link.lumipass.uz/JBWe?deep_link_value=referral&deep_link_sub1=<CODE>` |
| Web fallback | `https://app.lumipass.uz/r/<CODE>` |
| Custom scheme | `lumi://referral?code=<CODE>` or `lumi://referral/<CODE>` |

The code is stored on the device for seven days (`ReferralCoordinator`) —
before the tabs exist, so a deferred invite survives onboarding and login — and
applied silently once there is a session. `lumi://referral` **without** a code
is the ordinary `referral` destination above (push and in-app notifications use
it).

## How a link is routed

`AppLinkOpener.open(link)` is the single entry point for "something outside the
app handed us a link".

1. If `DeepLinkRoutes.resolve` recognises it, it opens **in the app**. That
   includes `https://` links on our own hosts — they are deep links, not web
   pages, and must not be bounced out to the browser.
2. Any other `http(s)` link opens in the device browser.
3. Anything else is logged and dropped.

Unknown keys are never fatal. A banner written against a destination added in a
later release does nothing on an older build, which is the required behaviour.

## Native configuration

Both platforms claim more than they used to; changing either means a release.

- `android/app/src/main/AndroidManifest.xml` — the `lumi` scheme filter has
  **no `android:host`** (it used to pin `class`), and the App Links filter uses
  `android:pathPrefix="/share/"` (it used to pin `/share/class/`).
- `ios/Runner/Info.plist` already claims the whole `lumi` scheme.
- The iOS association file is served by the backend
  (`ShareController.appleAppSiteAssociation`) and lists `/share/*`. iOS fetches
  it at install/update time, so widening it only takes effect for installs after
  the next release — links already in the wild keep working either way.

See `APPSFLYER.md` for the OneLink hosts and their own verification files.

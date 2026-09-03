# Yandex Maps migration plan

Replacing the in-app map (`flutter_map` + CartoDB raster tiles) with Yandex
MapKit.

Status: **Parts 3 and 4 implemented.** `yandex_mapkit` (Option A) chosen, native
setup done (§3.0), and `branches_map_page.dart` ported off `flutter_map` (§4.0).
Both platforms compile with a real key wired in. **Nothing has been run on a
device yet** — no map has been seen to render. That is the outstanding item.

---

## 0. Scope — what actually uses a map today

Exactly **one** screen renders a map in-app:

| File | What it does |
| --- | --- |
| `lib/presentation/app/main/subscreens/search/branches_map_page.dart` | "На карте" — plots every branch of the current search as a labelled pill, tap → pin + bottom card. Zoom ±, "my location", category chips. |

Two things are map-*adjacent* but **out of scope** — they don't render a map:

- `lib/common/widget/map_route_sheet.dart` — uses `map_launcher` to hand a
  destination to Yandex Navi / Google Maps / Apple Maps. Unaffected.
- `lib/common/utils/user_location.dart` — `geolocator` wrapper, plain
  lat/lng, no map package import. Unaffected.

`flutter_polyline_points` is in `pubspec.yaml` but unused — drop it while
we're here.

So the migration is **one screen, ~420 lines**, plus native setup. The risk is
not in the volume, it's in item 4.2 (custom markers) and item 6 (native
requirements).

---

## Part 1 — Your side: getting the API key

Do this first, it gates everything. Budget ~30 minutes plus a 15-minute wait.

### 1.1 Open the Developer Dashboard

<https://developer.tech.yandex.ru/services/>

Log in with a Yandex account. **Use a company account, not a personal one** —
the key is billed and renewed against whoever owns it, and moving a key between
accounts later is a support ticket.

### 1.2 Connect the right API

Click **Connect APIs** → choose **MapKit Mobile SDK**.

⚠️ Not "JavaScript API", not "Geocoder", not "Static API" — those are separate
products with separate keys, and a JS key will not work in the app.

### 1.3 Fill in the project details

You'll be asked for:

- Project / app name → `Lumi`
- App description → a sentence about what it does
- **Android package name** → `uz.lumi.mobileapp`
- **iOS bundle identifier** → `uz.lumipass.mobile`

  ⚠️ The two do **not** match (`uz.lumi.mobileapp` vs `uz.lumipass.mobile`).
  That's fine — Yandex takes both — but register them exactly as written, or the
  key is rejected at runtime on the platform you got wrong.

- Expected MAU (monthly active users) — be honest, this picks the tier.

Yandex binds the key to those two identifiers. This is why the key being
visible in the app binary is acceptable — it's useless in someone else's app.

### 1.4 Pick the pricing plan

Three licenses: **Free**, **Basic**, **Advanced**.

- **Free** — up to **25 000 MAU**, and a shared cap of **25 000 requests/day**
  across search + routing + panoramas. Stylized map, pins, landscape, borders,
  transport. This covers Lumi today with a lot of headroom.
- Basic / Advanced — paid, needed only past those limits or for offline maps,
  panoramas, NaviKit.

Start on **Free**. If we cross 25K MAU that's a good problem and an upgrade in
the dashboard, not a code change.

### 1.5 Wait for activation

The key appears under **API Interfaces → MapKit Mobile SDK**. It takes about
**15 minutes to activate** — a fresh key will make the map render grey/blank
until it does. Don't debug that; wait it out.

### 1.6 Send me

1. The API key string.
2. Confirmation of the exact iOS bundle id you registered.
3. Whether you registered one key for both platforms or two separate ones
   (either works; the dashboard usually issues one key valid for both).

I'll wire it in as a build-time value, **not** committed in plain text — see
§3.3.

> Note: the key `1bb5a540-…-32ffe296a172` is currently hardcoded in
> `MainApplication.kt` in both `yuldago` and `yuldadriver`. Those are private
> repos and the key is package-bound, so it's not an incident — but do **not**
> reuse that key for Lumi. It's registered to a different package name and will
> be rejected.

---

## Part 2 — Package choice

Two real options.

### Option A — `yandex_mapkit` ^4.3.0 (Unact) ← **recommended**

Community plugin, **declarative** API: `YandexMap(mapObjects: [...])`. Maps
almost 1:1 onto the existing `FlutterMap(children: [MarkerLayer(markers: […])])`,
so the migration is mostly a rename of types.

- Wraps native `com.yandex.android:maps.mobile` (lite variant by default, full
  selectable via a gradle property).
- This is the package already shipped in `yuldago` and `yuldadriver` — the team
  has hit its rough edges before.
- Requires **Android SDK 26+**, **iOS 15+**.

Risk: community-maintained, tracks Yandex's native releases with a lag.

### Option B — `yandex_maps_mapkit` 4.42.0 (official, publisher `maps.yandex.ru`)

Yandex's own FFI-generated bindings. Always current, verified publisher — but
**imperative**: you get a `MapWindow`, add listeners, manage map object
collections by hand. There is no `mapObjects:` list to hand a rebuilt array to.
Migrating `branches_map_page.dart` to it means rewriting the state management of
the screen, not just the widget names.

### Recommendation

**Option A.** It preserves the current declarative structure of the screen, and
the failure mode we care about (plugin abandonment) is a future migration we can
take deliberately — whereas Option B costs the rewrite up front, today.

If you'd rather bet on the official package for longevity, say so before I
start — it changes the estimate materially (roughly 1 day → 2–3 days).

---

## Part 3 — Native setup

### 3.0 Status — done

Implemented. The subsections below describe what is now in the tree.

| File | Change |
| --- | --- |
| `pubspec.yaml` | `+ yandex_mapkit: ^4.3.0` (resolves to 4.3.0) |
| `android/gradle.properties` | `yandexMapkit.variant=lite` |
| `android/app/build.gradle.kts` | `minSdk = 26`, `buildFeatures { buildConfig = true }`, `YANDEX_MAPKIT_KEY` buildConfigField, explicit `maps.mobile` compile dependency |
| `android/app/src/main/kotlin/uz/lumi/mobileapp/MainApplication.kt` | **new** — `setApiKey` + `setLocale` |
| `android/app/src/main/AndroidManifest.xml` | `android:name=".MainApplication"` |
| `android/key.properties.example` | **new** — template incl. `yandexMapkitKey` |
| `ios/Podfile` | `platform :ios, '15.0'`, post-install target 15.0 |
| `ios/Runner.xcodeproj/project.pbxproj` | `IPHONEOS_DEPLOYMENT_TARGET` 14.0 → 15.0 (×3) |
| `ios/Runner/AppDelegate.swift` | `configureYandexMapKit()` + `mapKitLocale()` |
| `ios/Runner/Info.plist` | `YandexMapKitKey` = `$(YANDEX_MAPKIT_KEY)` |
| `ios/Flutter/{Debug,Release}.xcconfig` | `#include? "Secrets.xcconfig"` |
| `ios/Flutter/Secrets.example.xcconfig` | **new** — template |
| `ios/.gitignore` | ignores `Flutter/Secrets.xcconfig` |
| `README.md` | local-secrets + platform-minimums sections |

`pod install` pulls `YandexMapsMobile 4.39.1-lite` — the iOS side defaults to
the same `lite` variant Android is pinned to, so no `YANDEX_MAPKIT_VARIANT`
environment variable is needed.

Both platforms degrade quietly with no key: each logs a warning and skips MapKit
setup entirely rather than handing it an empty string. Neither crashes; the map
just won't draw. That is deliberate, so a fresh clone builds.

**Verified — both platforms build.**

Android (`flutter build apk --debug`):
- manifest merges `android:name="uz.lumi.mobileapp.MainApplication"`
- `libmaps-mobile.so` ships for arm64-v8a, armeabi-v7a and x86_64

iOS (`flutter build ios --debug --no-codesign`):
- `Xcode build done` — `AppDelegate.swift` compiles against `YandexMapsMobile`
- MapKit is **statically** linked (4 549 `YMK*` symbols in `Runner.debug.dylib`,
  no dynamic `@rpath` entry and no framework in `Runner.app/Frameworks` — so
  nothing extra to embed or sign)
- `MinimumOSVersion` = `15.0` in the built `Info.plist`
- `YandexMapKitKey` resolves to an empty string when `Secrets.xcconfig` is
  absent — the substitution works and the empty-key guard is what runs, rather
  than a literal `$(YANDEX_MAPKIT_KEY)` reaching MapKit

**Still unverified:** that a map actually *renders*. Both builds ran without a
key, so nothing has yet exercised `setApiKey`. That is step 2b.

### 3.1 Android

**`android/gradle.properties`** — pick the SDK variant:

```properties
yandexMapkit.variant=lite
```

`lite` drops search/routing/panoramas we don't use and is meaningfully smaller.
We only draw a map with pins, so `lite` is correct.

The gradle property picks the variant, but it is **not** the only thing needed.
The plugin declares `"com.yandex.android:maps.mobile:4.39.1-" + variant` as an
`implementation` dependency of its own library module, which puts MapKit on the
app's *runtime* classpath but **not** its *compile* classpath. `MainApplication`
references `MapKitFactory` directly, so without an explicit declaration the build
fails with:

```
e: MainApplication.kt:34:9 Unresolved reference 'MapKitFactory'.
```

Hence `android/app/build.gradle.kts` also carries:

```kotlin
implementation("com.yandex.android:maps.mobile:$yandexMapkitVersion-$yandexMapkitVariant")
```

with the version pinned to what the plugin resolves (4.39.1) and the variant read
back out of the same gradle property, so the two can't drift apart. If a future
plugin bump changes the MapKit version, this line has to move with it.

Repositories need no change — `android/build.gradle.kts` already has
`allprojects { repositories { google(); mavenCentral() } }`, and the artifact is
on Maven Central.

**`android/app/build.gradle.kts`** — raise `minSdk`:

```kotlin
defaultConfig {
    applicationId = "uz.lumi.mobileapp"
    minSdk = 26              // was: flutter.minSdkVersion (= 24 on Flutter 3.44)
    …
}
```

⚠️ **This is a user-facing decision, not a technical detail.** It drops Android
7.x (Nougat) devices. Android 8.0+ is ~99% of the active Android install base in
2026, but check Play Console → Statistics → Android version for *our* users
before merging. If a real slice of users sits on 7.x we need to talk before
proceeding.

**New file `android/app/src/main/kotlin/uz/lumi/mobileapp/MainApplication.kt`:**

Extends `android.app.Application`. **Not** `io.flutter.app.FlutterApplication` —
that belongs to the removed v1 embedding; Flutter 3.44's `${applicationName}`
placeholder resolves to `android.app.Application`
(`BaseApplicationNameHandler.DEFAULT_BASE_APPLICATION_NAME`), so that is what we
must keep extending.

The locale is read from the `flutter.locale` SharedPreferences key that
`easy_localization` writes (see §6.3) rather than hardcoded.

**`android/app/src/main/AndroidManifest.xml`** — point the app at it:

```diff
-        android:name="${applicationName}"
+        android:name=".MainApplication"
```

Permissions are already correct — `INTERNET`, `ACCESS_FINE_LOCATION`,
`ACCESS_COARSE_LOCATION` are all present.

### 3.2 iOS

**`ios/Podfile`** — bump the platform:

```diff
-platform :ios, '14.0'
+platform :ios, '15.0'
```

Then also raise `IPHONEOS_DEPLOYMENT_TARGET` to 15.0 in the Xcode project, or
the pod install will warn on every build.

**`ios/Runner/AppDelegate.swift`** — note this file uses the newer
`FlutterImplicitEngineDelegate` shape, so the key goes in
`didFinishLaunchingWithOptions`, before `super`:

`configureYandexMapKit()` runs first in `didFinishLaunchingWithOptions`, before
`super`. It reads the key with `as? String ?? ""` and returns early on empty —
never `as!`, which would crash the app on a checkout without the key file.

`mapKitLocale()` mirrors `MainApplication.mapKitLocale()` on Android, reading the
same `flutter.locale` value out of `UserDefaults`.

`Info.plist` already carried the location usage strings (geolocator needs them);
the only addition is the key entry from §3.3.

### 3.3 Keeping the key out of git

Not hardcoded the way `yuldago` does it. The key is package-bound so leaking it
is low-severity, but a plaintext key in git is still a finding in any audit.

- **Android** — `yandexMapkitKey=…` in `android/key.properties` (already
  gitignored, already loaded by `build.gradle.kts` for the signing config),
  surfaced as `BuildConfig.YANDEX_MAPKIT_KEY` via a `buildConfigField`. Read with
  `as String?` and defaulted to `""`, so a missing entry doesn't fail
  configuration.
- **iOS** — `YANDEX_MAPKIT_KEY` in `ios/Flutter/Secrets.xcconfig` (gitignored,
  pulled into `Info.plist` as `YandexMapKitKey`). `Debug.xcconfig` and
  `Release.xcconfig` use `#include?` — the optional form — so the build still
  works when the file is absent.
- Templates for both are committed: `android/key.properties.example` and
  `ios/Flutter/Secrets.example.xcconfig`.
- **CI** — both values become pipeline secrets that write those two files before
  the build step. Not yet wired; do it when the key exists.

Since §3.4 a key also ships compiled in, so a fresh clone gets a working map
without either file. Both remain the way to build against a *different* key than
production's.

### 3.4 Rotating the key without a release — Firebase Remote Config

The key is also a Remote Config parameter, `yandex_mapkit_key`, so a rotation in
the Yandex dashboard doesn't need an App Store round trip.

It cannot be read the obvious way. MapKit is keyed from `Application.onCreate`
(Android) and `didFinishLaunchingWithOptions` (iOS), both of which run before the
Dart entrypoint — and `yandex_mapkit` exposes no Dart-side `setApiKey`, so
there's no later hook to use. The value therefore travels one launch behind, the
same way the locale does in §6.3:

1. `RemoteConfigService.init()` resolves `yandex_mapkit_key` and writes it to
   `shared_preferences` as `yandex_mapkit_key`;
2. on the **next** cold start, `MainApplication.mapKitApiKey()` /
   `AppDelegate.mapKitApiKey()` read it back (namespaced `flutter.…`) and hand
   it to MapKit before the first map exists.

Resolution order on both platforms, first non-empty wins:

| # | Source | Set where |
|---|---|---|
| 1 | Remote Config, cached last launch | Firebase console → `yandex_mapkit_key` |
| 2 | Build-time key | `key.properties` / `Secrets.xcconfig` |
| 3 | Compiled-in default | `MainApplication.DEFAULT_KEY` / `AppDelegate.defaultMapKitKey` |

Remote Config outranking the build is deliberate — a release that carries its own
key would otherwise never see a rotation. **Blank the console value** to clear
the cache and give the build-time key its job back.

Consequences worth knowing before you rotate:

- A console change reaches users on their **second** launch after it, not the
  first. Keep the old key alive in the Yandex dashboard until the new one has
  had time to spread.
- `minimumFetchInterval` is 5 minutes (`RemoteConfigService.init`), so the fetch
  side is not the bottleneck; the cold start is.
- A device that has never reached Firebase (offline first run, Play-services-less
  Android) stays on the build-time or compiled-in key indefinitely, which is why
  a working default still ships.

---

## Part 4 — Dart migration: `branches_map_page.dart`

### 4.0 Status — done

| File | Change |
| --- | --- |
| `lib/common/utils/map_marker_bitmap.dart` | **new** — `BranchMarkerPainter` rasterises the branch pill; `MarkerBitmap` carries bytes + anchor + scale |
| `lib/presentation/app/main/subscreens/search/branches_map_page.dart` | ported to `YandexMap`; `_BranchLabel` and `_MyLocationDot` deleted |

`flutter analyze` is clean on both.

**The old stack is deleted.** `flutter_map`, `latlong2` and the already-unused
`flutter_polyline_points` are out of `pubspec.yaml`, taking 7 transitive packages
with them (`dart_earcut`, `dart_polylabel2`, `mgrs_dart`, `proj4dart`,
`simple_sparse_list`, `unicode`, `wkt_parser`) — 10 in total.

That makes the remote-config kill switch in §6.6 **unavailable**: there is no
second implementation to fall back to, so a bad key or a rendering bug in
production needs a hotfix build, not a toggle. Deliberate, at the user's
instruction; noted here so nobody plans a rollout around a switch that isn't
there.

`latlong2` still appears in `pubspec.lock` as a transitive. It is not a leftover
of `flutter_map` — `packages/location` re-exports it from its public API
(`packages/location/lib/location.dart:1`). Nothing under `lib/` imports
`package:location/` at all, so that whole local package looks unused; removing it
is a separate decision from this migration.

#### Clusterization

Added on top of the port — the pills are ~160pt wide, so a city-dense result set
overlapped into an unreadable wall below street zoom.

The placemarks are handed to a `ClusterizedPlacemarkCollection` (`radius: 60`,
`minZoom: 15`) instead of being plotted directly. `minZoom` is deliberately
`_maxFitZoom`: selecting a branch zooms to exactly that level, so a user's pick
always lands on a real pill rather than staying swallowed by a bubble.

Two things that bite here:

- **A cluster has no appearance by default.** MapKit hands `onClusterAdded` an
  appearance placemark carrying only an id and a point — no icon, and the same
  0.5 opacity as above. Without supplying one, every cluster is an invisible
  hole where a group of centres used to be. `BranchMarkerPainter.buildCluster`
  paints the bubble (brand-purple disc, white ring, count, matching shadow),
  sized in three steps so a three-digit count doesn't overflow a circle drawn
  for two.
- **Tapping a cluster of co-located centres does nothing if you only fit their
  bounds.** Centres at (or within 1e-6 of) the same coordinate give a degenerate
  bounding box, so the camera doesn't move and the bubble feels dead.
  `_zoomIntoCluster` fits the bounds only when they are non-degenerate, then
  unconditionally guarantees the camera ends past `minZoom` — otherwise the
  cluster just re-forms.

Per-branch taps still work inside the collection: the plugin's `_findMapObject`
recurses into `ClusterizedPlacemarkCollection.placemarks`, so each placemark's
own `onTap` still resolves.

#### Platform gotchas found while implementing

Two things that are silent, not loud, if you get them wrong:

1. **`PlacemarkMapObject.opacity` defaults to `0.5`,** not 1. Every marker
   renders half transparent unless it is set explicitly.
2. **Icon scale is not portable.** The plugin's Android path decodes bytes to a
   `Bitmap` and hands MapKit `ImageProvider.fromBitmap`, drawn one bitmap pixel
   per screen pixel. The iOS path uses `UIImage(data:)`, which defaults to
   `scale = 1.0`, so UIKit treats each pixel as a **point**. A bitmap rasterised
   at `devicePixelRatio` is therefore correct on Android at `scale: 1` but
   `devicePixelRatio`× too large on iOS. `BranchMarkerPainter._iconScale`
   divides it back out on iOS only. **This one needs eyes on a real iPhone** —
   it is reasoned from the plugin source, not observed.

### 4.1 Type-for-type mapping (the easy 80%)

| Today (`flutter_map`) | Yandex (`yandex_mapkit`) |
| --- | --- |
| `MapController` | `YandexMapController` (from `onMapCreated`) |
| `LatLng(lat, lng)` | `Point(latitude:, longitude:)` |
| `FlutterMap(options: MapOptions(…))` | `YandexMap(…)` |
| `TileLayer(urlTemplate: dark/light)` | `YandexMap(nightModeEnabled: c.isDark)` ✅ *a whole tile-URL branch disappears* |
| `MarkerLayer(markers: [...])` | `YandexMap(mapObjects: [...])` |
| `Marker(point:, child: widget)` | `PlacemarkMapObject(mapId:, point:, icon:)` ⚠️ **see 4.2** |
| `onMapReady:` | `onMapCreated:` |
| `onTap: (_, __) => …` | `onMapTap: (Point p) => …` |
| `controller.move(center, zoom)` | `controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(target:, zoom:)))` |
| `controller.fitCamera(CameraFit.bounds(...))` | `controller.moveCamera(CameraUpdate.newBounds(BoundingBox(southWest:, northEast:)))` |
| `controller.camera.zoom` | `await controller.getCameraPosition()` ⚠️ **async now** |
| `minZoom/maxZoom` in `MapOptions` | `cameraBounds` / clamp manually in `_zoomBy` |

Two structural consequences:

1. **`_zoomBy` becomes async.** `_mapController.camera` was a synchronous
   getter; `getCameraPosition()` returns a `Future`. The clamp logic
   (`_minZoom`/`_maxZoom`) has to await it, or we switch to
   `CameraUpdate.zoomIn()` / `zoomOut()` and give up the clamp. Prefer awaiting
   — grey space past zoom 4 is exactly what the clamp was added to prevent.
2. **`_select()` also becomes async** for the same reason (it reads the current
   zoom to decide whether to zoom in to 15).

Everything else on the screen — `_fittedSig` re-fit guard, `_everLoaded` seed
logic, the plottable bbox filter, category chips, `_BranchCard`, `_MapButton` —
is map-library-agnostic and carries over unchanged.

### 4.2 The hard part: custom markers

This is the whole risk of the migration.

`flutter_map` `Marker` takes **an arbitrary Flutter widget**. `_BranchLabel` is
a real widget: rounded pill, `AppColors.chipGrey` / `brandPurple`, an SVG
building icon in a `link`-coloured square, `AppText.semibold12` label, ellipsis
overflow, drop shadow, selected state with a white ring.

Yandex `PlacemarkMapObject` takes **a bitmap** — `BitmapDescriptor.fromAssetImage`
or `fromBytes`. It cannot host a widget. So the Figma pill does not survive a
naive port.

**Option 4.2a — rasterize the widget to bytes (recommended)**

Render `_BranchLabel` off-screen to PNG bytes and feed
`BitmapDescriptor.fromBytes`.

- Use `ui.PictureRecorder` + a detached `RenderRepaintBoundary` pipeline (or a
  small offstage-overlay helper) to paint the widget at
  `MediaQuery.devicePixelRatio`.
- **Cache aggressively.** Key on `(title, isSelected, dpr, isDark)`. A search
  can plot 100+ branches; rasterizing on every rebuild would be visible jank.
  A `Map<String, Uint8List>` on the state object is enough.
- Anchor matters: current markers use `alignment: Alignment.centerLeft` with
  the pin implicitly at the left edge. `PlacemarkIconStyle` has an `anchor`
  (fractional offset) — set it to `Offset(0.06, 0.5)`-ish so the pill still
  hangs off the coordinate the same way. This needs eyeballing against Figma.
- SVG: `Assets.icons.home.building.svg` must be rendered into the same canvas —
  `flutter_svg` can do this, but it's async, so marker bytes must be built in an
  `initState`/`didUpdateWidget` async pass and held in state, not computed in
  `build()`.

Cost: one reusable `widget_to_bitmap.dart` helper (~80 lines) plus the cache.
Pays off — it's the only way to keep the design system on the map.

**Option 4.2b — Flutter widgets overlaid in a `Stack`**

Keep `_BranchLabel` as a real widget, position it with a `Positioned` computed
from `controller.getScreenPoint(Point)`, recomputed in `onCameraPositionChanged`.

- Pixel-identical to Figma, no rasterization, no cache.
- But: a `getScreenPoint` round-trip **per marker per camera frame** over the
  platform channel. With 100 branches this will not hold 60fps during a pan.
- Viable only if we cap it to the ~10 nearest markers, which changes behaviour.

**Verdict: 4.2a.** 4.2b is the fallback if rasterizing the SVG turns out to
fight us.

### 4.3 "My location" dot

`_MyLocationDot` has the same widget-vs-bitmap problem, but there's a better
answer: `controller.toggleUserLayer(visible: true)` gives MapKit's own native
location puck, with heading, for free. It won't match `_MyLocationDot` exactly.

Recommendation: use the native layer, drop `_MyLocationDot`. It's a standard
platform affordance, not a branded element. Flag for design sign-off.

`_goToMyLocation()` keeps its geolocator permission flow verbatim — that logic
is untouched by the map swap.

---

## Part 5 — Feature parity checklist

Verify each of these after the swap. This is the acceptance list.

**None of it has been checked yet** — the code compiles on both platforms, but
nothing has been run. Every box below is still open, and the two most likely to
fail are the marker size on iOS (§4.0 gotcha 2) and the anchor offset, since both
were derived by reading source rather than by looking at a screen.

- [ ] Branch pills render with correct title, icon, colours (light **and** dark)
- [ ] Selected pill: purple + white ring, drawn above overlapping neighbours
- [ ] Tapping a pill raises `_BranchCard`; tapping the map clears it
- [ ] Camera fits all branches on load, with the 56.w padding, max zoom 15
- [ ] Single branch → zoom 15, no branches → Tashkent centre @ 12
- [ ] Camera does **not** re-fit on spurious cubit emits (the `_fittedSig` guard)
- [ ] Category chip switch re-queries and re-fits
- [ ] Zoom ± clamps at 4 and 18
- [ ] "My location" asks permission, handles denied / services-off / error
- [ ] Dark mode: map goes dark with the theme
- [ ] `_everLoaded` seed behaviour — stale seed never flashes back
- [ ] Branch tap → `BranchDetailRoute` still pushes
- [ ] Clusters appear at zoom ≤ 15 and break apart above it
- [ ] Cluster bubble shows the right count, and 3-digit counts still fit
- [ ] Tapping a cluster opens it — including one whose centres share a coordinate
- [ ] Tapping an individual pill inside a collection still raises its card
- [ ] APK/IPA size delta measured and recorded
- [ ] Cold-start time not regressed (MapKit initialises in `Application.onCreate`)

---

## Part 6 — Risks and breaking changes

**6.1 minSdk 24 → 26.** Drops Android 7.x. Needs a Play Console check before
merge. Non-negotiable — it's the plugin's floor.

**6.2 iOS 14 → 15.** Drops iPhone 6s / 7 / SE 1st gen. Same check on App Store
Connect analytics.

**6.3 MapKit locale is fixed for the app's lifetime.** This is a genuine
regression and the one I'd most want your call on.

MapKit's `setLocale` runs once in `Application.onCreate` / `AppDelegate` and
**cannot be changed afterwards** — a native limitation, not a plugin one. Lumi
switches language at runtime via `easy_localization` (ru/uz/en). So: a user who
switches the app to Uzbek gets **Russian map labels** until they fully kill and
relaunch the app.

`flutter_phoenix` (already a dependency) does not help — it restarts the Flutter
layer, not the native process.

Options:
- Accept it, and read the persisted locale at native startup so the map is
  correct from the *second* launch after a language change.
- Show a "restart the app to update map language" hint on language switch.
- Ship as-is and see if anyone notices. Map labels in Tashkent are largely
  latin/cyrillic place names either way.

My recommendation: read the persisted locale natively (one-time cost, correct
99% of the time) and don't build the restart prompt unless someone complains.

**6.4 App size.** Measured, not estimated — from the debug APK built after §3:

| ABI | `libmaps-mobile.so` |
| --- | --- |
| arm64-v8a | **25.0 MB** |
| armeabi-v7a | 18.0 MB |
| x86_64 | 27.1 MB |

These are stored uncompressed in the APK (Android requires it for native libs),
so that is the raw on-disk cost of the `lite` variant. Play delivers a single ABI
per device via the App Bundle and compresses the download, so the user-visible
delta lands well under the arm64 figure — but it is still the largest single
dependency in the app. Measure the actual Play "download size" delta on the
first internal-track upload and put that number in the PR.

**6.5 CartoDB tiles go away.** No licence/attribution question anymore, but
Yandex has its own attribution requirement — the Yandex logo must stay visible.
`YandexMap` has `logoAlignment` / `logoPadding`; we can move it out from under
the category chips, but **we may not hide it.** Terms-of-use violation.

**6.6 Rollout.** `firebase_remote_config` is already wired up. Put the map
implementation behind a flag and keep `flutter_map` in the tree for one release,
so a bad key or a rendering bug in production is a remote toggle rather than a
hotfix build.

---

## Part 7 — Execution order

1. ~~Blocked on Part 1~~ — key issued.
2. ~~Native setup (§3), both platforms.~~ **Done** — see §3.0.
2b. **← we are here.** Drop the key into `android/key.properties`
   (`yandexMapkitKey=`) and `ios/Flutter/Secrets.xcconfig`
   (`YANDEX_MAPKIT_KEY =`), then verify a throwaway `YandexMap` with no markers
   renders tiles on both platforms. **Stop here if it doesn't** — every later
   step assumes a working key. (Remember the 15-minute activation window; a
   blank map right after issuing the key is expected, not a bug.)
3. ~~Marker rasteriser + cache (§4.2a).~~ **Done** — shipped as
   `map_marker_bitmap.dart`. Note it is a canvas painter, not the offscreen
   widget renderer the plan originally sketched: `RenderObjectToWidgetAdapter`
   no longer exists in Flutter 3.44 (replaced by `RootWidget`), and driving a
   detached `BuildOwner`/`PipelineOwner` by hand is far more fragile than
   painting a pill this simple directly.
4. ~~Port `branches_map_page.dart`.~~ **Done.**
5. ~~`toggleUserLayer` for the location puck (§4.3).~~ **Done.**
6. Walk Part 5 end to end on a physical Android device and a physical iPhone.
   Simulator/emulator GPU behaviour with MapKit is not representative.
7. Remote-config flag (§6.6), measure size, PR.
8. After one clean release: delete `flutter_map`, `latlong2`,
   `flutter_polyline_points` from `pubspec.yaml` and remove the flag.

Rough estimate, assuming Option A and no surprises in 4.2a: **1–1.5 days** of
implementation, plus device testing.

## Part 8 — Rollback

Until step 8, rollback is: flip the remote-config flag. `flutter_map` and its
code path stay in the tree and keep working. The only irreversible parts are the
minSdk/iOS-target bumps (§6.1, §6.2) — those ship regardless, so make the Play
Console / App Store Connect check *before* step 2, not after.

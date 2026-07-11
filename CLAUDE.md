# CLAUDE.md

Guidance for working in this Flutter app (`lumi_pass`).

## Data & server-driven types

- **Model server-driven string sets as `enum`s, never raw string literals or
  `Set<String>`.** A backend field with a fixed vocabulary (a `type`, `status`,
  `kind`, …) gets a Dart `enum` with a `key` for the wire value. Don't scatter
  magic strings like `'booking_approved'` or gate logic on
  `{...}.contains(json['type'])`.
- **Always include an `unknown` (or `other`) fallback and resolve via a
  `fromKey` that never throws.** The backend can add new values at any time;
  an unmodelled value must degrade gracefully (fall back to `unknown`), never
  crash. Example: `lib/data/api_model/notification_model/notification_type.dart`
  (`NotificationType.fromKey(String?)` → `unknown`).
- Keep the raw string on the model for (de)serialization and expose a typed
  getter (e.g. `NotificationModel.notificationType`). Put shared semantics on
  the enum (e.g. `isBooking`); keep UI mapping (icon/color) in the widget.
- **`switch` over the enum exhaustively** (handle every case incl. `unknown`,
  no `default`). Adding a new enum value then surfaces as a compile-time
  warning at every switch, instead of silently hitting a `default`.

## Styling conventions

### Colors

Colors live in **two layers**. Keep them separate — that separation is what
makes dark mode work.

1. **The palette — `AppColors`** (`lib/common/styles/app_colors.dart`).
   Nothing but `static const` hex literals, named after the *paint*
   (`brandPurple`, `error`, `lightBorder`, `darkSurface`). It is theme-unaware.
2. **The roles — `AppColorScheme`** (`lib/common/styles/app_color_scheme.dart`).
   A `ThemeExtension` naming what a color is *for* (`scaffoldBg`, `textPrimary`,
   `border`, `disabled`), with a `light` and a `dark` table assigning a palette
   entry to each role. Registered on `ThemeData.extensions` in `main.dart`.

- **Screens read roles, never paints: `context.colors.textPrimary`.** This is
  the single color accessor in the app. (`context.appColors` and the injectable
  `DefaultThemeColors` are gone — both folded into `context.colors`.)
- **A new color → add the hex to `AppColors`, then give it a role in
  `AppColorScheme` (both `light` *and* `dark`).** Never hardcode a hex literal
  in a widget, and never reference a `light*` / `dark*` palette entry from a
  screen — those exist only to be assigned inside the two tables.
- **The one exception: fixed inks.** `AppColors.ink`, `inkMuted`, `inkChip` and
  the brand/status statics (`brandPurple`, `error`, `green`, `warning`, `blue`)
  are theme-invariant *by design* — they paint chips that stay light in both
  themes because they sit on a photo. Use those directly.
- Adding a role means adding it to the constructor, both tables, `copyWith` and
  `lerp`. If you skip `lerp`, the color won't animate on theme switch.
- Gradients live in `AppGradients` (`lib/common/styles/app_gradients.dart`) —
  same rule: reuse tokens, don't inline `LinearGradient(...)` for a shared look.

### Shared widgets — don't re-declare a repeated look

When a visual pattern appears on multiple screens, extract/one shared widget
instead of copying the decoration inline. Existing shared building blocks:

- **`FrostedCard`** (`lib/common/widget/frosted_card.dart`) — the frosted
  light "gradient card": `AppGradients.frostedControl` + white border. Use it
  for notification cards, hero control chips (back/share/heart), the carousel
  dots pill (`hasBorder: false`), icon badges, and similar raised light
  surfaces. Do NOT re-declare this gradient + white border on a raw `Container`.
- **`Container3d`** (`lib/common/widget/container_3d.dart`) — bordered card with
  a subtle 3D press animation.

### Typography

- Text styles come from `AppText` (`lib/common/styles/app_text_styles.dart`),
  font family **SF Pro Rounded**. Use the named getters (`semibold14`,
  `regular13`, …) with `.copyWith(color: ...)` rather than raw `TextStyle`.

### Icons

- Icons are SVG assets under `assets/icons/` rendered with `flutter_svg`. New
  icons use `fill="currentColor"` and are tinted via
  `colorFilter: ColorFilter.mode(color, BlendMode.srcIn)`.
- Reference assets through the **generated getters**, never hardcoded path
  strings. After dropping a file in `assets/`, run `make gen` and use
  `Assets.icons.<name>.svg(...)` / `Assets.<...>.image(...)` from
  `lib/common/gen/assets.gen.dart`. Do NOT write
  `SvgPicture.asset('assets/icons/foo.svg')`.

## Code generation

This project relies on codegen (auto_route routes, flutter_gen assets,
freezed/json_serializable, injectable). The generated files live next to their
sources and in `lib/common/gen/`.

- **Regenerate with `make gen`** (runs
  `dart run build_runner build --delete-conflicting-outputs`). Run it after:
  adding/removing an asset, adding or changing a `@RoutePage` route, or editing
  any freezed/json/injectable-annotated class. Don't hand-edit generated files.
- **After regenerating, review `git diff` on generated files and commit only the
  changes that correspond to your work.** Codegen output can drift with tool
  versions (`pubspec.lock`); if a regen churns unrelated generated files (e.g.
  `app_router.gr.dart` starts referencing types without imports, or a route's
  constructor flips non-`const`), restore those files
  (`git checkout -- <file>`) rather than committing a broken generated file.
- **Gotcha — `strings.g.dart`:** `--delete-conflicting-outputs` deletes
  `lib/common/gen/strings.g.dart` because its `@SheetLocalization` generator is
  commented out (localization is driven by
  `assets/localization/translations.csv`, and `Strings` getters are maintained
  in that committed part file). `make gen` restores it automatically — never
  commit its deletion. Add new UI strings to `translations.csv` and, if a typed
  getter is needed, add it to `strings.g.dart` by hand.

RUNNING:
DO NOT RUN APP IN ORDER TO TEST/VIEW IT

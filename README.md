# LumiPass Mobile App

A Flutter mobile application for LumiPass - a platform for booking children's activity classes.

## Architecture

The project follows **Clean Architecture** with **BLoC/Cubit** state management pattern.

```
lib/
├── main.dart                              # App entry point
├── di/                                    # Dependency Injection (GetIt + Injectable)
│   ├── injection.dart                     # DI container setup
│   ├── injection.config.dart              # Generated DI config
│   ├── app_module.dart                    # App-level providers (Logger)
│   └── network_module.dart                # Network providers (Dio)
│
├── common/                                # Shared utilities & base classes
│   ├── base/
│   │   ├── base_cubit.dart                # Base Cubit with build/invoke pattern
│   │   ├── base_page.dart                 # Base StatefulWidget with BlocProvider
│   │   ├── base_state.dart                # Generic state (Buildable + Listenable)
│   │   ├── base_builder.dart              # BlocBuilder wrapper
│   │   ├── base_listener.dart             # BlocListener wrapper
│   │   └── base_storage.dart              # Typed Hive storage wrapper
│   ├── router/
│   │   ├── app_router.dart                # AutoRoute config
│   │   ├── app_router.gr.dart             # Generated routes
│   │   ├── empty_route.dart               # Initial empty route
│   │   └── initial_guard.dart             # Auth/onboarding guard
│   ├── constants/
│   │   └── constants.dart                 # Base URL, country phone masks
│   ├── extensions/
│   │   ├── sizedbox_extensions.dart       # .kh, .kw shortcuts
│   │   ├── text_extensions.dart           # .s(), .w(), .c(), .a() text styling
│   │   ├── theme_extensions.dart          # context.colors
│   │   ├── date_extensions.dart           # Date formatting
│   │   └── phone_extensions.dart          # Phone formatting
│   ├── gen/                               # Generated files (flutter_gen)
│   │   ├── assets.gen.dart                # Asset references
│   │   └── strings.dart                   # String constants
│   ├── utils/
│   │   └── input_validators.dart          # Form validators
│   └── widget/                            # Reusable widgets
│       ├── common_button.dart             # Elevated/outlined/text button
│       ├── common_text_filed.dart         # Text field with masking
│       ├── base_app_bar.dart              # Custom app bar
│       ├── bouncing_button.dart           # Animated tap button
│       └── display/                       # Toast/snackbar system
│           ├── display.dart               # Display interface
│           ├── display_impl.dart          # Dio error parsing
│           └── display_widget.dart        # SnackBar presenter
│
├── data/                                  # Data layer
│   ├── api_model/                         # API response models (Freezed)
│   │   ├── profile_model/                 # User profile
│   │   ├── home_model/                    # Home feed data
│   │   ├── child_model/                   # Children profiles
│   │   ├── schedule_model/                # Class schedules
│   │   ├── tariff_model/                  # Subscription tariffs
│   │   └── booking_model/                 # Booking data
│   ├── base_model/
│   │   ├── token/tokens.dart              # JWT tokens (Hive)
│   │   ├── default_theme_colors.dart      # Theme color definitions
│   │   └── material_colors.dart           # MaterialColor swatches
│   ├── storage/
│   │   └── storage.dart                   # Hive local storage
│   └── interceptor/
│       └── auth_interceptor.dart          # Bearer token interceptor
│
├── domain/                                # Domain layer
│   ├── repo/                              # Repository interfaces + API clients
│   │   ├── auth/
│   │   │   ├── auth_repository.dart       # Auth repository interface
│   │   │   └── auth_api.dart              # Auth API client (Dio)
│   │   ├── home/
│   │   │   ├── home_repository.dart       # Home repository interface
│   │   │   └── home_api.dart              # Home API client
│   │   └── booking/
│   │       ├── booking_repository.dart    # Booking repository interface
│   │       └── booking_api.dart           # Booking API client
│   └── impl/                              # Repository implementations
│       ├── auth_repository_impl.dart
│       ├── home_repository_impl.dart
│       └── booking_repository_impl.dart
│
└── presentation/                          # UI layer
    ├── app/
    │   ├── cubit/                         # App-level cubit
    │   ├── main/                          # Bottom navigation (5 tabs)
    │   │   ├── main_page.dart
    │   │   └── subscreens/
    │   │       ├── home/                  # Home feed
    │   │       ├── search/                # Category search
    │   │       ├── calendar/              # Class schedule
    │   │       ├── wallet/                # Tariffs & coins
    │   │       └── profile/               # User profile menu
    │   ├── home/
    │   │   ├── class_detail/              # Class detail & booking
    │   │   └── booking_complete/          # Booking confirmation
    │   ├── profile/
    │   │   ├── profile_detail/            # Edit profile
    │   │   ├── children/                  # Manage children
    │   │   └── payment/                   # Payment cards & checkout
    │   └── widgets/                       # Shared presentation widgets
    ├── auth/
    │   ├── login/                         # Phone number entry
    │   │   ├── login_page.dart
    │   │   └── bloc/
    │   │       ├── login_cubit.dart
    │   │       └── login_state.dart
    │   ├── register/                      # User registration
    │   │   ├── register_page.dart
    │   │   └── cubit/
    │   │       ├── register_cubit.dart
    │   │       └── register_state.dart
    │   └── verify/                        # OTP verification
    │       ├── verify_page.dart
    │       ├── cubit/
    │       │   ├── verify_cubit.dart
    │       │   └── verify_state.dart
    │       └── widget/
    │           └── common_pin_put.dart
    └── start/
        └── onboard/                       # Onboarding carousel
```

## Key Patterns

### State Management
- **BaseCubit<BUILDABLE, LISTENABLE>**: Custom Cubit with `build()` for UI state and `invoke()` for one-time effects
- **BasePage**: Auto-injects Cubit via GetIt, wraps with BlocProvider

### Navigation
- **AutoRoute** with `InitialGuard` for auth/onboarding routing
- Guard checks: onboarding shown -> tokens exist -> route accordingly

### API Layer
- **Dio** HTTP client with `AuthInterceptor` (Bearer token)
- Base URL: `https://dev-api.lumipass.uz/api/v1/`
- Repository pattern: Interface -> Implementation -> API Client

### Local Storage
- **Hive** with typed `BaseStorage<T>` wrapper
- Stores: tokens, user IDs, onboarding flag, device token

### Models
- **Freezed** for immutable data classes with `@JsonSerializable`

## Auth Flow

1. **Login**: Enter phone -> `POST /auth/check-number`
2. If user exists -> OTP verification (`POST /auth/verify-login`)
3. If new user -> Registration form -> `POST /auth/register` -> OTP (`POST /auth/verify`)
4. On OTP success -> JWT token stored -> Navigate to Main

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run code generation
dart run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### Local secrets

Two gitignored files hold keys the build reads. Copy the templates and fill
them in — a checkout without them still builds, but the map renders blank
(Android additionally needs `key.properties` to exist at all, for signing):

```bash
cp android/key.properties.example android/key.properties
cp ios/Flutter/Secrets.example.xcconfig ios/Flutter/Secrets.xcconfig
```

The Yandex MapKit key comes from the Yandex Developer Dashboard
(**API Interfaces → MapKit Mobile SDK**) and is bound to the app identifiers —
`uz.lumi.mobileapp` on Android, `uz.lumipass.mobile` on iOS.

For the map you don't have to fill anything in: a working key ships compiled
into `MainApplication.kt` / `AppDelegate.swift`, and released builds pick up
whatever `yandex_mapkit_key` holds in Firebase Remote Config from their next
cold start. Set `yandexMapkitKey` / `YANDEX_MAPKIT_KEY` only to build against a
different key than production's. See
[docs/YANDEX_MAP_MIGRATION.md](docs/YANDEX_MAP_MIGRATION.md) §3.3–3.4.

### Platform minimums

Yandex MapKit sets the floor: **Android API 26+** (`minSdk` is pinned in
`android/app/build.gradle.kts`, not inherited from Flutter) and **iOS 15+**.

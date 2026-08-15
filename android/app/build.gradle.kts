plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
keystoreProperties.load(FileInputStream(keystorePropertiesFile))

// Yandex MapKit key. Lives in the same gitignored key.properties as the signing
// config rather than in source — it is bound to the package name in the Yandex
// dashboard, but a plaintext key in git is still a finding. Empty is tolerated
// so a checkout without the file still configures; the map then renders blank.
val yandexMapkitKey: String = (keystoreProperties["yandexMapkitKey"] as String?) ?: ""

// Must match the variant in gradle.properties and the version the yandex_mapkit
// plugin resolves — see the dependencies block below.
val yandexMapkitVariant: String =
    (project.findProperty("yandexMapkit.variant") as String?) ?: "lite"
val yandexMapkitVersion = "4.39.1"

android {
    namespace = "uz.lumi.mobileapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildFeatures {
        // BuildConfig.YANDEX_MAPKIT_KEY, read by MainApplication.
        buildConfig = true
    }

    defaultConfig {
        applicationId = "uz.lumi.mobileapp"
        // Yandex MapKit requires API 26. Flutter's default (flutter.minSdkVersion)
        // is 24, so this is pinned rather than inherited — raising it drops
        // Android 7.x devices. See docs/YANDEX_MAP_MIGRATION.md §6.1.
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        buildConfigField("String", "YANDEX_MAPKIT_KEY", "\"$yandexMapkitKey\"")
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // The yandex_mapkit plugin declares MapKit as `implementation`, which puts
    // it on the runtime classpath but not on ours — so MainApplication cannot
    // resolve MapKitFactory at compile time without this line. Keep the version
    // pinned to whatever the plugin resolves (yandex_mapkit/android/build.gradle)
    // so Gradle isn't left arbitrating between two versions of the SDK.
    implementation("com.yandex.android:maps.mobile:$yandexMapkitVersion-$yandexMapkitVariant")
}

flutter {
    source = "../.."
}

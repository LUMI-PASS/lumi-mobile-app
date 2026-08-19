package uz.lumi.mobileapp

import android.app.Application
import android.content.Context
import android.util.Log
import com.yandex.mapkit.MapKitFactory

/**
 * Exists only so Yandex MapKit can be given its API key and locale before any
 * map is created — MapKit requires both to be set from `Application.onCreate`.
 *
 * Extends [Application] rather than `FlutterApplication`: the latter belongs to
 * the removed v1 embedding, and Flutter's own `${applicationName}` placeholder
 * resolves to `android.app.Application` on this version.
 */
class MainApplication : Application() {
    private companion object {
        const val TAG = "YandexMapKit"

        /** Stands in for a real key on a checkout without key.properties. */
        const val PLACEHOLDER_KEY = "00000000-0000-0000-0000-000000000000"
    }

    override fun onCreate() {
        super.onCreate()

        // Absent on a checkout without key.properties, which must not crash
        // the app — the map renders blank instead.
        val key = BuildConfig.YANDEX_MAPKIT_KEY
        if (key.isEmpty()) {
            Log.w(TAG, "no API key — set yandexMapkitKey in android/key.properties")
        }

        // Skipping setApiKey is NOT an option: yandex_mapkit's plugin
        // registration calls MapKitFactory.initialize(), which throws unless a
        // key was set first, killing the app before the first frame. A
        // syntactically valid placeholder keeps MapKit constructible — its tile
        // requests are then rejected and the map draws blank, which is the
        // intended keyless behaviour. Mirrors configureYandexMapKit() in
        // AppDelegate.swift.
        MapKitFactory.setApiKey(key.ifEmpty { PLACEHOLDER_KEY })
        MapKitFactory.setLocale(mapKitLocale())
    }

    /**
     * The map's language, read from the locale easy_localization persisted.
     *
     * MapKit's locale is fixed for the lifetime of the process and cannot be
     * changed once a map exists, so it cannot follow an in-app language switch:
     * the map catches up on the *next* cold start. Reading the saved value here
     * is what makes that "next launch" correct instead of permanently Russian.
     * See docs/YANDEX_MAP_MIGRATION.md §6.3.
     */
    private fun mapKitLocale(): String {
        val prefs = getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE,
        )
        // shared_preferences namespaces every Dart key with "flutter.".
        return when (prefs.getString("flutter.locale", null)) {
            "ru_RU" -> "ru_RU"
            "uz_UZ" -> "uz_UZ"
            // The app stores "en_EN", which is not a real region tag. MapKit
            // falls back on its own for anything it doesn't ship, but give it
            // something valid rather than relying on that.
            "en_EN", "en_US" -> "en_US"
            // First launch, before _seedDefaultLocale has written anything.
            else -> "uz_UZ"
        }
    }
}

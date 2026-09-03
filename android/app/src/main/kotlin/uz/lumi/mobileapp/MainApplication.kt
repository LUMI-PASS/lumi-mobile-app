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

        /**
         * The key compiled into the app, used until Remote Config has been read
         * at least once. Bound to the applicationId in the Yandex dashboard, so
         * it is a client identifier rather than a secret — it ships in the APK
         * whichever way it gets here.
         */
        const val DEFAULT_KEY = "17bb5f1b-73ed-4764-a574-6fb23e4079b3"

        /**
         * Where `RemoteConfigService` leaves the console's key on its way out of
         * a previous launch. shared_preferences namespaces every Dart key with
         * "flutter.".
         */
        const val REMOTE_KEY_PREF = "flutter.yandex_mapkit_key"

        const val PREFS_NAME = "FlutterSharedPreferences"
    }

    override fun onCreate() {
        super.onCreate()

        // Skipping setApiKey is NOT an option: yandex_mapkit's plugin
        // registration calls MapKitFactory.initialize(), which throws unless a
        // key was set first, killing the app before the first frame. There is
        // always a key to give it — worst case the one compiled in. Mirrors
        // configureYandexMapKit() in AppDelegate.swift.
        MapKitFactory.setApiKey(mapKitApiKey())
        MapKitFactory.setLocale(mapKitLocale())
    }

    /**
     * The key to hand MapKit, most-recently-authoritative first:
     *
     *  1. what Firebase Remote Config resolved on a previous launch, cached by
     *     `RemoteConfigService`;
     *  2. `yandexMapkitKey` from the gitignored key.properties, baked in as
     *     `BuildConfig.YANDEX_MAPKIT_KEY`;
     *  3. [DEFAULT_KEY].
     *
     * Remote Config outranks the build deliberately: rotating the key in the
     * console is the whole reason it is held there, and a build that already
     * carries a key would otherwise ignore it forever. Blanking the console
     * value clears the cache and hands the build-time key back its job.
     *
     * MapKit is keyed here, before Dart runs, so a console change can only
     * reach it on the *next* cold start — same one-launch lag as the locale
     * below. See docs/YANDEX_MAP_MIGRATION.md §6.3.
     */
    private fun mapKitApiKey(): String {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val remote = prefs.getString(REMOTE_KEY_PREF, null)?.trim().orEmpty()
        if (remote.isNotEmpty()) return remote

        val built = BuildConfig.YANDEX_MAPKIT_KEY.trim()
        if (built.isNotEmpty()) return built

        Log.i(TAG, "no key in key.properties and none cached from Remote Config — using the built-in key")
        return DEFAULT_KEY
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
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
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

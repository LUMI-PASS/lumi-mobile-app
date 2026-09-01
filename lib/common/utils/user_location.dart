import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Where the user is, for ordering the catalog "nearest first".
///
/// A plain lat/lng pair rather than a `LatLng`: this travels to the API layer,
/// which has no business importing a map package.
class UserLocation {
  const UserLocation(this.lat, this.lng, {required this.isPrecise});

  /// The device's real position.
  const UserLocation.precise(double lat, double lng)
      : this(lat, lng, isPrecise: true);

  final double lat;
  final double lng;

  /// False when this is the Tashkent fallback rather than the device's own
  /// position — the caller may want to say so, or to ask again later.
  final bool isPrecise;

  /// Great-circle distance in METRES from here to ([lat], [lng]), or null when
  /// that pair isn't a usable coordinate — see [isUsableCoords].
  ///
  /// Plain haversine, no roads and no ellipsoid. Over one city that is accurate
  /// to a few metres, and a card saying "1.2 km" is telling the user roughly
  /// how far away the centre is, not routing them there.
  double? metersTo(double? toLat, double? toLng) {
    if (!isUsableCoords(toLat, toLng)) return null;
    const earthRadiusMetres = 6371000.0;
    double rad(double deg) => deg * math.pi / 180.0;
    final dLat = rad(toLat! - lat);
    final dLng = rad(toLng! - lng);
    final h = math.pow(math.sin(dLat / 2), 2) +
        math.pow(math.sin(dLng / 2), 2) * math.cos(rad(lat)) * math.cos(rad(toLat));
    return 2 * earthRadiusMetres * math.asin(math.sqrt(h.toDouble()));
  }

  @override
  bool operator ==(Object other) =>
      other is UserLocation &&
      other.lat == lat &&
      other.lng == lng &&
      other.isPrecise == isPrecise;

  @override
  int get hashCode => Object.hash(lat, lng, isPrecise);

  @override
  String toString() =>
      'UserLocation($lat, $lng, ${isPrecise ? 'precise' : 'fallback'})';
}

/// Amir Temur square — the middle of Tashkent, and what the catalog is ordered
/// around when we don't know where the user actually is.
///
/// Every centre in the app is in Tashkent, so this is a far better answer than
/// no ordering at all: a user who refuses the permission still gets a list that
/// starts downtown instead of in whatever order Mongo returned.
const kTashkentCentre = UserLocation(41.3111, 69.2797, isPrecise: false);

/// Where the app currently believes the user is — published by whoever last
/// resolved it (today the home feed, on launch) and read by anything that has
/// to MEASURE from it, chiefly the distance line on activity cards.
///
/// Null until the first resolve finishes. It may also hold [kTashkentCentre],
/// which is fine for ordering a list but is not where the user is: anything
/// printing a number must check [UserLocation.isPrecise] first, or it will
/// quote a distance from a square downtown as if it were measured.
final ValueNotifier<UserLocation?> currentUserLocation =
    ValueNotifier<UserLocation?>(null);

/// Whether a lat/lng pair is real enough to measure against.
///
/// Mirrors the backend's `isCoords`: centres have shipped `location: null` and
/// half-set pairs, and 0,0 — the Gulf of Guinea — is what an unset pair looks
/// like once it has been coerced to a number. Measuring to any of those would
/// print a confident, wrong number on the card.
bool isUsableCoords(double? lat, double? lng) {
  if (lat == null || lng == null) return false;
  if (!lat.isFinite || !lng.isFinite) return false;
  if (lat.abs() > 90 || lng.abs() > 180) return false;
  if (lat == 0 && lng == 0) return false;
  return true;
}

/// Resolves the user's location for the home feed, asking for the permission
/// at most once ever.
///
/// The rules, in order:
///   - permission already granted  → the device's position;
///   - never asked before          → ask, then the position if granted;
///   - denied, or asked before     → [kTashkentCentre], silently.
///
/// Nothing here throws and nothing blocks forever: a GPS fix that doesn't
/// arrive inside [_fixTimeout] falls back like a refusal would. The home feed
/// must render whatever happens, so every failure has the same, quiet answer.
class UserLocationResolver {
  UserLocationResolver({
    required Future<bool> Function() hasAsked,
    required Future<void> Function() markAsked,
  })  : _hasAsked = hasAsked,
        _markAsked = markAsked;

  final Future<bool> Function() _hasAsked;
  final Future<void> Function() _markAsked;

  /// A cold GPS fix can take a while. The home feed is already on screen by
  /// then, so we'd rather re-sort a moment later than hold the request open.
  static const _fixTimeout = Duration(seconds: 8);

  /// Whether the permission is already granted, without ever prompting.
  ///
  /// Lets the home page fetch with the real position on later launches without
  /// the "ask once" bookkeeping getting involved.
  Future<bool> get isGranted async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// The last fix the OS still remembers, or null.
  ///
  /// Caught separately from the main flow: the web implementation doesn't
  /// support this at all, and that must fall through to a live position rather
  /// than being read as "no location".
  Future<UserLocation?> _lastKnown() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return UserLocation.precise(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }

  /// The device's position if we may have it, else [kTashkentCentre].
  ///
  /// Set [prompt] false to never show the OS dialog on this call — used for the
  /// very first paint, so the feed isn't waiting behind a permission sheet.
  Future<UserLocation> resolve({bool prompt = true}) async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied && prompt) {
        // Ask exactly once in the app's lifetime. Re-prompting on every launch
        // is what makes users deny permanently; if they change their mind they
        // can grant it in Settings and `checkPermission` picks it up here.
        if (await _hasAsked()) return kTashkentCentre;
        await _markAsked();
        permission = await Geolocator.requestPermission();
      }

      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return kTashkentCentre;
      }

      // Granted but the device's location services are switched off entirely —
      // getCurrentPosition would just throw.
      if (!await Geolocator.isLocationServiceEnabled()) return kTashkentCentre;

      // A position we already have beats one we wait for. This orders centres
      // by which is nearer, and for that a fix from a few minutes ago is
      // indistinguishable from a fresh one — while a cold GPS lock is seconds
      // the home feed would spend on a shimmer.
      final last = await _lastKnown();
      if (last != null) return last;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          // The list is ordered by which centre is nearer, not by metres. Block
          // accuracy is plenty and spares the user a long GPS lock.
          accuracy: LocationAccuracy.low,
          timeLimit: _fixTimeout,
        ),
      );
      return UserLocation.precise(position.latitude, position.longitude);
    } catch (_) {
      // Timeout, platform channel error, location services racing off — the
      // feed still has to render.
      return kTashkentCentre;
    }
  }
}

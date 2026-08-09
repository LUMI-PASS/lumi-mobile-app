import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The home feed's location rules. The point of every case here is the same:
/// the feed renders no matter what the user, the OS or the GPS chip does, and a
/// refusal is answered with the centre of Tashkent rather than nothing.
void main() {
  late _FakeGeolocator geo;
  late bool asked;

  UserLocationResolver resolver() => UserLocationResolver(
        hasAsked: () async => asked,
        markAsked: () async => asked = true,
      );

  setUp(() {
    geo = _FakeGeolocator();
    GeolocatorPlatform.instance = geo;
    asked = false;
  });

  group('permission already granted', () {
    setUp(() => geo.permission = LocationPermission.whileInUse);

    test('uses the device position and never prompts', () async {
      final where = await resolver().resolve();
      expect(where, const UserLocation.precise(41.35, 69.31));
      expect(geo.requestCount, 0);
      expect(asked, isFalse, reason: 'nothing to ask — already granted');
    });

    test('does so even on the no-prompt first paint', () async {
      final where = await resolver().resolve(prompt: false);
      expect(where.isPrecise, isTrue);
    });
  });

  group('permission not yet decided', () {
    setUp(() => geo.permission = LocationPermission.denied);

    test('asks once, and uses the position when granted', () async {
      geo.grantOnRequest = LocationPermission.whileInUse;
      final where = await resolver().resolve();
      expect(geo.requestCount, 1);
      expect(where.isPrecise, isTrue);
    });

    test('falls back to Tashkent when refused', () async {
      geo.grantOnRequest = LocationPermission.deniedForever;
      expect(await resolver().resolve(), kTashkentCentre);
    });

    // Re-prompting every launch is what drives people to deny permanently.
    test('never asks a second time, across resolver instances', () async {
      geo.grantOnRequest = LocationPermission.denied;
      await resolver().resolve();
      expect(geo.requestCount, 1);
      expect(asked, isTrue);

      await resolver().resolve();
      expect(geo.requestCount, 1, reason: 'the flag outlives the resolver');
    });

    test('does not prompt behind the first paint', () async {
      final where = await resolver().resolve(prompt: false);
      expect(geo.requestCount, 0);
      expect(where, kTashkentCentre);
    });
  });

  group('falls back to Tashkent centre when', () {
    test('the user denied permanently', () async {
      geo.permission = LocationPermission.deniedForever;
      expect(await resolver().resolve(), kTashkentCentre);
      expect(geo.requestCount, 0, reason: 'the OS would not show it anyway');
    });

    test('location services are switched off device-wide', () async {
      geo.permission = LocationPermission.whileInUse;
      geo.serviceEnabled = false;
      expect(await resolver().resolve(), kTashkentCentre);
    });

    test('the GPS fix never arrives', () async {
      geo.permission = LocationPermission.whileInUse;
      geo.positionError = TimeoutException('no fix', const Duration(seconds: 8));
      expect(await resolver().resolve(), kTashkentCentre);
    });

    test('the platform channel blows up entirely', () async {
      geo.permission = LocationPermission.whileInUse;
      geo.positionError = Exception('no platform implementation');
      expect(await resolver().resolve(), kTashkentCentre);
    });
  });

  // A cold GPS lock is seconds the home feed would spend on a shimmer, and for
  // "which centre is nearer" a slightly old fix is just as good.
  group('remembered position', () {
    setUp(() => geo.permission = LocationPermission.whileInUse);

    test('is used instead of waiting for a fresh fix', () async {
      geo.lastKnown = (41.29, 69.24);
      expect(await resolver().resolve(), const UserLocation.precise(41.29, 69.24));
      expect(geo.currentPositionCalls, 0);
    });

    test('falls through to a live fix when the OS has none', () async {
      geo.lastKnown = null;
      expect(await resolver().resolve(), const UserLocation.precise(41.35, 69.31));
      expect(geo.currentPositionCalls, 1);
    });

    // Web has no such API. Throwing here must not read as "no location".
    test('falls through to a live fix when the platform refuses it', () async {
      geo.lastKnownError = UnsupportedError('not available on web');
      final where = await resolver().resolve();
      expect(where, const UserLocation.precise(41.35, 69.31));
      expect(geo.currentPositionCalls, 1);
    });
  });

  test('the fallback is flagged as imprecise, so callers can ask again', () {
    expect(kTashkentCentre.isPrecise, isFalse);
    expect(const UserLocation.precise(1, 2).isPrecise, isTrue);
  });

  test('isGranted reports permission without ever prompting', () async {
    geo.permission = LocationPermission.denied;
    expect(await resolver().isGranted, isFalse);
    geo.permission = LocationPermission.always;
    expect(await resolver().isGranted, isTrue);
    expect(geo.requestCount, 0);
  });
}

class _FakeGeolocator extends GeolocatorPlatform with MockPlatformInterfaceMixin {
  LocationPermission permission = LocationPermission.denied;
  LocationPermission grantOnRequest = LocationPermission.denied;
  bool serviceEnabled = true;
  Object? positionError;
  int requestCount = 0;

  /// A remembered fix, as (lat, lng). Null means the OS has none.
  (double, double)? lastKnown;
  Object? lastKnownError;
  int currentPositionCalls = 0;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async {
    requestCount++;
    return permission = grantOnRequest;
  }

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<Position?> getLastKnownPosition({bool forceLocationManager = false}) async {
    if (lastKnownError != null) throw lastKnownError!;
    if (lastKnown == null) return null;
    return _at(lastKnown!.$1, lastKnown!.$2);
  }

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    currentPositionCalls++;
    if (positionError != null) throw positionError!;
    return _at(41.35, 69.31);
  }

  Position _at(double latitude, double longitude) {
    return Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.fromMillisecondsSinceEpoch(0),
      accuracy: 50,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }
}

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
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    if (positionError != null) throw positionError!;
    return Position(
      latitude: 41.35,
      longitude: 69.31,
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

import 'dart:developer';

import 'package:geolocator/geolocator.dart';

export 'package:geolocator/geolocator.dart';

//TODO change all to return latlng;

class Location {
  const Location({
    this.locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    ),
  });

  ///
  final LocationSettings locationSettings;

  /// Returns [LocationPermission]
  Future<LocationPermission> checkPermissionStatus() => Geolocator.checkPermission();

  /// Returns [true] if persmission was granted
  ///
  /// otherwise [false]
  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return true;
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        return false;
    }
  }

  /// Asks for location permission
  ///
  /// returns [true] if persmission was granted
  /// otherwise [false]
  Future<bool> requestPermission() async {
    try {
      LocationPermission permission;

      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      }

      return true;
    } catch (e) {
      return Future.error('Something happened: $e');
    }
  }

  /// Returns [true] if location is enabled
  ///
  /// otherwise [false]
  Future<bool> isLocationServiceEnabled() async {
    // Test if location services are enabled.
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }
    return serviceEnabled;
  }

  Future<bool> checkLocationServiceAndPermission() async {
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    final permissionGranted = await isPermissionGranted();
    return permissionGranted;
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position?> getCurrentLocation() async {
    final enabled = await isLocationServiceEnabled();
    if (!enabled) return null;

    final permissionGranted = await isPermissionGranted();
    if (!permissionGranted) return null;

    return Geolocator.getCurrentPosition(locationSettings: locationSettings);
  }

  /// Returns the last known location
  Future<Position?> getLastKnownLocation() async {
    try {
      return Geolocator.getLastKnownPosition();
    } catch (e) {
      log('$e');
      return null;
    }
  }

  /// Stream of current position changes
  Stream<Position> getLocationStream() => Geolocator.getPositionStream(
        locationSettings: locationSettings,
      );

  Stream<ServiceStatus> getLocationServiceStatusStream() => Geolocator.getServiceStatusStream();

  Future<bool> openAppSettings() => Geolocator.openAppSettings();
  Future<bool> openLocationSettings() => Geolocator.openLocationSettings();

  double distanceBetween(double startLatitude, double startLongitude, double endLatitude, double endLongitude) =>
      Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
}

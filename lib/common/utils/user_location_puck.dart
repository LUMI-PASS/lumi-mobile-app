import 'dart:ui';

import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/utils/map_marker_bitmap.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// `YandexMap.onUserLocationAdded` for every map in the app: draws the user's
/// position as [BranchMarkerPainter.buildUserPuck] above the pins, with a
/// faint accuracy circle.
///
/// Without it the plugin's pin and arrow have no icon, so the position is
/// invisible until the accuracy circle grows big enough to see — see
/// [BranchMarkerPainter.buildUserPuck].
Future<UserLocationView> styleUserLocation(
  UserLocationView view, {
  required double devicePixelRatio,
}) async {
  final bitmap = await BranchMarkerPainter.buildUserPuck(
    devicePixelRatio: devicePixelRatio,
  );
  final icon = PlacemarkIcon.single(
    PlacemarkIconStyle(
      image: BitmapDescriptor.fromBytes(bitmap.bytes),
      anchor: bitmap.anchor,
      scale: bitmap.scale,
    ),
  );
  // Above the branch pills (zIndex 0–1), so a centre next door never hides
  // where the user stands.
  return view.copyWith(
    pin: view.pin.copyWith(icon: icon, opacity: 1, zIndex: 10),
    arrow: view.arrow.copyWith(icon: icon, opacity: 1, zIndex: 10),
    accuracyCircle: view.accuracyCircle.copyWith(
      fillColor: AppColors.brandPurple.withValues(alpha: 0.10),
      strokeColor: const Color(0x00000000),
      strokeWidth: 0,
      zIndex: 9,
    ),
  );
}

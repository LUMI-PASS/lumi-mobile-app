import 'package:flutter/widgets.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

/// Moves the camera, retrying each frame until MapKit accepts the move.
///
/// MapKit silently drops any camera move made while its map window has no
/// size yet — `moveCamera` just answers false — and `onMapCreated` can fire
/// before the view is laid out. A screen that placed its opening camera
/// there and ignored the answer opened on MapKit's default view: the whole
/// world. This waits a frame and tries again, giving up after [maxFrames]
/// (about a second) or once [isActive] says the screen is gone.
///
/// For moves without an animation only: an animated move also answers false
/// when it is interrupted, which is not a reason to replay it.
Future<bool> moveCameraWhenSized(
  YandexMapController controller,
  CameraUpdate update, {
  required bool Function() isActive,
  int maxFrames = 60,
}) async {
  for (var i = 0; i < maxFrames && isActive(); i++) {
    if (await controller.moveCamera(update)) return true;
    await WidgetsBinding.instance.endOfFrame;
  }
  return false;
}

import 'dart:async';
import 'dart:math' show Random;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:lumi_pass/common/router/deep_link_log.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Where a banner was rendered. Must match the backend's `BANNER_PLACEMENTS`,
/// which is a closed list because the value is displayed on a console screen.
class BannerPlacement {
  const BannerPlacement._();

  static const homeCarousel = 'home_carousel';
  static const homeAd = 'home_ad';
}

/// Reports banner taps to `POST /api/banners/:id/click`.
///
/// Fire-and-forget by design: [report] returns immediately and swallows every
/// error. A tap's real job is to open the banner's link, and tracking must
/// never delay that, fail it, or — if the network is down — stop it happening.
@lazySingleton
class BannerClickReporter {
  BannerClickReporter(this._dio, this._storage);

  final Dio _dio;
  final Storage _storage;

  String? _appVersion;

  /// Records a tap. Never awaited by callers; never throws.
  void report(String? bannerId, {required String placement}) {
    final id = (bannerId ?? '').trim();
    if (id.isEmpty) return;

    unawaited(_send(id, placement));
  }

  Future<void> _send(String id, String placement) async {
    try {
      final platform = _platform();
      final version = await _version();
      final locale = _locale();

      await _dio.post(
        'banners/$id/click',
        data: {
          'device_id': _installId(),
          'placement': placement,
          if (platform != null) 'platform': platform,
          if (version != null) 'app_version': version,
          if (locale != null) 'locale': locale,
        },
      );
      dlog('click: recorded for banner $id');
    } catch (e) {
      // Includes the throttle's 429. A dropped click is a rounding error in a
      // report; a crashed tap is a broken app.
      dlog('click: NOT recorded for banner $id: $e');
    }
  }

  /// The install id, generated on first use and persisted. See [Storage.installId].
  String _installId() {
    final existing = _storage.installId.call();
    if (existing != null && existing.isNotEmpty) return existing;

    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    _storage.installId.set(id);
    return id;
  }

  String? _platform() {
    if (kIsWeb) return 'web';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      default:
        return null;
    }
  }

  /// Cached after the first lookup — `PackageInfo.fromPlatform` is a platform
  /// channel call and this runs on a tap.
  Future<String?> _version() async {
    if (_appVersion != null) return _appVersion;
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
    } catch (_) {
      _appVersion = null;
    }
    return _appVersion;
  }

  /// The locale the user is actually reading the app in — their stored
  /// override, not the phone's, since the two routinely disagree here.
  String? _locale() {
    final code = (_storage.localeCode.call() ?? '').trim();
    return const {'uz', 'ru', 'en'}.contains(code) ? code : null;
  }
}

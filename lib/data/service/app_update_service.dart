import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/update/force_update_page.dart';
import 'package:lumi_pass/presentation/app/update/optional_update_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

/// What the installed build owes the user, decided by the two version floors
/// in Remote Config (`min_supported_version`, `latest_app_version`).
enum AppUpdateKind {
  /// Up to date — or the gate is switched off in the console.
  none,

  /// Newer build exists; the user may keep going. Dismissible sheet.
  optional,

  /// Below the supported floor. Blocking screen, no way past it.
  force,
}

/// Decides — and shows — the update gate.
///
/// Everything it needs comes from Remote Config, so both the thresholds and
/// the store links move without an app release. Ported from the same gate in
/// the Wisdom app, with the store link split per platform and the "Later"
/// choice remembered per version instead of per session.
class AppUpdateService {
  AppUpdateService._();

  static final AppUpdateService instance = AppUpdateService._();

  final _config = RemoteConfigService.instance;

  /// Guards against a second gate stacking on top of the first — the check can
  /// run again on a later launch path (deep link, push cold start).
  bool _shown = false;

  /// Frames spent waiting for the root navigator to exist. Bounded, so a build
  /// that somehow never mounts one does not spin a callback every frame.
  int _waitedFrames = 0;
  static const _maxWaitedFrames = 10;

  /// Debug-only escape hatch for checking the two views on a device:
  ///
  ///   flutter run --dart-define=UPDATE_GATE=force
  ///   flutter run --dart-define=UPDATE_GATE=optional
  ///
  /// It exists because dev and prod share one Firebase project — setting a
  /// real floor in the console to "try it out" would gate every live user on
  /// the spot. Compile-time and [kDebugMode]-guarded, so a release build
  /// cannot be talked into it.
  static const _gateOverride = String.fromEnvironment('UPDATE_GATE');

  static bool get _overridden => kDebugMode && _gateOverride.isNotEmpty;

  /// What the current build is owed. Anything unparseable — a blank console
  /// value, a malformed version, a Remote Config fetch that never landed —
  /// resolves to [AppUpdateKind.none]: a config accident must never lock users
  /// out of the app.
  AppUpdateKind get status {
    if (_overridden) {
      return _gateOverride == 'force'
          ? AppUpdateKind.force
          : AppUpdateKind.optional;
    }

    // No store to send anyone to on web, and the review build is deliberately
    // pinned to an older version — neither should ever see the gate.
    if (kIsWeb || _config.isInReview) return AppUpdateKind.none;

    final installed = _parse(_config.currentVersion);
    if (installed == null) return AppUpdateKind.none;

    final minimum = _parse(_config.minSupportedVersion);
    if (minimum != null && _compare(installed, minimum) < 0) {
      return AppUpdateKind.force;
    }

    final latest = _parse(_config.latestAppVersion);
    if (latest != null && _compare(installed, latest) < 0) {
      return AppUpdateKind.optional;
    }

    return AppUpdateKind.none;
  }

  /// Shows the gate the current build is owed, at most once per app run.
  ///
  /// [context] is optional: called from app start-up there is no screen to
  /// hang a dialog off yet, so the root navigator's context is used instead.
  Future<void> maybeShow([BuildContext? context]) async {
    if (_shown) return;

    final kind = status;
    if (kind == AppUpdateKind.none) return;

    final ctx = context ?? getIt<AppRouter>().navigatorKey.currentContext;
    if (ctx == null || !ctx.mounted) {
      // Called from app start-up the router may not have mounted its navigator
      // in this frame yet. Try again next frame rather than dropping the gate.
      if (context == null && _waitedFrames < _maxWaitedFrames) {
        _waitedFrames++;
        WidgetsBinding.instance.addPostFrameCallback((_) => maybeShow());
      }
      return;
    }

    if (kind == AppUpdateKind.force) {
      _shown = true;
      await ForceUpdatePage.show(ctx);
      return;
    }

    // Optional: honour a "Later" the user already gave for this same version.
    // Skipped under the debug override, which must show the sheet every run.
    final storage = getIt<Storage>();
    final latest = _config.latestAppVersion;
    if (!_overridden && storage.updateSkippedVersion.call() == latest) return;

    _shown = true;
    final updating = await OptionalUpdateSheet.show(ctx);
    if (!_overridden && updating != true) {
      await storage.updateSkippedVersion.set(latest);
    }
  }

  /// Sends the user to this platform's store listing.
  Future<void> openStore() async {
    final uri = Uri.tryParse(_config.storeLink);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('AppUpdateService: could not open $uri — $e');
    }
  }

  // ─── Version arithmetic ────────────────────────────────────────────────────

  /// "2.1.0", "2.1", "2.1.0+34", "2.1.0-beta.1" → [2, 1, 0]. Null when there
  /// is no leading number at all, which is how a blank or junk console value
  /// takes itself out of the comparison.
  static List<int>? _parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // Drop the build number and any pre-release tag; only the release triple
    // decides the gate.
    final core = trimmed.split(RegExp(r'[+\-\s]')).first;
    final parts = core.split('.');
    final numbers = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null) break;
      numbers.add(value);
    }
    return numbers.isEmpty ? null : numbers;
  }

  /// Segment-by-segment, shorter side padded with zeroes so "2.1" == "2.1.0".
  static int _compare(List<int> a, List<int> b) {
    final length = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < length; i++) {
      final left = i < a.length ? a[i] : 0;
      final right = i < b.length ? b[i] : 0;
      if (left != right) return left < right ? -1 : 1;
    }
    return 0;
  }
}

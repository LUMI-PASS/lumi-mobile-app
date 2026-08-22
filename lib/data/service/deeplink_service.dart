import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:flutter/widgets.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/service/interest_source.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

// Matches https://mobile-api.lumipass.uz/share/class/<id>
const _kShareClassPath = '/share/class/';

class DeeplinkService {
  DeeplinkService(this._appRouter);

  final AppRouter _appRouter;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    // Warm links (app already running in background)
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        log('[Deeplink] warm link: $uri');
        _handleUri(uri, cold: false);
      },
      onError: (e) => log('[Deeplink] stream error: $e'),
    );

    // Cold start link (app launched via link)
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        log('[Deeplink] cold start: $initial');
        // Wait for the widget tree and router stack to be ready.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 800), () {
            _handleUri(initial, cold: true);
          });
        });
      }
    } catch (e) {
      log('[Deeplink] getInitialLink error: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
  }

  /// Entry point for links AppsFlyer resolved for us — a OneLink click, or the
  /// deferred deep link replayed on the first launch after an install.
  ///
  /// AppsFlyer owns those URLs (they never reach `app_links`), so this is the
  /// only way they get routed. [deferred] is treated as a cold start: the app
  /// is coming up from scratch, so the router stack may not exist yet, which
  /// is exactly the case [_navigateToClass] retries around.
  void handleAppsFlyerLink(Uri uri, {required bool deferred}) {
    log('[Deeplink] appsflyer link: $uri (deferred=$deferred)');
    _handleUri(uri, cold: deferred);
  }

  void _handleUri(Uri uri, {required bool cold}) {
    String? classId;

    if (uri.scheme == 'lumi' && uri.host == 'class') {
      // Custom scheme: lumi://class/<id>
      classId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    } else {
      // Universal/App Link: https://mobile-api.lumipass.uz/share/class/<id>
      final path = uri.path;
      final idx = path.indexOf(_kShareClassPath);
      if (idx != -1) {
        classId = path.substring(idx + _kShareClassPath.length);
      }
    }

    if (classId == null || classId.isEmpty) return;
    log('[Deeplink] class id: $classId (cold=$cold)');
    _navigateToClass(classId);
  }

  Future<void> _navigateToClass(String classId, {int retryCount = 0}) async {
    if (_appRouter.stack.isEmpty) {
      if (retryCount < 5) {
        await Future.delayed(const Duration(milliseconds: 600));
        return _navigateToClass(classId, retryCount: retryCount + 1);
      }
      log('[Deeplink] router stack never became ready, giving up');
      return;
    }
    try {
      // Navigate with a minimal HomClass — the ClassDetailPage calls
      // _loadFull() in initState so full data loads immediately on screen.
      final minimal = HomClass(id: classId);
      // That `_loadFull()` is the request the backend records the interest
      // from, and no route can say where this one came from — the user was
      // not in the app at all. Pin it before the push, while the observer is
      // still one frame away from overwriting it.
      InterestSourceTracker.instance.pin(InterestSource.deeplink);
      await _appRouter.push(ClassDetailRoute(classModel: minimal));
    } catch (e) {
      log('[Deeplink] navigation error: $e');
    }
  }
}

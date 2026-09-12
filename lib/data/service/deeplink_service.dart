import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/router/deep_link_routes.dart';
import 'package:lumi_pass/data/service/interest_source.dart';

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
  /// is exactly the case [_navigate] retries around.
  void handleAppsFlyerLink(Uri uri, {required bool deferred}) {
    log('[Deeplink] appsflyer link: $uri (deferred=$deferred)');
    _handleUri(uri, cold: deferred);
  }

  /// Entry point for a link opened from INSIDE the app — a banner tap, a push
  /// payload. Goes through [AppLinkOpener], never called directly.
  ///
  /// The app is on screen by definition here, so there is no cold-start wait;
  /// [source] says which surface the tap came from so the interest the target
  /// screen records is attributed to it rather than to `deeplink`.
  Future<void> openFromApp(Uri uri, {String? source}) =>
      _handleUri(uri, cold: false, source: source);

  Future<void> _handleUri(
    Uri uri, {
    required bool cold,
    String? source,
  }) async {
    // A localhost URL is a debugging artefact — never a real destination in a
    // release build.
    if (!kDebugMode && uri.host.contains('localhost')) return;

    final target = DeepLinkRoutes.resolve(uri);
    if (target == null) return;

    final entry = DeepLinkRoutes.lookup(target.key);
    if (entry == null) return;

    log('[Deeplink] -> $target (cold=$cold)');
    await _navigate(entry, target, source: source);
  }

  /// Dispatches a resolved entry by its [DeepLinkNavMode].
  ///
  /// Retries while the router stack is still empty: on a cold start this runs
  /// before the first route is mounted, and a push onto an empty stack is
  /// silently lost.
  Future<void> _navigate(
    DeepLinkRoute entry,
    DeepLinkTarget target, {
    String? source,
    int retryCount = 0,
  }) async {
    if (_appRouter.stack.isEmpty) {
      if (retryCount < 5) {
        await Future.delayed(const Duration(milliseconds: 600));
        return _navigate(
          entry,
          target,
          source: source,
          retryCount: retryCount + 1,
        );
      }
      log('[Deeplink] router stack never became ready, giving up');
      return;
    }

    try {
      switch (entry.mode) {
        case DeepLinkNavMode.tab:
          final tabsRouter =
              _appRouter.innerRouterOf<TabsRouter>(MainRoute.name);
          // Not past the splash or the login wall yet — there is no tab bar to
          // switch. Dropping it beats pushing a tab's page onto the root stack
          // with no bottom nav under it.
          if (tabsRouter == null) {
            log('[Deeplink] tabs router unavailable, ignoring tab switch');
            return;
          }
          tabsRouter.setActiveIndex(entry.tabIndex!);

        case DeepLinkNavMode.root:
          final route = await entry.build!(target.params);
          if (route == null) return;
          // The screen's own `initState` fetch is what the backend records the
          // interest from, and no route can say where it came from — the user
          // was not on a screen at all. Pin it immediately before the push,
          // while the route observer is still one frame away from overwriting
          // it. A tap from inside the app names its own surface (`banner`);
          // anything arriving from outside is a deep link.
          InterestSourceTracker.instance.pin(source ?? InterestSource.deeplink);
          await _appRouter.push(route);
      }
    } catch (e) {
      log('[Deeplink] navigation error: $e');
    }
  }
}

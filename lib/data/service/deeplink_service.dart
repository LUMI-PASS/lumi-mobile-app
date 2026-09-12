import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/router/deep_link_log.dart';
import 'package:lumi_pass/common/router/deep_link_routes.dart';
import 'package:lumi_pass/data/service/interest_source.dart';

class DeeplinkService {
  DeeplinkService(this._appRouter);

  final AppRouter _appRouter;
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// The last link routed and when, so the SAME link arriving twice is only
  /// acted on once.
  ///
  /// One user action reaches us through more than one channel: the AppsFlyer
  /// SDK claims the `lumi` scheme and reports the link through its UDL
  /// callback, while `app_links` delivers the identical URI straight from the
  /// OS. Both used to route it, pushing the destination onto the navigator
  /// twice — which auto_route keys identically, producing a storm of
  /// "Duplicate GlobalKey detected" and a screen built twice (two identical
  /// API calls, two of everything).
  ///
  /// Deduping on the URI rather than on a channel flag is deliberate: which of
  /// the two arrives first is a race, so there is no "primary" channel to
  /// trust, and a new channel added later is covered for free.
  String? _lastLink;
  DateTime? _lastLinkAt;

  /// A link that arrived before the app had a home screen to come back to.
  ///
  /// Replayed by [markAppReady]. Deep links routinely arrive during a COLD
  /// start, while `InitialGuard` is still deciding between onboarding, login
  /// and the main tabs — and a user who is not logged in may sit on the login
  /// screen for minutes. Holding the link beats dropping it.
  ({DeepLinkRoute entry, DeepLinkTarget target, String? source})? _pending;

  /// What the last deep link we pushed was aiming at (`key:id`).
  ///
  /// Paired with the router's own top-route name to answer "is the screen on
  /// top already the one this link wants?". The router knows the route NAME
  /// but not which class or venue it is showing — that lives in constructor
  /// args it does not expose comparably — so the id is remembered here.
  String? _topSignature;

  /// How long after routing a link an identical one is treated as the same
  /// event. Comfortably longer than the gap between the two deliveries, short
  /// enough that a user deliberately re-opening the same link still works.
  static const _duplicateWindow = Duration(seconds: 3);

  Future<void> init() async {
    // Warm links (app already running in background)
    dlog('service: listening for links');
    _sub = _appLinks.uriLinkStream.listen(
      (uri) {
        dlog('=== WARM LINK: $uri');
        _handleUri(uri, cold: false);
      },
      onError: (e) => dlog('stream error: $e'),
    );

    // Cold start link (app launched via link)
    try {
      final initial = await _appLinks.getInitialLink();
      dlog('service: initial link = ${initial ?? "none"}');
      if (initial != null) {
        // Wait for the widget tree and router stack to be ready.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 800), () {
            dlog('=== COLD LINK: $initial');
            _handleUri(initial, cold: true);
          });
        });
      }
    } catch (e) {
      dlog('getInitialLink error: $e');
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
    dlog('=== APPSFLYER LINK: $uri (deferred=$deferred)');
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
    if (!kDebugMode && uri.host.contains('localhost')) {
      dlog('handle: dropped localhost URL in a release build');
      return;
    }

    // The same link delivered by a second channel — see [_lastLink].
    final link = uri.toString();
    final now = DateTime.now();
    final previous = _lastLinkAt;
    if (_lastLink == link &&
        previous != null &&
        now.difference(previous) < _duplicateWindow) {
      dlog('handle: DROPPED duplicate "$link" '
          '(${now.difference(previous).inMilliseconds}ms after the first)');
      return;
    }
    _lastLink = link;
    _lastLinkAt = now;

    final target = DeepLinkRoutes.resolve(uri);
    if (target == null) {
      dlog('handle: STOP — nothing in this build handles that link');
      return;
    }

    final entry = DeepLinkRoutes.lookup(target.key);
    if (entry == null) {
      dlog('handle: STOP — "${target.key}" resolved but has no registry entry');
      return;
    }

    dlog('handle: ${target.key} mode=${entry.mode.name} '
        'cold=$cold source=${source ?? "deeplink"}');
    await _navigate(entry, target, source: source);
  }

  /// Dispatches a resolved entry by its [DeepLinkNavMode].
  ///
  /// Retries while the router stack is still empty: on a cold start this runs
  /// before the first route is mounted, and a push onto an empty stack is
  /// silently lost.
  /// Whether the app has a home screen for a deep link to land on top of.
  ///
  /// `stack.isEmpty` is NOT this test, and using it was the bug: the stack
  /// stops being empty as soon as the `/` route mounts, which is BEFORE
  /// `InitialGuard` has redirected to the main tabs. The guard REPLACES that
  /// entry, so a route pushed during the gap ends up sitting on nothing — and
  /// popping it revealed a black screen instead of the home page.
  ///
  /// `MainRoute`'s tabs router existing is the honest signal: the user is past
  /// onboarding, past login, and looking at the app.
  bool get _isReady =>
      _appRouter.innerRouterOf<TabsRouter>(MainRoute.name) != null;

  /// Replays a link that arrived before the app was ready. Called by
  /// [MainPage] once the tabs are mounted.
  void markAppReady() {
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    dlog('service: app ready, replaying held link ${pending.target}');
    unawaited(
      _navigate(pending.entry, pending.target, source: pending.source),
    );
  }

  Future<void> _navigate(
    DeepLinkRoute entry,
    DeepLinkTarget target, {
    String? source,
    int retryCount = 0,
  }) async {
    if (!_isReady) {
      // A short retry covers the ordinary cold start, where the guard resolves
      // in well under a second.
      if (retryCount < 10) {
        dlog('nav: app not ready yet, retry ${retryCount + 1}/10');
        await Future.delayed(const Duration(milliseconds: 400));
        return _navigate(
          entry,
          target,
          source: source,
          retryCount: retryCount + 1,
        );
      }
      // Past that it is not a race but a state: the user is on the login or
      // onboarding screen. Hold the link rather than dropping it — they are
      // very likely logging in BECAUSE they followed it.
      dlog('nav: HELD — app not ready, will replay after login/onboarding');
      _pending = (entry: entry, target: target, source: source);
      return;
    }

    try {
      switch (entry.mode) {
        case DeepLinkNavMode.tab:
          final tabsRouter =
              _appRouter.innerRouterOf<TabsRouter>(MainRoute.name);
          if (tabsRouter == null) {
            dlog('nav: FAILED — no tabs router yet');
            return;
          }
          dlog('nav: switching to tab ${entry.tabIndex}');
          tabsRouter.setActiveIndex(entry.tabIndex!);
          dlog('nav: DONE');

        case DeepLinkNavMode.root:
          final route = await entry.build!(target.params);
          if (route == null) {
            dlog('nav: FAILED — builder returned no route');
            return;
          }

          // Already looking at exactly this screen — don't stack a second copy
          // of it.
          //
          // The time-window guard upstream catches the same link arriving from
          // two channels at once, but not a link genuinely opened again while
          // its destination is still on top (AppsFlyer re-fires its UDL
          // callback on resume, and a user can simply tap the same link twice).
          // Pushing then puts two identical entries on the stack, which
          // auto_route keys identically — that is what produces the
          // "Duplicate GlobalKey" storm and builds the screen twice.
          //
          // The target signature includes the id, so `lumi://class/a` while
          // class B is open still pushes.
          final signature = '${target.key}:${target.params['id'] ?? ''}';
          if (_appRouter.topRoute.name == route.routeName &&
              _topSignature == signature) {
            dlog('nav: SKIPPED — ${route.routeName} ($signature) is already on top');
            return;
          }

          // The screen's own `initState` fetch is what the backend records the
          // interest from, and no route can say where it came from — the user
          // was not on a screen at all. Pin it immediately before the push,
          // while the route observer is still one frame away from overwriting
          // it. A tap from inside the app names its own surface (`banner`);
          // anything arriving from outside is a deep link.
          InterestSourceTracker.instance.pin(source ?? InterestSource.deeplink);
          dlog('nav: pushing ${route.routeName} ($signature)');
          _topSignature = signature;
          await _appRouter.push(route);
          dlog('nav: DONE');
      }
    } catch (e, stack) {
      dlog('nav: ERROR $e\n$stack');
    }
  }
}

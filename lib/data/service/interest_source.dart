import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

/// Where a catalog request came FROM, as the backend cannot know.
///
/// The server sees WHAT a user opened — `GET /classes/:id` is the same request
/// whether the class was tapped in the home row, found by searching, or opened
/// from a push notification — and records the interest itself. Only the app
/// knows which of those it was, so it says, in an `X-Lumi-Source` header.
///
/// Values match the backend's `InterestSource` enum, which is a CLOSED list:
/// anything not on it is dropped server-side rather than written through onto
/// a console screen.
class InterestSource {
  const InterestSource._();

  static const home = 'home';
  static const search = 'search';
  static const category = 'category';
  static const map = 'map';
  static const branch = 'branch';
  static const banner = 'banner';
  static const shorts = 'shorts';
  static const deeplink = 'deeplink';
  static const notification = 'notification';
  static const profile = 'profile';
  static const calendar = 'calendar';
  static const other = 'other';
}

/// Screens the user can be standing on when they open something else.
///
/// Only the screens that LEAD somewhere are mapped. A route that is not here
/// resolves to no source at all rather than to [InterestSource.other] — an
/// absent header reads as "we don't know", which is honest, where `other`
/// would be a category on a chart that means nothing.
const _sourceByRoute = <String, String>{
  'HomeRoute': InterestSource.home,
  'ClassesGridRoute': InterestSource.category,
  'SearchRoute': InterestSource.search,
  'SearchDiscoveryRoute': InterestSource.search,
  'BranchesMapRoute': InterestSource.map,
  'BranchDetailRoute': InterestSource.branch,
  'ShortsRoute': InterestSource.shorts,
  'CalendarRoute': InterestSource.calendar,
  'ProfileRoute': InterestSource.profile,
  'NotificationsRoute': InterestSource.notification,
};

/// The screen the user is currently on, kept up to date by
/// [InterestSourceObserver] and read by `InterestSourceInterceptor`.
///
/// Deliberately a plain global rather than an injected singleton: it is read
/// from inside a Dio interceptor on every catalog request, and it is a single
/// nullable string with no lifecycle of its own.
class InterestSourceTracker {
  InterestSourceTracker._();

  static final InterestSourceTracker instance = InterestSourceTracker._();

  String? _current;

  String? get current => _current;

  /// Pins a source that no route can express — a deep link or a notification
  /// tap, where the user came from outside the app entirely.
  ///
  /// Holds until the next navigation overwrites it, which is exactly long
  /// enough: the detail page's fetch happens in the `initState` that follows.
  void pin(String source) => _current = source;

  void _onRoute(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null) return;
    // An unmapped screen leaves the last known source standing rather than
    // clearing it. Half the app's routes are sheets and dialogs pushed over
    // the screen the user is still, to their mind, looking at.
    final source = _sourceByRoute[name];
    if (source != null) _current = source;
  }
}

/// Feeds [InterestSourceTracker] from navigation.
///
/// `AppRouter.config` takes a BUILDER for its observers and calls it once per
/// router — including the nested one behind the bottom tabs — so every
/// instance writes into the one shared tracker rather than holding state.
class InterestSourceObserver extends AutoRouteObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // The screen being LEFT is the source of what is being opened, and it is
    // still `previousRoute` at the moment of the push — which is the same
    // frame the new page's `initState` fires its fetch in.
    InterestSourceTracker.instance._onRoute(previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    // Back onto the screen underneath — whatever is opened next comes from it.
    InterestSourceTracker.instance._onRoute(previousRoute);
  }

  /// Switching bottom tabs is not a push, so the tab's own route has to say so.
  @override
  void didChangeTabRoute(TabPageRoute route, TabPageRoute previousRoute) {
    final source = _sourceByRoute[route.name];
    if (source != null) InterestSourceTracker.instance.pin(source);
  }

  @override
  void didInitTabRoute(TabPageRoute route, TabPageRoute? previousRoute) {
    final source = _sourceByRoute[route.name];
    if (source != null) InterestSourceTracker.instance.pin(source);
  }
}

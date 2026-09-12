import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_api.dart';

/// Where a resolved deep-link route is placed on the navigation stack.
enum DeepLinkNavMode {
  /// Switch the bottom nav to [DeepLinkRoute.tabIndex] — no push.
  /// Top-level destinations: `lumi://home`, `lumi://profile`.
  tab,

  /// Push as a full-screen route on the root navigator, which is how every
  /// detail and settings screen in this app is already opened.
  root,
}

/// Builds a route from the link's parameters. Returning `null` aborts
/// navigation — a required parameter was missing, or a lookup failed.
///
/// Async because some destinations cannot be opened from an id alone:
/// [BranchDetailPage] renders entirely from the `HomBranch` it is handed and
/// never fetches one, so a `lumi://branch/<id>` has to resolve the document
/// before it can push.
typedef DeepLinkRouteBuilder = FutureOr<PageRouteInfo?> Function(
  Map<String, String> params,
);

/// One entry in the registry: how to build a route and where to put it.
class DeepLinkRoute {
  const DeepLinkRoute({required this.mode, this.build, this.tabIndex})
      : assert(
          mode == DeepLinkNavMode.tab || build != null,
          'root entries must provide a build function',
        ),
        assert(
          mode != DeepLinkNavMode.tab || tabIndex != null,
          'tab entries must provide a tabIndex',
        );

  final DeepLinkNavMode mode;
  final DeepLinkRouteBuilder? build;

  /// Bottom-nav index — see [DeepLinkRoutes._tab*]. Required for
  /// [DeepLinkNavMode.tab].
  final int? tabIndex;
}

/// A link normalised to "which destination, with what parameters".
class DeepLinkTarget {
  const DeepLinkTarget(this.key, this.params);

  /// The registry key — `class`, `plans`, `profile`, …
  final String key;

  /// Query parameters, plus `id` folded in from the trailing path segment so
  /// `lumi://class/<id>` and `lumi://class?id=<id>` are the same thing.
  final Map<String, String> params;

  String? get id => params['id'];

  @override
  String toString() => 'DeepLinkTarget($key, $params)';
}

/// The deep-link map: which link opens which screen.
///
/// This is the single source of truth both the adminka and the backend code
/// against. To expose a new screen, add ONE entry to [_registry] — the handler
/// never changes, and the same key works in all three link shapes:
///
///   lumi://class/<id>                                  custom scheme
///   https://mobile-api.lumipass.uz/share/class/<id>    App / Universal Link
///   OneLink with deep_link_value=class&deep_link_sub1  AppsFlyer
///
/// Unknown keys are logged and ignored, never thrown — a banner shipped with a
/// typo must not crash the app, and a link naming a screen added in a LATER
/// release has to be survivable by the build that is already installed.
abstract final class DeepLinkRoutes {
  const DeepLinkRoutes._();

  // Visual tab order — must match `routes` in main_page.dart's AutoTabsScaffold.
  static const int _tabHome = 0;
  static const int _tabShorts = 1;
  static const int _tabCalendar = 2;
  static const int _tabSearch = 3;
  static const int _tabProfile = 4;

  /// Hosts whose `https://` links belong to us and must open IN the app rather
  /// than in the browser. `link.lumipass.uz` / `lumipass.onelink.me` are the
  /// two AppsFlyer OneLink hosts, already claimed in the manifest and the iOS
  /// entitlements.
  static const Set<String> appHosts = {
    'mobile-api.lumipass.uz',
    'dev-mobile-api.lumipass.uz',
    'app.lumipass.uz',
    'lumipass.uz',
    'www.lumipass.uz',
    'link.lumipass.uz',
    'lumipass.onelink.me',
  };

  /// The path prefix our own share links use: `/share/<key>/<id>`.
  static const String sharePrefix = 'share';

  /// Every key the app understands, for the adminka's destination picker and
  /// for validating a banner's link before it is saved.
  static List<String> get keys => _registry.keys.toList(growable: false);

  static DeepLinkRoute? lookup(String key) => _registry[key.toLowerCase()];

  /// Normalises any supported link shape to a [DeepLinkTarget], or `null` when
  /// the URI names nothing this build knows about.
  ///
  /// The key is taken from the URI's host for a scheme link (`lumi://class/1`
  /// parses as host `class`, path `/1`) and from the path for an https share
  /// link. Everything after the key is treated as the `id`, so a link keeps
  /// working whether the id rides in the path or in a query parameter.
  static DeepLinkTarget? resolve(Uri uri) {
    final segments = [
      for (final s in uri.pathSegments)
        if (s.trim().isNotEmpty) s.trim(),
    ];

    String? key;
    List<String> rest;

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      // lumi://class/<id> — host is the key, the path carries the id.
      key = uri.host.isNotEmpty ? uri.host : (segments.isEmpty ? null : segments.first);
      rest = uri.host.isNotEmpty ? segments : segments.skip(1).toList();
    } else {
      if (!appHosts.contains(uri.host)) return null;
      // https://<our-host>/share/<key>/<id>, and the bare /<key>/<id> a
      // hand-written link is just as likely to use.
      final i = segments.indexOf(sharePrefix);
      final after = i == -1 ? segments : segments.skip(i + 1).toList();
      if (after.isEmpty) return null;
      key = after.first;
      rest = after.skip(1).toList();
    }

    if (key == null || key.isEmpty) return null;
    key = key.toLowerCase();
    if (!_registry.containsKey(key)) {
      log('[Deeplink] no route registered for "$key" ($uri)');
      return null;
    }

    return DeepLinkTarget(key, {
      ...uri.queryParameters,
      // The path wins over `?id=`: it is the form our own share links emit.
      if (rest.isNotEmpty) 'id': rest.first,
    });
  }

  static final Map<String, DeepLinkRoute> _registry = {
    // ── Tabs ───────────────────────────────────────────────────────────────
    'home': const DeepLinkRoute(mode: DeepLinkNavMode.tab, tabIndex: _tabHome),
    'shorts':
        const DeepLinkRoute(mode: DeepLinkNavMode.tab, tabIndex: _tabShorts),
    'calendar':
        const DeepLinkRoute(mode: DeepLinkNavMode.tab, tabIndex: _tabCalendar),
    'search':
        const DeepLinkRoute(mode: DeepLinkNavMode.tab, tabIndex: _tabSearch),
    'profile':
        const DeepLinkRoute(mode: DeepLinkNavMode.tab, tabIndex: _tabProfile),

    // ── Catalog ────────────────────────────────────────────────────────────
    // A course opens the same screen as a class: ClassDetailPage resolves the
    // course itself (`_course`) once it has the id. `activity` is the name the
    // AppsFlyer templates already use for the same thing.
    'class': const DeepLinkRoute(mode: DeepLinkNavMode.root, build: _buildClass),
    'course': const DeepLinkRoute(mode: DeepLinkNavMode.root, build: _buildClass),
    'activity': const DeepLinkRoute(mode: DeepLinkNavMode.root, build: _buildClass),
    'branch': const DeepLinkRoute(mode: DeepLinkNavMode.root, build: _buildBranch),
    'category': const DeepLinkRoute(mode: DeepLinkNavMode.root, build: _buildCategory),
    'discovery': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => SearchDiscoveryRoute(autofocusSearch: true),
    ),
    'map': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => BranchesMapRoute(),
    ),

    // ── Money ──────────────────────────────────────────────────────────────
    'plans': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => const PlansRoute(),
    ),
    'coupons': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => const CouponsRoute(),
    ),
    'wallet': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => const WalletRoute(),
    ),
    'cards': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => const MyCardsRoute(),
    ),
    'payment-history': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => const PaymentHistoryRoute(),
    ),

    // ── Account ────────────────────────────────────────────────────────────
    'my-bookings': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => const MyBookingsRoute(),
    ),
    'notifications': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => const NotificationsRoute(),
    ),
    'faq': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => const FaqRoute(),
    ),
  };

  /// `lumi://class/<id>` — pushes the detail page with a minimal [HomClass].
  /// [ClassDetailPage] calls `_loadFull()` from `initState`, so the full record
  /// arrives as soon as the screen is on, exactly as it does for a card tap.
  static PageRouteInfo? _buildClass(Map<String, String> params) {
    final id = params['id'];
    if (id == null || id.isEmpty) {
      log('[Deeplink] class link is missing its id');
      return null;
    }
    return ClassDetailRoute(classModel: HomClass(id: id));
  }

  /// `lumi://branch/<id>` — resolves the branch BEFORE pushing.
  ///
  /// Unlike the class page, [BranchDetailPage] draws its hero, title, address
  /// and map from the object it is given and never fetches one, so pushing a
  /// bare `HomBranch(id:)` would land the user on an empty page.
  static Future<PageRouteInfo?> _buildBranch(Map<String, String> params) async {
    final id = params['id'];
    if (id == null || id.isEmpty) {
      log('[Deeplink] branch link is missing its id');
      return null;
    }
    try {
      final res = await getIt<HomeApi>().getBranch(id);
      final json = (res.data as Map)['data'];
      if (json is! Map<String, dynamic>) {
        log('[Deeplink] branch $id came back without a document');
        return null;
      }
      return BranchDetailRoute(branch: HomBranch.fromJson(json));
    } catch (e) {
      log('[Deeplink] branch $id could not be loaded: $e');
      return null;
    }
  }

  /// `lumi://category/<id>?title=Танцы` — opens discovery filtered to it.
  /// The title is optional and only cosmetic: the screen filters on the id.
  static PageRouteInfo? _buildCategory(Map<String, String> params) {
    final id = params['id'];
    if (id == null || id.isEmpty) {
      log('[Deeplink] category link is missing its id');
      return null;
    }
    return SearchDiscoveryRoute(
      initialCategory: HomCategory(id: id, title: params['title']),
    );
  }
}

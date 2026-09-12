import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/router/deep_link_log.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';
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
    dlog('resolve: scheme=${uri.scheme} host=${uri.host} '
        'path=${uri.path} query=${uri.queryParameters}');

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
      dlog('  scheme link -> key="$key" rest=$rest');
    } else {
      if (!appHosts.contains(uri.host)) {
        dlog('  REJECT: "${uri.host}" is not one of our hosts, '
            'this belongs to the browser');
        return null;
      }
      // https://<our-host>/share/<key>/<id>, and the bare /<key>/<id> a
      // hand-written link is just as likely to use.
      final i = segments.indexOf(sharePrefix);
      final after = i == -1 ? segments : segments.skip(i + 1).toList();
      if (after.isEmpty) {
        dlog('  REJECT: our host but no destination in the path');
        return null;
      }
      key = after.first;
      rest = after.skip(1).toList();
      dlog('  app link -> key="$key" rest=$rest');
    }

    if (key == null || key.isEmpty) {
      dlog('  REJECT: no destination key in the link');
      return null;
    }
    key = key.toLowerCase();
    if (!_registry.containsKey(key)) {
      dlog('  REJECT: "$key" is not registered. Known: ${keys.join(", ")}');
      return null;
    }

    final target = DeepLinkTarget(key, {
      ...uri.queryParameters,
      // The path wins over `?id=`: it is the form our own share links emit.
      if (rest.isNotEmpty) 'id': rest.first,
    });
    dlog('  OK -> $target');
    return target;
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

    // ── Shop ───────────────────────────────────────────────────────────────
    // All three answer null while `shop_enabled` is off in Remote Config.
    // A banner or a push can outlive the campaign it belongs to, and a link
    // that opens a storefront nobody is stocking or delivering from is worse
    // than one that quietly does nothing.
    'shop': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: (_) => _shopOpen ? ShopRoute() : null,
    ),
    // `lumi://shop-product/<id>` — the product screen fetches the product
    // itself, so unlike a branch link there is nothing to load here first.
    'shop-product': const DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      build: _buildShopProduct,
    ),
    'shop-orders': DeepLinkRoute(
      mode: DeepLinkNavMode.root,
      // The orders list is the shop's third tab, not a screen of its own.
      build: (_) => _shopOpen ? ShopRoute(initialTab: 2) : null,
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
      dlog('build class: ABORT, no id in $params');
      return null;
    }
    dlog('build class: pushing ClassDetailRoute(id=$id)');
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
      dlog('build branch: ABORT, no id in $params');
      return null;
    }
    try {
      dlog('build branch: fetching branches/$id/mobile …');
      final res = await getIt<HomeApi>().getBranch(id);
      final json = (res.data as Map)['data'];
      if (json is! Map<String, dynamic>) {
        dlog('build branch: ABORT, $id came back without a document');
        return null;
      }
      final branch = HomBranch.fromJson(json);
      dlog('build branch: got "${branch.title}", pushing BranchDetailRoute');
      return BranchDetailRoute(branch: branch);
    } catch (e) {
      dlog('build branch: ABORT, $id could not be loaded: $e');
      return null;
    }
  }

  /// Whether the merch shop is open at all — see
  /// `RemoteConfigService.isShopEnabled`. False until someone switches it on.
  static bool get _shopOpen => RemoteConfigService.instance.isShopEnabled;

  /// `lumi://shop-product/<id>` — one merch product.
  static PageRouteInfo? _buildShopProduct(Map<String, String> params) {
    if (!_shopOpen) {
      dlog('build shop product: ABORT, the shop is switched off');
      return null;
    }
    final id = params['id'];
    if (id == null || id.isEmpty) {
      dlog('build shop product: ABORT, no id in $params');
      return null;
    }
    return ShopProductRoute(productId: id);
  }

  /// `lumi://category/<id>?title=Танцы` — opens discovery filtered to it.
  /// The title is optional and only cosmetic: the screen filters on the id.
  static PageRouteInfo? _buildCategory(Map<String, String> params) {
    final id = params['id'];
    if (id == null || id.isEmpty) {
      dlog('build category: ABORT, no id in $params');
      return null;
    }
    dlog('build category: pushing SearchDiscoveryRoute(category=$id)');
    return SearchDiscoveryRoute(
      initialCategory: HomCategory(id: id, title: params['title']),
    );
  }
}

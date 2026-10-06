import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/router/deep_link_routes.dart';
import 'package:lumi_pass/data/storage/storage.dart';

/// The Lumi Coin shelf took the Броны slot on the bottom bar, which leaves it
/// registered twice — as `MainRoute`'s fourth child (the Тарифы tab) and
/// top-level (a push that carries `topUpFor` / `returnOnPurchase`). These pin
/// down that the config still resolves, and that nothing which used to open
/// the booking tab now opens nothing.
void main() {
  late Directory tmp;
  late AppRouter router;

  setUpAll(() async {
    // `AppRouter` builds an `InitialGuard`, which reads `Storage` out of GetIt.
    tmp = await Directory.systemTemp.createTemp('lumi_router_test');
    Hive.init(tmp.path);
    final box = await Hive.openBox('storage');
    GetIt.I.registerSingleton<Storage>(Storage(box));
    router = AppRouter();
  });

  tearDownAll(() async {
    await Hive.close();
    await GetIt.I.reset();
    await tmp.delete(recursive: true);
  });

  AutoRoute mainRoute() =>
      router.routes.firstWhere((r) => r.name == MainRoute.name);

  test('the router config is valid with the shelf registered twice', () {
    // Forces auto_route to build its RouteCollection over the whole tree,
    // which is where a bad config — a duplicate path, or a page with no entry
    // in `pagesMap` — throws.
    expect(router.routeCollection.routes, isNotEmpty);
    // Exactly one top-level entry: the pushed shelf, the only one that can be
    // given arguments.
    expect(
      router.routes.where((r) => r.name == NewCoinsRoute.name),
      hasLength(1),
    );
  });

  test('the shelf is the fourth tab, where the booking list used to be', () {
    final names = mainRoute().children!.routes.map((r) => r.name).toList();
    expect(names, [
      HomeRoute.name,
      SearchCategoriesRoute.name,
      ShortsRoute.name,
      NewCoinsRoute.name,
      ProfileRoute.name,
    ]);
    expect(names, isNot(contains(CalendarRoute.name)));
  });

  test('the pushed shelf still carries its arguments', () {
    // The reason the shelf stays registered top-level as well as on the bar:
    // a booking that is short opens it to top up and wants the buyer back.
    // The tab form takes no arguments, so it could not serve this.
    final route = NewCoinsRoute(topUpFor: 7, returnOnPurchase: true);
    final args = route.args as NewCoinsRouteArgs;
    expect(args.topUpFor, 7);
    expect(args.returnOnPurchase, isTrue);
  });

  test('lumi://coins switches to the Тарифы tab rather than stacking a copy',
      () {
    final entry = DeepLinkRoutes.lookup('coins')!;
    expect(entry.mode, DeepLinkNavMode.tab);
    // The slot the bar gives the shelf — index 3, the old Броны slot.
    expect(entry.tabIndex, 3);
  });

  test('lumi://calendar still lands on a booking list', () {
    final entry = DeepLinkRoutes.lookup('calendar')!;
    // No longer a tab, so it pushes the full list that sits behind Profile.
    expect(entry.mode, DeepLinkNavMode.root);
    expect(entry.build, isNotNull);
    expect(entry.build!({}), isA<MyBookingsRoute>());
  });
}

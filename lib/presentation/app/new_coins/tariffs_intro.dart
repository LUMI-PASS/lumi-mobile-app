import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/new_coins/new_coins_repository.dart';
import 'package:lumi_pass/presentation/app/new_coins/new_coins_page.dart';

/// Shows the tariffs after a successful sign-in: the Lumi Coin shelf,
/// full screen, with a ✕ to close it.
///
/// Called by MainPage once per sign-in (`Storage.tariffsIntroOwed`, set by
/// `enterAppAfterSignIn` for new and returning accounts alike). The shelf is fetched BEFORE anything is pushed: with nothing on sale
/// (or no connection) the new user goes straight into the app rather than
/// onto a screen that would only close itself.
///
/// Returns whether the intro was shown, so the caller does not stack another
/// interstitial on the same launch.
Future<bool> showTariffsIntro(BuildContext context) async {
  try {
    final catalogue = await getIt<NewCoinsRepository>().getCatalogue();
    if (!catalogue.isOnSale) return false;
  } catch (_) {
    return false;
  }
  if (!context.mounted) return false;
  // Over the tabs and the bottom nav, sliding up like a sheet — a
  // fullscreen dialog route is the platform's own "modal you close with ✕".
  //
  // Through the ROOT AutoRouter, like the interests question — not
  // `Navigator.of(context, rootNavigator: true)`, whose navigator sits outside
  // every AutoRouter scope: there `context.router` throws, and the shelf and
  // the checkout/FAQ screens it opens (BaseAppBar) all call it.
  await context.router.root.pushWidget<bool>(
    const NewCoinsPage(isIntro: true),
    fullscreenDialog: true,
  );
  return true;
}

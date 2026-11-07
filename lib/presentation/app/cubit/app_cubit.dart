import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/service/interest_reporter.dart';
import 'package:lumi_pass/data/service/saved_activity_store.dart';
import 'package:lumi_pass/data/service/push_notification_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:lumi_pass/common/utils/new_coins_summary.dart';
import 'package:lumi_pass/common/utils/promo_pass_coverage.dart';
import 'package:lumi_pass/domain/repo/new_coins/new_coins_repository.dart';
import 'package:lumi_pass/domain/repo/promo/promo_repository.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'app_state.dart';

/// One instance for the whole run — deliberately a singleton, not a factory.
///
/// The root `BlocProvider` (MyApp) resolves this from `getIt`, and every price
/// on screen watches that instance. Checkout flows reach the cubit the only way
/// they can from outside the tree, `getIt<AppCubit>()`; as a factory that call
/// built a *second*, throwaway cubit — it synced into its own state, then was discarded, so the cards and the detail page
/// kept rendering the pre-purchase state until the next cold start (and every
/// such call re-fired `app_open` and re-registered the FCM token as a bonus).
@lazySingleton
class AppCubit extends BaseCubit<AppBuildable, AppListenable> {
  AppCubit(this._repo, this._push, this._storage)
      : super(const AppBuildable()) {
    final analytics = getIt<AnalyticsService>();
    // Re-register the FCM token on warm start so token rotations during
    // background time make it back to the server. Skipped when not logged in;
    // the post-login flow handles first-time registration.
    final tokens = _storage.tokens();
    if (tokens?.access != null && tokens!.access!.isNotEmpty) {
      _push.registerCurrentDevice();
      // Re-apply identity so warm-start events are attributed to the user.
      analytics.identify();
      // The packet decides what prices render, so it is pulled on warm start
      // — a price that is wrong on the first frame is the whole bug.
      _syncPromoPass();
      // Send any booking sheet abandoned on a bad connection last time. The
      // whole signal is a user who lost interest and left, so the send has to
      // survive the app being closed — see [InterestReporter].
      getIt<InterestReporter>().flush();
      // The saved shelf is the account's, so another phone may have changed
      // it since this one last looked.
      getIt<SavedActivityStore>().sync();
    }
    // Outside the signed-in block: the shelf is public, and whether anything
    // is on it decides if a guest sees coin prices at all. The balance half
    // is skipped for a guest inside the sync itself.
    _syncNewCoins();
    analytics.logEvent(AnalyticsEvent.appOpen);
  }

  final AuthRepository _repo;
  final PushNotificationService _push;
  final Storage _storage;

  /// Public entry point for every flow that can change what is left on the
  /// packet: buying one, and spending a visit at checkout. Prices across the
  /// catalogue hang off this, so it is re-pulled rather than guessed at —
  /// the third booking is what brings every price back.
  Future<void> syncPromoPass() => _syncPromoPass();

  /// Signing out drops the packet — this cubit outlives the
  /// session, so without it the next account would inherit hidden prices.
  void clearPromoPass() => build((b) => b.copyWith(promoPass: null));

  /// Fetches the user's live packet and publishes the subset the display rule
  /// needs (see [PromoPassCoverage]).
  ///
  /// A failure leaves the previous answer standing rather than clearing it: the
  /// safe direction is unchanged, and clearing on a flaky network would flash
  /// every price back onto a screen whose packet is fine. Checkout re-tests the
  /// rules regardless, so a stale label can never charge anybody.
  Future<void> _syncPromoPass() async {
    try {
      final passes = await getIt<PromoRepository>().getPasses();
      final live = passes.where((p) => p.isUsable);
      build((b) => b.copyWith(
            promoPass: live.isEmpty
                ? null
                : PromoPassCoverage.fromPass(
                    // Nearest deadline first, which is the one checkout spends.
                    live.reduce((a, b) => a.daysLeft <= b.daysLeft ? a : b),
                  ),
          ));
    } catch (_) {
      // Network / auth failure — leave state as-is.
    }
  }

  /// Public entry point for every flow that moves coins: buying a pack or
  /// loose coins, and paying for a booking with them.
  Future<void> syncNewCoins() => _syncNewCoins();

  /// Pulls the coin shelf and, when signed in, the balance.
  ///
  /// The two are fetched independently and each failure leaves its own half
  /// standing, for the reason [_syncPromoPass] does: a flaky network must not
  /// flash the coin option out from under someone about to pay with it.
  /// Checkout re-tests the balance regardless, so a stale figure can never
  /// spend coins that are not there.
  Future<void> _syncNewCoins() async {
    final repo = getIt<NewCoinsRepository>();
    try {
      final catalogue = await repo.getCatalogue();
      build((b) => b.copyWith(
            newCoins:
                (b.newCoins ?? const NewCoinsSummary()).withCatalogue(catalogue),
          ));
    } catch (_) {
      // Network failure, or a backend that predates coins — leave as-is.
    }
    final tokens = _storage.tokens();
    if (tokens?.access == null || tokens!.access!.isEmpty) return;
    try {
      final held = await repo.getBalance();
      build((b) => b.copyWith(
            newCoins: (b.newCoins ?? const NewCoinsSummary()).withBalance(held),
          ));
    } catch (_) {
      // Network / auth failure — leave state as-is.
    }
  }

  /// Signing out has to drop the account's state from memory too:
  /// `Storage.logout()` clears the box, but this cubit outlives the session,
  /// so without this the next account signed in on the same run would inherit
  /// the last one's packet and coins.
  void clearSession() => build(
      (b) => b.copyWith(
        promoPass: null,
        // The shelf stays — it is public — but the coins were the last
        // account's.
        newCoins: b.newCoins?.signedOut(),
      ));

  /// Signing in is the other half of that: the cubit was built at cold start,
  /// possibly logged out, so pull the new account's state now rather than at
  /// the next launch.
  Future<void> onSignedIn() async {
    await _syncPromoPass();
    await _syncNewCoins();
  }

  /// The root `BlocProvider` closes whatever it creates when it is disposed.
  /// This cubit is shared with every `getIt<AppCubit>()` caller, so closing it
  /// would silently kill later syncs — `BaseCubit.build` bails out on
  /// `isClosed`. It is meant to live for the whole run.
  @override
  Future<void> close() async {}
}

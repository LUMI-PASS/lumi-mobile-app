import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/service/interest_reporter.dart';
import 'package:lumi_pass/data/service/push_notification_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'app_state.dart';

/// One instance for the whole run — deliberately a singleton, not a factory.
///
/// The root `BlocProvider` (MyApp) resolves this from `getIt`, and every price
/// on screen watches that instance. Checkout flows reach the cubit the only way
/// they can from outside the tree, `getIt<AppCubit>()`; as a factory that call
/// built a *second*, throwaway cubit — it synced the subscription into Hive and
/// into its own state, then was discarded, so the cards and the detail page
/// kept rendering the pre-purchase state until the next cold start (and every
/// such call re-fired `app_open` and re-registered the FCM token as a bonus).
@lazySingleton
class AppCubit extends BaseCubit<AppBuildable, AppListenable> {
  AppCubit(this._repo, this._push, this._storage)
      : super(AppBuildable(
          // Seed from the last-known Hive value so a watcher gets the right
          // answer on the very first frame, before the network sync below
          // has had a chance to resolve — avoids a flash of "no discount".
          hasPremium: _storage.hasPremium() == true,
          planDiscountPercentage: _storage.planDiscountPercentage() ?? 0,
        )) {
    final analytics = getIt<AnalyticsService>();
    // Re-register the FCM token on warm start so token rotations during
    // background time make it back to the server. Skipped when not logged in;
    // the post-login flow handles first-time registration.
    final tokens = _storage.tokens();
    if (tokens?.access != null && tokens!.access!.isNotEmpty) {
      _push.registerCurrentDevice();
      // Re-apply identity so warm-start events are attributed to the user.
      analytics.identify();
      // Sync premium/coupon status from the server so it works across
      // devices and after reinstalls — local Hive storage alone is not enough.
      _syncSubscriptionStatus();
      // Send any booking sheet abandoned on a bad connection last time. The
      // whole signal is a user who lost interest and left, so the send has to
      // survive the app being closed — see [InterestReporter].
      getIt<InterestReporter>().flush();
    }
    analytics.logEvent(AnalyticsEvent.appOpen);
  }

  final AuthRepository _repo;
  final PushNotificationService _push;
  final Storage _storage;

  /// Public entry point for checkout flows: re-fetches subscription status so
  /// the discount badge disappears the moment a coupon's activity cap is
  /// reached (coins hit 0 at checkout time, not at payment time).
  Future<void> syncSubscription() => _syncSubscriptionStatus();

  /// Called when a plan purchase is confirmed paid. Marks the plan active
  /// straight away — the payment is settled, so the prices on screen should
  /// drop on this frame — then confirms against the server, which is what
  /// fills in the authoritative percentage and catches an already-exhausted
  /// coupon.
  Future<void> applyPurchasedPlan(int discountPercentage) async {
    await _storage.hasPremium.set(true);
    await _storage.planDiscountPercentage.set(discountPercentage);
    build((b) => b.copyWith(
          hasPremium: true,
          planDiscountPercentage: discountPercentage,
        ));
    await _syncSubscriptionStatus();
  }

  /// Signing out has to drop the plan from memory too: `Storage.logout()`
  /// clears the box, but this cubit outlives the session, so without this the
  /// next account signed in on the same run would inherit the discount.
  void clearSubscription() =>
      build((b) => b.copyWith(hasPremium: false, planDiscountPercentage: 0));

  /// Signing in is the other half of that: the cubit was built at cold start,
  /// possibly logged out, so pull the new account's plan now rather than at the
  /// next launch.
  Future<void> onSignedIn() => _syncSubscriptionStatus();

  /// Fetches the user's active subscription from the backend and updates
  /// both Hive (survives a restart) and Cubit state (every watcher rebuilds
  /// right now). This ensures `hasPremium` and `planDiscountPercentage` are
  /// correct on every device, not just the one that made the payment — and
  /// that a card on screen at the moment reflects it immediately instead of
  /// only on the next cold start that happens to re-run this cubit.
  ///
  /// - Server returns a subscription  → hasPremium=true + discount %
  /// - Server returns null (expired / exhausted) → clear both flags
  /// - Network / auth error            → keep existing state unchanged
  Future<void> _syncSubscriptionStatus() async {
    try {
      final ordersApi = getIt<OrdersApi>();
      final sub = await ordersApi.getActiveSubscription();
      final hasPremium = sub != null;
      final discountPct =
          hasPremium ? (sub['discount_percentage'] as num?)?.toInt() ?? 0 : 0;
      await _storage.hasPremium.set(hasPremium);
      await _storage.planDiscountPercentage.set(discountPct);
      build((b) => b.copyWith(
            hasPremium: hasPremium,
            planDiscountPercentage: discountPct,
          ));
    } catch (_) {
      // Network / auth failure — leave state as-is.
    }
  }

  /// The root `BlocProvider` closes whatever it creates when it is disposed.
  /// This cubit is shared with every `getIt<AppCubit>()` caller, so closing it
  /// would silently kill later syncs — `BaseCubit.build` bails out on
  /// `isClosed`. It is meant to live for the whole run.
  @override
  Future<void> close() async {}
}

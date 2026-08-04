import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/data/service/analytics_service.dart';
import 'package:lumi_pass/data/service/push_notification_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/auth/auth_repository.dart';
import 'package:lumi_pass/domain/repo/orders/orders_api.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import 'app_state.dart';

@injectable
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
}

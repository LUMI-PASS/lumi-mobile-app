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
  /// local storage. This ensures `hasPremium` and `planDiscountPercentage`
  /// are correct on every device, not just the one that made the payment.
  ///
  /// - Server returns a subscription  → write hasPremium=true + discount %
  /// - Server returns null (expired / exhausted) → clear both flags
  /// - Network / auth error            → keep existing local state unchanged
  Future<void> _syncSubscriptionStatus() async {
    try {
      final ordersApi = getIt<OrdersApi>();
      final sub = await ordersApi.getActiveSubscription();
      if (sub != null) {
        await _storage.hasPremium.set(true);
        final discountPct = (sub['discount_percentage'] as num?)?.toInt() ?? 0;
        await _storage.planDiscountPercentage.set(discountPct);
      } else {
        // Server confirmed no active subscription — clear local flags so
        // expired plans don't linger after reinstall on a new device.
        await _storage.hasPremium.set(false);
        await _storage.planDiscountPercentage.set(0);
      }
    } catch (_) {
      // Network / auth failure — leave local state as-is.
    }
  }
}

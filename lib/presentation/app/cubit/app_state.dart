import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/common/utils/promo_pass_coverage.dart';

part 'app_state.freezed.dart';

@freezed
class AppBuildable with _$AppBuildable {
  /// Live coupon-plan status, kept in Cubit state (not just Hive) so every
  /// watcher — activity cards, the detail page, the booking sheet — rebuilds
  /// the instant `AppCubit.syncSubscription()` resolves, instead of each
  /// reading a stale one-time snapshot of `Storage` at whatever moment it
  /// happened to build.
  const factory AppBuildable({
    @Default(false) bool hasPremium,
    @Default(0) int planDiscountPercentage,

    /// The live "Lumi Start" packet, or null when the user holds none.
    ///
    /// Here for the same reason the coupon plan is: it decides what every price
    /// in the catalogue RENDERS — a covered activity shows an included badge
    /// instead of a figure — so it has to be one value every card watches, not
    /// a fetch per screen. Null the moment it is spent or expires, which is
    /// what brings the prices back.
    PromoPassCoverage? promoPass,
  }) = _AppBuildable;
}

@freezed
class AppListenable with _$AppListenable {
  const factory AppListenable() = _AppListenable;
}

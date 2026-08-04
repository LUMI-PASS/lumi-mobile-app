import 'package:freezed_annotation/freezed_annotation.dart';

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
  }) = _AppBuildable;
}

@freezed
class AppListenable with _$AppListenable {
  const factory AppListenable() = _AppListenable;
}

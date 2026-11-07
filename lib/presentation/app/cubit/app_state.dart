import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/common/utils/new_coins_summary.dart';
import 'package:lumi_pass/common/utils/promo_pass_coverage.dart';

part 'app_state.freezed.dart';

@freezed
class AppBuildable with _$AppBuildable {
  /// App-wide state every price on screen watches, so each card, the detail
  /// page and the booking sheet rebuild the instant a sync resolves.
  const factory AppBuildable({
    /// The live "Lumi Start" packet, or null when the user holds none.
    ///
    /// It decides what every price in the catalogue RENDERS — a covered activity shows an included badge
    /// instead of a figure — so it has to be one value every card watches, not
    /// a fetch per screen. Null the moment it is spent or expires, which is
    /// what brings the prices back.
    PromoPassCoverage? promoPass,

    /// "Lumi Coin": whether packs are on sale and what this user holds.
    ///
    /// Null until the first sync lands, which reads the same as "not on sale"
    /// — every coin surface stays hidden rather than flashing in and out.
    NewCoinsSummary? newCoins,
  }) = _AppBuildable;
}

@freezed
class AppListenable with _$AppListenable {
  const factory AppListenable() = _AppListenable;
}

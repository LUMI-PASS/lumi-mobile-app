import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';

part 'referral_state.freezed.dart';

@freezed
class ReferralBuildable with _$ReferralBuildable {
  const factory ReferralBuildable({
    /// First paint only — a pull-to-refresh keeps the old data on screen.
    @Default(true) bool isLoading,

    /// The first load failed and there is nothing to show.
    @Default(false) bool hasError,
    ReferralMe? me,
  }) = _ReferralBuildable;
}

@freezed
class ReferralListenable with _$ReferralListenable {
  const factory ReferralListenable({
    required ReferralEffect effect,
  }) = _ReferralListenable;
}

enum ReferralEffect { none }

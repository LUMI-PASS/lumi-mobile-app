import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileBuildable with _$ProfileBuildable {
  const factory ProfileBuildable({
    @Default(false) bool isLoading,
    HomForUser? user,
    @Default([]) List<ChildModel> children,
    ParentTrialSummary? trialSummary,

    /// `GET /referrals/me`. Null until it lands or when it failed — the invite
    /// card and the "Have a referral code?" row then simply don't show.
    ReferralMe? referral,
  }) = _ProfileBuildable;
}

@freezed
class ProfileListenable with _$ProfileListenable {
  const factory ProfileListenable({
    required ProfileEffect effect,
  }) = _ProfileListenable;
}

enum ProfileEffect { login, deleted }

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileBuildable with _$ProfileBuildable {
  const factory ProfileBuildable({
    @Default(false) bool isLoading,
    HomForUser? user,
    @Default([]) List<ChildModel> children,
    ParentTrialSummary? trialSummary,
  }) = _ProfileBuildable;
}

@freezed
class ProfileListenable with _$ProfileListenable {
  const factory ProfileListenable({
    required ProfileEffect effect,
  }) = _ProfileListenable;
}

enum ProfileEffect { login, deleted }

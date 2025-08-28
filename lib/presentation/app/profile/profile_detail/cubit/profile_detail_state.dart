import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileBuildable with _$ProfileBuildable {
  const factory ProfileBuildable(
      {@Default(false) bool isSelected,
      @Default(false) bool isLoading,
      @Default(false) bool success,
      HomForUser? homeModel}) = _ProfileBuildable;
}

@freezed
class ProfileListenable with _$ProfileListenable {
  const factory ProfileListenable({
    required ProfileEffect effect,
  }) = _ProfileListenable;
}

enum ProfileEffect { verify, reg }

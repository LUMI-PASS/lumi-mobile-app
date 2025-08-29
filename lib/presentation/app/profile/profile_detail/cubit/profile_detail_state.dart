import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/profile_model/profile_model.dart';

part 'profile_detail_state.freezed.dart';

@freezed
class ProfileDetailBuildable with _$ProfileDetailBuildable {
  const factory ProfileDetailBuildable(
      {@Default(false) bool isSelected,
      @Default(false) bool isLoading,
      @Default(false) bool success,
      HomForUser? homeModel}) = _ProfileDetailBuildable;
}

@freezed
class ProfileDetailListenable with _$ProfileDetailListenable {
  const factory ProfileDetailListenable({
    required ProfileDetailEffect effect,
  }) = _ProfileDetailListenable;
}

enum ProfileDetailEffect { verify, reg }

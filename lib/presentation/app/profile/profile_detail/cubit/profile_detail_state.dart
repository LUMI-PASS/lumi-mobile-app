import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/interest_topic/interest_topic.dart';

part 'profile_detail_state.freezed.dart';

@freezed
class ProfileDetailBuildable with _$ProfileDetailBuildable {
  const factory ProfileDetailBuildable(
      {@Default(false) bool isSelected,
      @Default(false) bool isLoading,
      @Default(false) bool success,

      /// The words the form offers. Empty until loaded — and for good on a
      /// server that has none, where the form leaves the question out.
      @Default([]) List<InterestTopic> interestTopics,
      HomForUser? homeModel}) = _ProfileDetailBuildable;
}

@freezed
class ProfileDetailListenable with _$ProfileDetailListenable {
  const factory ProfileDetailListenable({
    required ProfileDetailEffect effect,
  }) = _ProfileDetailListenable;
}

enum ProfileDetailEffect { verify, reg }

import 'package:freezed_annotation/freezed_annotation.dart';

part 'child_model.freezed.dart';
part 'child_model.g.dart';

@freezed
class ChildModel with _$ChildModel {
  const factory ChildModel({
    String? id,
    @JsonKey(name: "parent_id") String? parentId,
    @JsonKey(name: "first_name") String? firstName,
    @JsonKey(name: "last_name") String? lastName,
    @JsonKey(name: "phone_number") String? phoneNumber,
    String? dob,
    String? gender,
    String? type,
    int? age,
    @JsonKey(name: "child_age_type") String? childAgeType,
    String? city,
    String? district,
    @JsonKey(name: "is_eligible") bool? isEligible,
    @JsonKey(name: "is_verified") bool? isVerified,
    @JsonKey(name: "has_photo") bool? hasPhoto,
    String? reason,
    @JsonKey(name: "remaining_trials") int? remainingTrials,
    @JsonKey(name: "paid_coin_accumulator") int? paidCoinAccumulator,
    @JsonKey(name: "unlock_cycles_granted") int? unlockCyclesGranted,
    @JsonKey(name: "coins_into_unlock_cycle") int? coinsIntoUnlockCycle,
    @JsonKey(name: "coins_to_next_unlock") int? coinsToNextUnlock,
    @JsonKey(name: "next_unlock_at_total_paid_coins") int? nextUnlockAtTotalPaidCoins,
    @JsonKey(name: "unlock_threshold_coin") int? unlockThresholdCoin,
    @JsonKey(name: "effective_class_price") num? effectiveClassPrice,
    @JsonKey(name: "will_use_trial") bool? willUseTrial,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
    @JsonKey(name: "deleted_at") String? deletedAt,
    dynamic parent,
  }) = _ChildModel;

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);
}

@freezed
class ParentTrialSummary with _$ParentTrialSummary {
  const factory ParentTrialSummary({
    @JsonKey(name: "total_remaining_trials") @Default(0) int totalRemainingTrials,
    @JsonKey(name: "unlock_threshold_coin") @Default(700) int unlockThresholdCoin,
    @JsonKey(name: "unlock_batch_trials") @Default(3) int unlockBatchTrials,
    @Default([]) List<TrialSummaryChild> children,
  }) = _ParentTrialSummary;

  factory ParentTrialSummary.fromJson(Map<String, dynamic> json) =>
      _$ParentTrialSummaryFromJson(json);
}

@freezed
class TrialSummaryChild with _$TrialSummaryChild {
  const factory TrialSummaryChild({
    @JsonKey(name: "child_id") String? childId,
    @JsonKey(name: "remaining_trials") int? remainingTrials,
    @JsonKey(name: "coins_into_unlock_cycle") int? coinsIntoUnlockCycle,
    @JsonKey(name: "coins_to_next_unlock") int? coinsToNextUnlock,
    @JsonKey(name: "next_unlock_at_total_paid_coins") int? nextUnlockAtTotalPaidCoins,
  }) = _TrialSummaryChild;

  factory TrialSummaryChild.fromJson(Map<String, dynamic> json) =>
      _$TrialSummaryChildFromJson(json);
}

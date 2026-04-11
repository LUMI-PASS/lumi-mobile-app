import 'package:freezed_annotation/freezed_annotation.dart';

part 'eligibility_model.freezed.dart';
part 'eligibility_model.g.dart';

@freezed
class ClassEligibilityData with _$ClassEligibilityData {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ClassEligibilityData({
    String? classId,
    String? classTitle,
    num? classPrice,
    num? classTrialPrice,
    bool? classTrialEnabled,
    int? minAge,
    int? maxAge,
    String? gender,
    bool? isBalanceEnough,
    bool? isBalanceEnoughForTrialPrice,
    @Default(0) num walletBalance,
    int? trialUnlockThresholdCoin,
    int? trialUnlockBatchLessonsPerUnlock,
    @Default([]) List<EligibleChild> children,
  }) = _ClassEligibilityData;

  factory ClassEligibilityData.fromJson(Map<String, dynamic> json) =>
      _$ClassEligibilityDataFromJson(json);
}

@freezed
class EligibleChild with _$EligibleChild {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EligibleChild({
    String? id,
    String? parentId,
    String? firstName,
    String? lastName,
    String? type,
    int? age,
    String? childAgeType,
    @Default(false) bool isEligible,
    bool? hasPhoto,
    String? reason,
    bool? isVerified,
    int? remainingTrials,
    int? paidCoinAccumulator,
    int? unlockCyclesGranted,
    int? coinsIntoUnlockCycle,
    int? coinsToNextUnlock,
    int? nextUnlockAtTotalPaidCoins,
    int? unlockThresholdCoin,
    num? effectiveClassPrice,
    bool? willUseTrial,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) = _EligibleChild;

  factory EligibleChild.fromJson(Map<String, dynamic> json) =>
      _$EligibleChildFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eligibility_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ClassEligibilityDataImpl _$$ClassEligibilityDataImplFromJson(
        Map<String, dynamic> json) =>
    _$ClassEligibilityDataImpl(
      classId: json['class_id'] as String?,
      classTitle: json['class_title'] as String?,
      classPrice: json['class_price'] as num?,
      classTrialPrice: json['class_trial_price'] as num?,
      classTrialEnabled: json['class_trial_enabled'] as bool?,
      minAge: (json['min_age'] as num?)?.toInt(),
      maxAge: (json['max_age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      isBalanceEnough: json['is_balance_enough'] as bool?,
      isBalanceEnoughForTrialPrice:
          json['is_balance_enough_for_trial_price'] as bool?,
      walletBalance: json['wallet_balance'] as num? ?? 0,
      trialUnlockThresholdCoin:
          (json['trial_unlock_threshold_coin'] as num?)?.toInt(),
      trialUnlockBatchLessonsPerUnlock:
          (json['trial_unlock_batch_lessons_per_unlock'] as num?)?.toInt(),
      children: (json['children'] as List<dynamic>?)
              ?.map((e) => EligibleChild.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ClassEligibilityDataImplToJson(
        _$ClassEligibilityDataImpl instance) =>
    <String, dynamic>{
      'class_id': instance.classId,
      'class_title': instance.classTitle,
      'class_price': instance.classPrice,
      'class_trial_price': instance.classTrialPrice,
      'class_trial_enabled': instance.classTrialEnabled,
      'min_age': instance.minAge,
      'max_age': instance.maxAge,
      'gender': instance.gender,
      'is_balance_enough': instance.isBalanceEnough,
      'is_balance_enough_for_trial_price':
          instance.isBalanceEnoughForTrialPrice,
      'wallet_balance': instance.walletBalance,
      'trial_unlock_threshold_coin': instance.trialUnlockThresholdCoin,
      'trial_unlock_batch_lessons_per_unlock':
          instance.trialUnlockBatchLessonsPerUnlock,
      'children': instance.children,
    };

_$EligibleChildImpl _$$EligibleChildImplFromJson(Map<String, dynamic> json) =>
    _$EligibleChildImpl(
      id: json['id'] as String?,
      parentId: json['parent_id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      type: json['type'] as String?,
      age: (json['age'] as num?)?.toInt(),
      childAgeType: json['child_age_type'] as String?,
      isEligible: json['is_eligible'] as bool? ?? false,
      hasPhoto: json['has_photo'] as bool?,
      reason: json['reason'] as String?,
      isVerified: json['is_verified'] as bool?,
      remainingTrials: (json['remaining_trials'] as num?)?.toInt(),
      paidCoinAccumulator: (json['paid_coin_accumulator'] as num?)?.toInt(),
      unlockCyclesGranted: (json['unlock_cycles_granted'] as num?)?.toInt(),
      coinsIntoUnlockCycle: (json['coins_into_unlock_cycle'] as num?)?.toInt(),
      coinsToNextUnlock: (json['coins_to_next_unlock'] as num?)?.toInt(),
      nextUnlockAtTotalPaidCoins:
          (json['next_unlock_at_total_paid_coins'] as num?)?.toInt(),
      unlockThresholdCoin: (json['unlock_threshold_coin'] as num?)?.toInt(),
      effectiveClassPrice: json['effective_class_price'] as num?,
      willUseTrial: json['will_use_trial'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );

Map<String, dynamic> _$$EligibleChildImplToJson(_$EligibleChildImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_id': instance.parentId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'type': instance.type,
      'age': instance.age,
      'child_age_type': instance.childAgeType,
      'is_eligible': instance.isEligible,
      'has_photo': instance.hasPhoto,
      'reason': instance.reason,
      'is_verified': instance.isVerified,
      'remaining_trials': instance.remainingTrials,
      'paid_coin_accumulator': instance.paidCoinAccumulator,
      'unlock_cycles_granted': instance.unlockCyclesGranted,
      'coins_into_unlock_cycle': instance.coinsIntoUnlockCycle,
      'coins_to_next_unlock': instance.coinsToNextUnlock,
      'next_unlock_at_total_paid_coins': instance.nextUnlockAtTotalPaidCoins,
      'unlock_threshold_coin': instance.unlockThresholdCoin,
      'effective_class_price': instance.effectiveClassPrice,
      'will_use_trial': instance.willUseTrial,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };

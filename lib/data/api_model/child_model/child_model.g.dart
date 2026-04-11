// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChildModelImpl _$$ChildModelImplFromJson(Map<String, dynamic> json) =>
    _$ChildModelImpl(
      id: json['id'] as String?,
      parentId: json['parent_id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      type: json['type'] as String?,
      age: (json['age'] as num?)?.toInt(),
      childAgeType: json['child_age_type'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      isEligible: json['is_eligible'] as bool?,
      isVerified: json['is_verified'] as bool?,
      hasPhoto: json['has_photo'] as bool?,
      reason: json['reason'] as String?,
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
      parent: json['parent'],
    );

Map<String, dynamic> _$$ChildModelImplToJson(_$ChildModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_id': instance.parentId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'dob': instance.dob,
      'gender': instance.gender,
      'type': instance.type,
      'age': instance.age,
      'child_age_type': instance.childAgeType,
      'city': instance.city,
      'district': instance.district,
      'is_eligible': instance.isEligible,
      'is_verified': instance.isVerified,
      'has_photo': instance.hasPhoto,
      'reason': instance.reason,
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
      'parent': instance.parent,
    };

_$ParentTrialSummaryImpl _$$ParentTrialSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$ParentTrialSummaryImpl(
      totalRemainingTrials:
          (json['total_remaining_trials'] as num?)?.toInt() ?? 0,
      unlockThresholdCoin:
          (json['unlock_threshold_coin'] as num?)?.toInt() ?? 700,
      unlockBatchTrials: (json['unlock_batch_trials'] as num?)?.toInt() ?? 3,
      children: (json['children'] as List<dynamic>?)
              ?.map(
                  (e) => TrialSummaryChild.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ParentTrialSummaryImplToJson(
        _$ParentTrialSummaryImpl instance) =>
    <String, dynamic>{
      'total_remaining_trials': instance.totalRemainingTrials,
      'unlock_threshold_coin': instance.unlockThresholdCoin,
      'unlock_batch_trials': instance.unlockBatchTrials,
      'children': instance.children,
    };

_$TrialSummaryChildImpl _$$TrialSummaryChildImplFromJson(
        Map<String, dynamic> json) =>
    _$TrialSummaryChildImpl(
      childId: json['child_id'] as String?,
      remainingTrials: (json['remaining_trials'] as num?)?.toInt(),
      coinsIntoUnlockCycle: (json['coins_into_unlock_cycle'] as num?)?.toInt(),
      coinsToNextUnlock: (json['coins_to_next_unlock'] as num?)?.toInt(),
      nextUnlockAtTotalPaidCoins:
          (json['next_unlock_at_total_paid_coins'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TrialSummaryChildImplToJson(
        _$TrialSummaryChildImpl instance) =>
    <String, dynamic>{
      'child_id': instance.childId,
      'remaining_trials': instance.remainingTrials,
      'coins_into_unlock_cycle': instance.coinsIntoUnlockCycle,
      'coins_to_next_unlock': instance.coinsToNextUnlock,
      'next_unlock_at_total_paid_coins': instance.nextUnlockAtTotalPaidCoins,
    };

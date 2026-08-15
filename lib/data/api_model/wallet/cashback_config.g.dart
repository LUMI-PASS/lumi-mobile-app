// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cashback_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CashbackRuleImpl _$$CashbackRuleImplFromJson(Map<String, dynamic> json) =>
    _$CashbackRuleImpl(
      percent: json['percent'] as num? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      maxCashbackAmount: json['max_cashback_amount'] as num?,
      minOrderAmount: json['min_order_amount'] as num? ?? 0,
    );

Map<String, dynamic> _$$CashbackRuleImplToJson(_$CashbackRuleImpl instance) =>
    <String, dynamic>{
      'percent': instance.percent,
      'is_active': instance.isActive,
      'max_cashback_amount': instance.maxCashbackAmount,
      'min_order_amount': instance.minOrderAmount,
    };

_$CashbackConfigImpl _$$CashbackConfigImplFromJson(Map<String, dynamic> json) =>
    _$CashbackConfigImpl(
      isEnabled: json['is_enabled'] as bool? ?? false,
      maxRedeemPercent: json['max_redeem_percent'] as num? ?? 100,
      currency: json['currency'] as String? ?? 'UZS',
      rules: json['rules'] == null
          ? const CashbackRules()
          : CashbackRules.fromJson(json['rules'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CashbackConfigImplToJson(
        _$CashbackConfigImpl instance) =>
    <String, dynamic>{
      'is_enabled': instance.isEnabled,
      'max_redeem_percent': instance.maxRedeemPercent,
      'currency': instance.currency,
      'rules': instance.rules,
    };

_$CashbackRulesImpl _$$CashbackRulesImplFromJson(Map<String, dynamic> json) =>
    _$CashbackRulesImpl(
      activity: json['activity'] == null
          ? const CashbackRule()
          : CashbackRule.fromJson(json['activity'] as Map<String, dynamic>),
      trialLesson: json['trial_lesson'] == null
          ? const CashbackRule()
          : CashbackRule.fromJson(json['trial_lesson'] as Map<String, dynamic>),
      course: json['course'] == null
          ? const CashbackRule()
          : CashbackRule.fromJson(json['course'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CashbackRulesImplToJson(_$CashbackRulesImpl instance) =>
    <String, dynamic>{
      'activity': instance.activity,
      'trial_lesson': instance.trialLesson,
      'course': instance.course,
    };

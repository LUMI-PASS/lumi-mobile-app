// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cashback_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CashbackRule _$CashbackRuleFromJson(Map<String, dynamic> json) {
  return _CashbackRule.fromJson(json);
}

/// @nodoc
mixin _$CashbackRule {
  num get percent => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  num? get maxCashbackAmount => throw _privateConstructorUsedError;
  num get minOrderAmount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CashbackRuleCopyWith<CashbackRule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashbackRuleCopyWith<$Res> {
  factory $CashbackRuleCopyWith(
          CashbackRule value, $Res Function(CashbackRule) then) =
      _$CashbackRuleCopyWithImpl<$Res, CashbackRule>;
  @useResult
  $Res call(
      {num percent, bool isActive, num? maxCashbackAmount, num minOrderAmount});
}

/// @nodoc
class _$CashbackRuleCopyWithImpl<$Res, $Val extends CashbackRule>
    implements $CashbackRuleCopyWith<$Res> {
  _$CashbackRuleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent = null,
    Object? isActive = null,
    Object? maxCashbackAmount = freezed,
    Object? minOrderAmount = null,
  }) {
    return _then(_value.copyWith(
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as num,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      maxCashbackAmount: freezed == maxCashbackAmount
          ? _value.maxCashbackAmount
          : maxCashbackAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      minOrderAmount: null == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as num,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CashbackRuleImplCopyWith<$Res>
    implements $CashbackRuleCopyWith<$Res> {
  factory _$$CashbackRuleImplCopyWith(
          _$CashbackRuleImpl value, $Res Function(_$CashbackRuleImpl) then) =
      __$$CashbackRuleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {num percent, bool isActive, num? maxCashbackAmount, num minOrderAmount});
}

/// @nodoc
class __$$CashbackRuleImplCopyWithImpl<$Res>
    extends _$CashbackRuleCopyWithImpl<$Res, _$CashbackRuleImpl>
    implements _$$CashbackRuleImplCopyWith<$Res> {
  __$$CashbackRuleImplCopyWithImpl(
      _$CashbackRuleImpl _value, $Res Function(_$CashbackRuleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? percent = null,
    Object? isActive = null,
    Object? maxCashbackAmount = freezed,
    Object? minOrderAmount = null,
  }) {
    return _then(_$CashbackRuleImpl(
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as num,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      maxCashbackAmount: freezed == maxCashbackAmount
          ? _value.maxCashbackAmount
          : maxCashbackAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      minOrderAmount: null == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as num,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$CashbackRuleImpl extends _CashbackRule {
  const _$CashbackRuleImpl(
      {this.percent = 0,
      this.isActive = false,
      this.maxCashbackAmount,
      this.minOrderAmount = 0})
      : super._();

  factory _$CashbackRuleImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashbackRuleImplFromJson(json);

  @override
  @JsonKey()
  final num percent;
  @override
  @JsonKey()
  final bool isActive;
  @override
  final num? maxCashbackAmount;
  @override
  @JsonKey()
  final num minOrderAmount;

  @override
  String toString() {
    return 'CashbackRule(percent: $percent, isActive: $isActive, maxCashbackAmount: $maxCashbackAmount, minOrderAmount: $minOrderAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashbackRuleImpl &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.maxCashbackAmount, maxCashbackAmount) ||
                other.maxCashbackAmount == maxCashbackAmount) &&
            (identical(other.minOrderAmount, minOrderAmount) ||
                other.minOrderAmount == minOrderAmount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, percent, isActive, maxCashbackAmount, minOrderAmount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CashbackRuleImplCopyWith<_$CashbackRuleImpl> get copyWith =>
      __$$CashbackRuleImplCopyWithImpl<_$CashbackRuleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashbackRuleImplToJson(
      this,
    );
  }
}

abstract class _CashbackRule extends CashbackRule {
  const factory _CashbackRule(
      {final num percent,
      final bool isActive,
      final num? maxCashbackAmount,
      final num minOrderAmount}) = _$CashbackRuleImpl;
  const _CashbackRule._() : super._();

  factory _CashbackRule.fromJson(Map<String, dynamic> json) =
      _$CashbackRuleImpl.fromJson;

  @override
  num get percent;
  @override
  bool get isActive;
  @override
  num? get maxCashbackAmount;
  @override
  num get minOrderAmount;
  @override
  @JsonKey(ignore: true)
  _$$CashbackRuleImplCopyWith<_$CashbackRuleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CashbackConfig _$CashbackConfigFromJson(Map<String, dynamic> json) {
  return _CashbackConfig.fromJson(json);
}

/// @nodoc
mixin _$CashbackConfig {
  bool get isEnabled => throw _privateConstructorUsedError;
  num get maxRedeemPercent => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  CashbackRules get rules => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CashbackConfigCopyWith<CashbackConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashbackConfigCopyWith<$Res> {
  factory $CashbackConfigCopyWith(
          CashbackConfig value, $Res Function(CashbackConfig) then) =
      _$CashbackConfigCopyWithImpl<$Res, CashbackConfig>;
  @useResult
  $Res call(
      {bool isEnabled,
      num maxRedeemPercent,
      String currency,
      CashbackRules rules});

  $CashbackRulesCopyWith<$Res> get rules;
}

/// @nodoc
class _$CashbackConfigCopyWithImpl<$Res, $Val extends CashbackConfig>
    implements $CashbackConfigCopyWith<$Res> {
  _$CashbackConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? maxRedeemPercent = null,
    Object? currency = null,
    Object? rules = null,
  }) {
    return _then(_value.copyWith(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRedeemPercent: null == maxRedeemPercent
          ? _value.maxRedeemPercent
          : maxRedeemPercent // ignore: cast_nullable_to_non_nullable
              as num,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      rules: null == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as CashbackRules,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CashbackRulesCopyWith<$Res> get rules {
    return $CashbackRulesCopyWith<$Res>(_value.rules, (value) {
      return _then(_value.copyWith(rules: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CashbackConfigImplCopyWith<$Res>
    implements $CashbackConfigCopyWith<$Res> {
  factory _$$CashbackConfigImplCopyWith(_$CashbackConfigImpl value,
          $Res Function(_$CashbackConfigImpl) then) =
      __$$CashbackConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isEnabled,
      num maxRedeemPercent,
      String currency,
      CashbackRules rules});

  @override
  $CashbackRulesCopyWith<$Res> get rules;
}

/// @nodoc
class __$$CashbackConfigImplCopyWithImpl<$Res>
    extends _$CashbackConfigCopyWithImpl<$Res, _$CashbackConfigImpl>
    implements _$$CashbackConfigImplCopyWith<$Res> {
  __$$CashbackConfigImplCopyWithImpl(
      _$CashbackConfigImpl _value, $Res Function(_$CashbackConfigImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isEnabled = null,
    Object? maxRedeemPercent = null,
    Object? currency = null,
    Object? rules = null,
  }) {
    return _then(_$CashbackConfigImpl(
      isEnabled: null == isEnabled
          ? _value.isEnabled
          : isEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      maxRedeemPercent: null == maxRedeemPercent
          ? _value.maxRedeemPercent
          : maxRedeemPercent // ignore: cast_nullable_to_non_nullable
              as num,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      rules: null == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as CashbackRules,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$CashbackConfigImpl extends _CashbackConfig {
  const _$CashbackConfigImpl(
      {this.isEnabled = false,
      this.maxRedeemPercent = 100,
      this.currency = 'UZS',
      this.rules = const CashbackRules()})
      : super._();

  factory _$CashbackConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashbackConfigImplFromJson(json);

  @override
  @JsonKey()
  final bool isEnabled;
  @override
  @JsonKey()
  final num maxRedeemPercent;
  @override
  @JsonKey()
  final String currency;
  @override
  @JsonKey()
  final CashbackRules rules;

  @override
  String toString() {
    return 'CashbackConfig(isEnabled: $isEnabled, maxRedeemPercent: $maxRedeemPercent, currency: $currency, rules: $rules)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashbackConfigImpl &&
            (identical(other.isEnabled, isEnabled) ||
                other.isEnabled == isEnabled) &&
            (identical(other.maxRedeemPercent, maxRedeemPercent) ||
                other.maxRedeemPercent == maxRedeemPercent) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.rules, rules) || other.rules == rules));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, isEnabled, maxRedeemPercent, currency, rules);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CashbackConfigImplCopyWith<_$CashbackConfigImpl> get copyWith =>
      __$$CashbackConfigImplCopyWithImpl<_$CashbackConfigImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashbackConfigImplToJson(
      this,
    );
  }
}

abstract class _CashbackConfig extends CashbackConfig {
  const factory _CashbackConfig(
      {final bool isEnabled,
      final num maxRedeemPercent,
      final String currency,
      final CashbackRules rules}) = _$CashbackConfigImpl;
  const _CashbackConfig._() : super._();

  factory _CashbackConfig.fromJson(Map<String, dynamic> json) =
      _$CashbackConfigImpl.fromJson;

  @override
  bool get isEnabled;
  @override
  num get maxRedeemPercent;
  @override
  String get currency;
  @override
  CashbackRules get rules;
  @override
  @JsonKey(ignore: true)
  _$$CashbackConfigImplCopyWith<_$CashbackConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CashbackRules _$CashbackRulesFromJson(Map<String, dynamic> json) {
  return _CashbackRules.fromJson(json);
}

/// @nodoc
mixin _$CashbackRules {
  CashbackRule get activity => throw _privateConstructorUsedError;
  CashbackRule get trialLesson => throw _privateConstructorUsedError;
  CashbackRule get course => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CashbackRulesCopyWith<CashbackRules> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashbackRulesCopyWith<$Res> {
  factory $CashbackRulesCopyWith(
          CashbackRules value, $Res Function(CashbackRules) then) =
      _$CashbackRulesCopyWithImpl<$Res, CashbackRules>;
  @useResult
  $Res call(
      {CashbackRule activity, CashbackRule trialLesson, CashbackRule course});

  $CashbackRuleCopyWith<$Res> get activity;
  $CashbackRuleCopyWith<$Res> get trialLesson;
  $CashbackRuleCopyWith<$Res> get course;
}

/// @nodoc
class _$CashbackRulesCopyWithImpl<$Res, $Val extends CashbackRules>
    implements $CashbackRulesCopyWith<$Res> {
  _$CashbackRulesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activity = null,
    Object? trialLesson = null,
    Object? course = null,
  }) {
    return _then(_value.copyWith(
      activity: null == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as CashbackRule,
      trialLesson: null == trialLesson
          ? _value.trialLesson
          : trialLesson // ignore: cast_nullable_to_non_nullable
              as CashbackRule,
      course: null == course
          ? _value.course
          : course // ignore: cast_nullable_to_non_nullable
              as CashbackRule,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $CashbackRuleCopyWith<$Res> get activity {
    return $CashbackRuleCopyWith<$Res>(_value.activity, (value) {
      return _then(_value.copyWith(activity: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CashbackRuleCopyWith<$Res> get trialLesson {
    return $CashbackRuleCopyWith<$Res>(_value.trialLesson, (value) {
      return _then(_value.copyWith(trialLesson: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CashbackRuleCopyWith<$Res> get course {
    return $CashbackRuleCopyWith<$Res>(_value.course, (value) {
      return _then(_value.copyWith(course: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CashbackRulesImplCopyWith<$Res>
    implements $CashbackRulesCopyWith<$Res> {
  factory _$$CashbackRulesImplCopyWith(
          _$CashbackRulesImpl value, $Res Function(_$CashbackRulesImpl) then) =
      __$$CashbackRulesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CashbackRule activity, CashbackRule trialLesson, CashbackRule course});

  @override
  $CashbackRuleCopyWith<$Res> get activity;
  @override
  $CashbackRuleCopyWith<$Res> get trialLesson;
  @override
  $CashbackRuleCopyWith<$Res> get course;
}

/// @nodoc
class __$$CashbackRulesImplCopyWithImpl<$Res>
    extends _$CashbackRulesCopyWithImpl<$Res, _$CashbackRulesImpl>
    implements _$$CashbackRulesImplCopyWith<$Res> {
  __$$CashbackRulesImplCopyWithImpl(
      _$CashbackRulesImpl _value, $Res Function(_$CashbackRulesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activity = null,
    Object? trialLesson = null,
    Object? course = null,
  }) {
    return _then(_$CashbackRulesImpl(
      activity: null == activity
          ? _value.activity
          : activity // ignore: cast_nullable_to_non_nullable
              as CashbackRule,
      trialLesson: null == trialLesson
          ? _value.trialLesson
          : trialLesson // ignore: cast_nullable_to_non_nullable
              as CashbackRule,
      course: null == course
          ? _value.course
          : course // ignore: cast_nullable_to_non_nullable
              as CashbackRule,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$CashbackRulesImpl implements _CashbackRules {
  const _$CashbackRulesImpl(
      {this.activity = const CashbackRule(),
      this.trialLesson = const CashbackRule(),
      this.course = const CashbackRule()});

  factory _$CashbackRulesImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashbackRulesImplFromJson(json);

  @override
  @JsonKey()
  final CashbackRule activity;
  @override
  @JsonKey()
  final CashbackRule trialLesson;
  @override
  @JsonKey()
  final CashbackRule course;

  @override
  String toString() {
    return 'CashbackRules(activity: $activity, trialLesson: $trialLesson, course: $course)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashbackRulesImpl &&
            (identical(other.activity, activity) ||
                other.activity == activity) &&
            (identical(other.trialLesson, trialLesson) ||
                other.trialLesson == trialLesson) &&
            (identical(other.course, course) || other.course == course));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, activity, trialLesson, course);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CashbackRulesImplCopyWith<_$CashbackRulesImpl> get copyWith =>
      __$$CashbackRulesImplCopyWithImpl<_$CashbackRulesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashbackRulesImplToJson(
      this,
    );
  }
}

abstract class _CashbackRules implements CashbackRules {
  const factory _CashbackRules(
      {final CashbackRule activity,
      final CashbackRule trialLesson,
      final CashbackRule course}) = _$CashbackRulesImpl;

  factory _CashbackRules.fromJson(Map<String, dynamic> json) =
      _$CashbackRulesImpl.fromJson;

  @override
  CashbackRule get activity;
  @override
  CashbackRule get trialLesson;
  @override
  CashbackRule get course;
  @override
  @JsonKey(ignore: true)
  _$$CashbackRulesImplCopyWith<_$CashbackRulesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

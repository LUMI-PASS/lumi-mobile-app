// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'eligibility_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClassEligibilityData _$ClassEligibilityDataFromJson(Map<String, dynamic> json) {
  return _ClassEligibilityData.fromJson(json);
}

/// @nodoc
mixin _$ClassEligibilityData {
  String? get classId => throw _privateConstructorUsedError;
  String? get classTitle => throw _privateConstructorUsedError;
  num? get classPrice => throw _privateConstructorUsedError;
  num? get classTrialPrice => throw _privateConstructorUsedError;
  bool? get classTrialEnabled => throw _privateConstructorUsedError;
  int? get minAge => throw _privateConstructorUsedError;
  int? get maxAge => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  bool? get isBalanceEnough => throw _privateConstructorUsedError;
  bool? get isBalanceEnoughForTrialPrice => throw _privateConstructorUsedError;
  num get walletBalance => throw _privateConstructorUsedError;
  int? get trialUnlockThresholdCoin => throw _privateConstructorUsedError;
  int? get trialUnlockBatchLessonsPerUnlock =>
      throw _privateConstructorUsedError;
  List<EligibleChild> get children => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ClassEligibilityDataCopyWith<ClassEligibilityData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClassEligibilityDataCopyWith<$Res> {
  factory $ClassEligibilityDataCopyWith(ClassEligibilityData value,
          $Res Function(ClassEligibilityData) then) =
      _$ClassEligibilityDataCopyWithImpl<$Res, ClassEligibilityData>;
  @useResult
  $Res call(
      {String? classId,
      String? classTitle,
      num? classPrice,
      num? classTrialPrice,
      bool? classTrialEnabled,
      int? minAge,
      int? maxAge,
      String? gender,
      bool? isBalanceEnough,
      bool? isBalanceEnoughForTrialPrice,
      num walletBalance,
      int? trialUnlockThresholdCoin,
      int? trialUnlockBatchLessonsPerUnlock,
      List<EligibleChild> children});
}

/// @nodoc
class _$ClassEligibilityDataCopyWithImpl<$Res,
        $Val extends ClassEligibilityData>
    implements $ClassEligibilityDataCopyWith<$Res> {
  _$ClassEligibilityDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = freezed,
    Object? classTitle = freezed,
    Object? classPrice = freezed,
    Object? classTrialPrice = freezed,
    Object? classTrialEnabled = freezed,
    Object? minAge = freezed,
    Object? maxAge = freezed,
    Object? gender = freezed,
    Object? isBalanceEnough = freezed,
    Object? isBalanceEnoughForTrialPrice = freezed,
    Object? walletBalance = null,
    Object? trialUnlockThresholdCoin = freezed,
    Object? trialUnlockBatchLessonsPerUnlock = freezed,
    Object? children = null,
  }) {
    return _then(_value.copyWith(
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String?,
      classTitle: freezed == classTitle
          ? _value.classTitle
          : classTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      classPrice: freezed == classPrice
          ? _value.classPrice
          : classPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      classTrialPrice: freezed == classTrialPrice
          ? _value.classTrialPrice
          : classTrialPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      classTrialEnabled: freezed == classTrialEnabled
          ? _value.classTrialEnabled
          : classTrialEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      minAge: freezed == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int?,
      maxAge: freezed == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isBalanceEnough: freezed == isBalanceEnough
          ? _value.isBalanceEnough
          : isBalanceEnough // ignore: cast_nullable_to_non_nullable
              as bool?,
      isBalanceEnoughForTrialPrice: freezed == isBalanceEnoughForTrialPrice
          ? _value.isBalanceEnoughForTrialPrice
          : isBalanceEnoughForTrialPrice // ignore: cast_nullable_to_non_nullable
              as bool?,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as num,
      trialUnlockThresholdCoin: freezed == trialUnlockThresholdCoin
          ? _value.trialUnlockThresholdCoin
          : trialUnlockThresholdCoin // ignore: cast_nullable_to_non_nullable
              as int?,
      trialUnlockBatchLessonsPerUnlock: freezed ==
              trialUnlockBatchLessonsPerUnlock
          ? _value.trialUnlockBatchLessonsPerUnlock
          : trialUnlockBatchLessonsPerUnlock // ignore: cast_nullable_to_non_nullable
              as int?,
      children: null == children
          ? _value.children
          : children // ignore: cast_nullable_to_non_nullable
              as List<EligibleChild>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClassEligibilityDataImplCopyWith<$Res>
    implements $ClassEligibilityDataCopyWith<$Res> {
  factory _$$ClassEligibilityDataImplCopyWith(_$ClassEligibilityDataImpl value,
          $Res Function(_$ClassEligibilityDataImpl) then) =
      __$$ClassEligibilityDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? classId,
      String? classTitle,
      num? classPrice,
      num? classTrialPrice,
      bool? classTrialEnabled,
      int? minAge,
      int? maxAge,
      String? gender,
      bool? isBalanceEnough,
      bool? isBalanceEnoughForTrialPrice,
      num walletBalance,
      int? trialUnlockThresholdCoin,
      int? trialUnlockBatchLessonsPerUnlock,
      List<EligibleChild> children});
}

/// @nodoc
class __$$ClassEligibilityDataImplCopyWithImpl<$Res>
    extends _$ClassEligibilityDataCopyWithImpl<$Res, _$ClassEligibilityDataImpl>
    implements _$$ClassEligibilityDataImplCopyWith<$Res> {
  __$$ClassEligibilityDataImplCopyWithImpl(_$ClassEligibilityDataImpl _value,
      $Res Function(_$ClassEligibilityDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = freezed,
    Object? classTitle = freezed,
    Object? classPrice = freezed,
    Object? classTrialPrice = freezed,
    Object? classTrialEnabled = freezed,
    Object? minAge = freezed,
    Object? maxAge = freezed,
    Object? gender = freezed,
    Object? isBalanceEnough = freezed,
    Object? isBalanceEnoughForTrialPrice = freezed,
    Object? walletBalance = null,
    Object? trialUnlockThresholdCoin = freezed,
    Object? trialUnlockBatchLessonsPerUnlock = freezed,
    Object? children = null,
  }) {
    return _then(_$ClassEligibilityDataImpl(
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String?,
      classTitle: freezed == classTitle
          ? _value.classTitle
          : classTitle // ignore: cast_nullable_to_non_nullable
              as String?,
      classPrice: freezed == classPrice
          ? _value.classPrice
          : classPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      classTrialPrice: freezed == classTrialPrice
          ? _value.classTrialPrice
          : classTrialPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      classTrialEnabled: freezed == classTrialEnabled
          ? _value.classTrialEnabled
          : classTrialEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      minAge: freezed == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int?,
      maxAge: freezed == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isBalanceEnough: freezed == isBalanceEnough
          ? _value.isBalanceEnough
          : isBalanceEnough // ignore: cast_nullable_to_non_nullable
              as bool?,
      isBalanceEnoughForTrialPrice: freezed == isBalanceEnoughForTrialPrice
          ? _value.isBalanceEnoughForTrialPrice
          : isBalanceEnoughForTrialPrice // ignore: cast_nullable_to_non_nullable
              as bool?,
      walletBalance: null == walletBalance
          ? _value.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as num,
      trialUnlockThresholdCoin: freezed == trialUnlockThresholdCoin
          ? _value.trialUnlockThresholdCoin
          : trialUnlockThresholdCoin // ignore: cast_nullable_to_non_nullable
              as int?,
      trialUnlockBatchLessonsPerUnlock: freezed ==
              trialUnlockBatchLessonsPerUnlock
          ? _value.trialUnlockBatchLessonsPerUnlock
          : trialUnlockBatchLessonsPerUnlock // ignore: cast_nullable_to_non_nullable
              as int?,
      children: null == children
          ? _value._children
          : children // ignore: cast_nullable_to_non_nullable
              as List<EligibleChild>,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ClassEligibilityDataImpl implements _ClassEligibilityData {
  const _$ClassEligibilityDataImpl(
      {this.classId,
      this.classTitle,
      this.classPrice,
      this.classTrialPrice,
      this.classTrialEnabled,
      this.minAge,
      this.maxAge,
      this.gender,
      this.isBalanceEnough,
      this.isBalanceEnoughForTrialPrice,
      this.walletBalance = 0,
      this.trialUnlockThresholdCoin,
      this.trialUnlockBatchLessonsPerUnlock,
      final List<EligibleChild> children = const []})
      : _children = children;

  factory _$ClassEligibilityDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClassEligibilityDataImplFromJson(json);

  @override
  final String? classId;
  @override
  final String? classTitle;
  @override
  final num? classPrice;
  @override
  final num? classTrialPrice;
  @override
  final bool? classTrialEnabled;
  @override
  final int? minAge;
  @override
  final int? maxAge;
  @override
  final String? gender;
  @override
  final bool? isBalanceEnough;
  @override
  final bool? isBalanceEnoughForTrialPrice;
  @override
  @JsonKey()
  final num walletBalance;
  @override
  final int? trialUnlockThresholdCoin;
  @override
  final int? trialUnlockBatchLessonsPerUnlock;
  final List<EligibleChild> _children;
  @override
  @JsonKey()
  List<EligibleChild> get children {
    if (_children is EqualUnmodifiableListView) return _children;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_children);
  }

  @override
  String toString() {
    return 'ClassEligibilityData(classId: $classId, classTitle: $classTitle, classPrice: $classPrice, classTrialPrice: $classTrialPrice, classTrialEnabled: $classTrialEnabled, minAge: $minAge, maxAge: $maxAge, gender: $gender, isBalanceEnough: $isBalanceEnough, isBalanceEnoughForTrialPrice: $isBalanceEnoughForTrialPrice, walletBalance: $walletBalance, trialUnlockThresholdCoin: $trialUnlockThresholdCoin, trialUnlockBatchLessonsPerUnlock: $trialUnlockBatchLessonsPerUnlock, children: $children)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClassEligibilityDataImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.classTitle, classTitle) ||
                other.classTitle == classTitle) &&
            (identical(other.classPrice, classPrice) ||
                other.classPrice == classPrice) &&
            (identical(other.classTrialPrice, classTrialPrice) ||
                other.classTrialPrice == classTrialPrice) &&
            (identical(other.classTrialEnabled, classTrialEnabled) ||
                other.classTrialEnabled == classTrialEnabled) &&
            (identical(other.minAge, minAge) || other.minAge == minAge) &&
            (identical(other.maxAge, maxAge) || other.maxAge == maxAge) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isBalanceEnough, isBalanceEnough) ||
                other.isBalanceEnough == isBalanceEnough) &&
            (identical(other.isBalanceEnoughForTrialPrice,
                    isBalanceEnoughForTrialPrice) ||
                other.isBalanceEnoughForTrialPrice ==
                    isBalanceEnoughForTrialPrice) &&
            (identical(other.walletBalance, walletBalance) ||
                other.walletBalance == walletBalance) &&
            (identical(
                    other.trialUnlockThresholdCoin, trialUnlockThresholdCoin) ||
                other.trialUnlockThresholdCoin == trialUnlockThresholdCoin) &&
            (identical(other.trialUnlockBatchLessonsPerUnlock,
                    trialUnlockBatchLessonsPerUnlock) ||
                other.trialUnlockBatchLessonsPerUnlock ==
                    trialUnlockBatchLessonsPerUnlock) &&
            const DeepCollectionEquality().equals(other._children, _children));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      classId,
      classTitle,
      classPrice,
      classTrialPrice,
      classTrialEnabled,
      minAge,
      maxAge,
      gender,
      isBalanceEnough,
      isBalanceEnoughForTrialPrice,
      walletBalance,
      trialUnlockThresholdCoin,
      trialUnlockBatchLessonsPerUnlock,
      const DeepCollectionEquality().hash(_children));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ClassEligibilityDataImplCopyWith<_$ClassEligibilityDataImpl>
      get copyWith =>
          __$$ClassEligibilityDataImplCopyWithImpl<_$ClassEligibilityDataImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClassEligibilityDataImplToJson(
      this,
    );
  }
}

abstract class _ClassEligibilityData implements ClassEligibilityData {
  const factory _ClassEligibilityData(
      {final String? classId,
      final String? classTitle,
      final num? classPrice,
      final num? classTrialPrice,
      final bool? classTrialEnabled,
      final int? minAge,
      final int? maxAge,
      final String? gender,
      final bool? isBalanceEnough,
      final bool? isBalanceEnoughForTrialPrice,
      final num walletBalance,
      final int? trialUnlockThresholdCoin,
      final int? trialUnlockBatchLessonsPerUnlock,
      final List<EligibleChild> children}) = _$ClassEligibilityDataImpl;

  factory _ClassEligibilityData.fromJson(Map<String, dynamic> json) =
      _$ClassEligibilityDataImpl.fromJson;

  @override
  String? get classId;
  @override
  String? get classTitle;
  @override
  num? get classPrice;
  @override
  num? get classTrialPrice;
  @override
  bool? get classTrialEnabled;
  @override
  int? get minAge;
  @override
  int? get maxAge;
  @override
  String? get gender;
  @override
  bool? get isBalanceEnough;
  @override
  bool? get isBalanceEnoughForTrialPrice;
  @override
  num get walletBalance;
  @override
  int? get trialUnlockThresholdCoin;
  @override
  int? get trialUnlockBatchLessonsPerUnlock;
  @override
  List<EligibleChild> get children;
  @override
  @JsonKey(ignore: true)
  _$$ClassEligibilityDataImplCopyWith<_$ClassEligibilityDataImpl>
      get copyWith => throw _privateConstructorUsedError;
}

EligibleChild _$EligibleChildFromJson(Map<String, dynamic> json) {
  return _EligibleChild.fromJson(json);
}

/// @nodoc
mixin _$EligibleChild {
  String? get id => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get childAgeType => throw _privateConstructorUsedError;
  bool get isEligible => throw _privateConstructorUsedError;
  bool? get hasPhoto => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;
  bool? get isVerified => throw _privateConstructorUsedError;
  int? get remainingTrials => throw _privateConstructorUsedError;
  int? get paidCoinAccumulator => throw _privateConstructorUsedError;
  int? get unlockCyclesGranted => throw _privateConstructorUsedError;
  int? get coinsIntoUnlockCycle => throw _privateConstructorUsedError;
  int? get coinsToNextUnlock => throw _privateConstructorUsedError;
  int? get nextUnlockAtTotalPaidCoins => throw _privateConstructorUsedError;
  int? get unlockThresholdCoin => throw _privateConstructorUsedError;
  num? get effectiveClassPrice => throw _privateConstructorUsedError;
  bool? get willUseTrial => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get deletedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EligibleChildCopyWith<EligibleChild> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EligibleChildCopyWith<$Res> {
  factory $EligibleChildCopyWith(
          EligibleChild value, $Res Function(EligibleChild) then) =
      _$EligibleChildCopyWithImpl<$Res, EligibleChild>;
  @useResult
  $Res call(
      {String? id,
      String? parentId,
      String? firstName,
      String? lastName,
      String? type,
      int? age,
      String? childAgeType,
      bool isEligible,
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
      String? deletedAt});
}

/// @nodoc
class _$EligibleChildCopyWithImpl<$Res, $Val extends EligibleChild>
    implements $EligibleChildCopyWith<$Res> {
  _$EligibleChildCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? parentId = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? type = freezed,
    Object? age = freezed,
    Object? childAgeType = freezed,
    Object? isEligible = null,
    Object? hasPhoto = freezed,
    Object? reason = freezed,
    Object? isVerified = freezed,
    Object? remainingTrials = freezed,
    Object? paidCoinAccumulator = freezed,
    Object? unlockCyclesGranted = freezed,
    Object? coinsIntoUnlockCycle = freezed,
    Object? coinsToNextUnlock = freezed,
    Object? nextUnlockAtTotalPaidCoins = freezed,
    Object? unlockThresholdCoin = freezed,
    Object? effectiveClassPrice = freezed,
    Object? willUseTrial = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      childAgeType: freezed == childAgeType
          ? _value.childAgeType
          : childAgeType // ignore: cast_nullable_to_non_nullable
              as String?,
      isEligible: null == isEligible
          ? _value.isEligible
          : isEligible // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      remainingTrials: freezed == remainingTrials
          ? _value.remainingTrials
          : remainingTrials // ignore: cast_nullable_to_non_nullable
              as int?,
      paidCoinAccumulator: freezed == paidCoinAccumulator
          ? _value.paidCoinAccumulator
          : paidCoinAccumulator // ignore: cast_nullable_to_non_nullable
              as int?,
      unlockCyclesGranted: freezed == unlockCyclesGranted
          ? _value.unlockCyclesGranted
          : unlockCyclesGranted // ignore: cast_nullable_to_non_nullable
              as int?,
      coinsIntoUnlockCycle: freezed == coinsIntoUnlockCycle
          ? _value.coinsIntoUnlockCycle
          : coinsIntoUnlockCycle // ignore: cast_nullable_to_non_nullable
              as int?,
      coinsToNextUnlock: freezed == coinsToNextUnlock
          ? _value.coinsToNextUnlock
          : coinsToNextUnlock // ignore: cast_nullable_to_non_nullable
              as int?,
      nextUnlockAtTotalPaidCoins: freezed == nextUnlockAtTotalPaidCoins
          ? _value.nextUnlockAtTotalPaidCoins
          : nextUnlockAtTotalPaidCoins // ignore: cast_nullable_to_non_nullable
              as int?,
      unlockThresholdCoin: freezed == unlockThresholdCoin
          ? _value.unlockThresholdCoin
          : unlockThresholdCoin // ignore: cast_nullable_to_non_nullable
              as int?,
      effectiveClassPrice: freezed == effectiveClassPrice
          ? _value.effectiveClassPrice
          : effectiveClassPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      willUseTrial: freezed == willUseTrial
          ? _value.willUseTrial
          : willUseTrial // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EligibleChildImplCopyWith<$Res>
    implements $EligibleChildCopyWith<$Res> {
  factory _$$EligibleChildImplCopyWith(
          _$EligibleChildImpl value, $Res Function(_$EligibleChildImpl) then) =
      __$$EligibleChildImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? parentId,
      String? firstName,
      String? lastName,
      String? type,
      int? age,
      String? childAgeType,
      bool isEligible,
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
      String? deletedAt});
}

/// @nodoc
class __$$EligibleChildImplCopyWithImpl<$Res>
    extends _$EligibleChildCopyWithImpl<$Res, _$EligibleChildImpl>
    implements _$$EligibleChildImplCopyWith<$Res> {
  __$$EligibleChildImplCopyWithImpl(
      _$EligibleChildImpl _value, $Res Function(_$EligibleChildImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? parentId = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? type = freezed,
    Object? age = freezed,
    Object? childAgeType = freezed,
    Object? isEligible = null,
    Object? hasPhoto = freezed,
    Object? reason = freezed,
    Object? isVerified = freezed,
    Object? remainingTrials = freezed,
    Object? paidCoinAccumulator = freezed,
    Object? unlockCyclesGranted = freezed,
    Object? coinsIntoUnlockCycle = freezed,
    Object? coinsToNextUnlock = freezed,
    Object? nextUnlockAtTotalPaidCoins = freezed,
    Object? unlockThresholdCoin = freezed,
    Object? effectiveClassPrice = freezed,
    Object? willUseTrial = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_$EligibleChildImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      childAgeType: freezed == childAgeType
          ? _value.childAgeType
          : childAgeType // ignore: cast_nullable_to_non_nullable
              as String?,
      isEligible: null == isEligible
          ? _value.isEligible
          : isEligible // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      reason: freezed == reason
          ? _value.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      remainingTrials: freezed == remainingTrials
          ? _value.remainingTrials
          : remainingTrials // ignore: cast_nullable_to_non_nullable
              as int?,
      paidCoinAccumulator: freezed == paidCoinAccumulator
          ? _value.paidCoinAccumulator
          : paidCoinAccumulator // ignore: cast_nullable_to_non_nullable
              as int?,
      unlockCyclesGranted: freezed == unlockCyclesGranted
          ? _value.unlockCyclesGranted
          : unlockCyclesGranted // ignore: cast_nullable_to_non_nullable
              as int?,
      coinsIntoUnlockCycle: freezed == coinsIntoUnlockCycle
          ? _value.coinsIntoUnlockCycle
          : coinsIntoUnlockCycle // ignore: cast_nullable_to_non_nullable
              as int?,
      coinsToNextUnlock: freezed == coinsToNextUnlock
          ? _value.coinsToNextUnlock
          : coinsToNextUnlock // ignore: cast_nullable_to_non_nullable
              as int?,
      nextUnlockAtTotalPaidCoins: freezed == nextUnlockAtTotalPaidCoins
          ? _value.nextUnlockAtTotalPaidCoins
          : nextUnlockAtTotalPaidCoins // ignore: cast_nullable_to_non_nullable
              as int?,
      unlockThresholdCoin: freezed == unlockThresholdCoin
          ? _value.unlockThresholdCoin
          : unlockThresholdCoin // ignore: cast_nullable_to_non_nullable
              as int?,
      effectiveClassPrice: freezed == effectiveClassPrice
          ? _value.effectiveClassPrice
          : effectiveClassPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      willUseTrial: freezed == willUseTrial
          ? _value.willUseTrial
          : willUseTrial // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$EligibleChildImpl implements _EligibleChild {
  const _$EligibleChildImpl(
      {this.id,
      this.parentId,
      this.firstName,
      this.lastName,
      this.type,
      this.age,
      this.childAgeType,
      this.isEligible = false,
      this.hasPhoto,
      this.reason,
      this.isVerified,
      this.remainingTrials,
      this.paidCoinAccumulator,
      this.unlockCyclesGranted,
      this.coinsIntoUnlockCycle,
      this.coinsToNextUnlock,
      this.nextUnlockAtTotalPaidCoins,
      this.unlockThresholdCoin,
      this.effectiveClassPrice,
      this.willUseTrial,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  factory _$EligibleChildImpl.fromJson(Map<String, dynamic> json) =>
      _$$EligibleChildImplFromJson(json);

  @override
  final String? id;
  @override
  final String? parentId;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? type;
  @override
  final int? age;
  @override
  final String? childAgeType;
  @override
  @JsonKey()
  final bool isEligible;
  @override
  final bool? hasPhoto;
  @override
  final String? reason;
  @override
  final bool? isVerified;
  @override
  final int? remainingTrials;
  @override
  final int? paidCoinAccumulator;
  @override
  final int? unlockCyclesGranted;
  @override
  final int? coinsIntoUnlockCycle;
  @override
  final int? coinsToNextUnlock;
  @override
  final int? nextUnlockAtTotalPaidCoins;
  @override
  final int? unlockThresholdCoin;
  @override
  final num? effectiveClassPrice;
  @override
  final bool? willUseTrial;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final String? deletedAt;

  @override
  String toString() {
    return 'EligibleChild(id: $id, parentId: $parentId, firstName: $firstName, lastName: $lastName, type: $type, age: $age, childAgeType: $childAgeType, isEligible: $isEligible, hasPhoto: $hasPhoto, reason: $reason, isVerified: $isVerified, remainingTrials: $remainingTrials, paidCoinAccumulator: $paidCoinAccumulator, unlockCyclesGranted: $unlockCyclesGranted, coinsIntoUnlockCycle: $coinsIntoUnlockCycle, coinsToNextUnlock: $coinsToNextUnlock, nextUnlockAtTotalPaidCoins: $nextUnlockAtTotalPaidCoins, unlockThresholdCoin: $unlockThresholdCoin, effectiveClassPrice: $effectiveClassPrice, willUseTrial: $willUseTrial, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EligibleChildImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.childAgeType, childAgeType) ||
                other.childAgeType == childAgeType) &&
            (identical(other.isEligible, isEligible) ||
                other.isEligible == isEligible) &&
            (identical(other.hasPhoto, hasPhoto) ||
                other.hasPhoto == hasPhoto) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.remainingTrials, remainingTrials) ||
                other.remainingTrials == remainingTrials) &&
            (identical(other.paidCoinAccumulator, paidCoinAccumulator) ||
                other.paidCoinAccumulator == paidCoinAccumulator) &&
            (identical(other.unlockCyclesGranted, unlockCyclesGranted) ||
                other.unlockCyclesGranted == unlockCyclesGranted) &&
            (identical(other.coinsIntoUnlockCycle, coinsIntoUnlockCycle) ||
                other.coinsIntoUnlockCycle == coinsIntoUnlockCycle) &&
            (identical(other.coinsToNextUnlock, coinsToNextUnlock) ||
                other.coinsToNextUnlock == coinsToNextUnlock) &&
            (identical(other.nextUnlockAtTotalPaidCoins,
                    nextUnlockAtTotalPaidCoins) ||
                other.nextUnlockAtTotalPaidCoins ==
                    nextUnlockAtTotalPaidCoins) &&
            (identical(other.unlockThresholdCoin, unlockThresholdCoin) ||
                other.unlockThresholdCoin == unlockThresholdCoin) &&
            (identical(other.effectiveClassPrice, effectiveClassPrice) ||
                other.effectiveClassPrice == effectiveClassPrice) &&
            (identical(other.willUseTrial, willUseTrial) ||
                other.willUseTrial == willUseTrial) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        parentId,
        firstName,
        lastName,
        type,
        age,
        childAgeType,
        isEligible,
        hasPhoto,
        reason,
        isVerified,
        remainingTrials,
        paidCoinAccumulator,
        unlockCyclesGranted,
        coinsIntoUnlockCycle,
        coinsToNextUnlock,
        nextUnlockAtTotalPaidCoins,
        unlockThresholdCoin,
        effectiveClassPrice,
        willUseTrial,
        createdAt,
        updatedAt,
        deletedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EligibleChildImplCopyWith<_$EligibleChildImpl> get copyWith =>
      __$$EligibleChildImplCopyWithImpl<_$EligibleChildImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EligibleChildImplToJson(
      this,
    );
  }
}

abstract class _EligibleChild implements EligibleChild {
  const factory _EligibleChild(
      {final String? id,
      final String? parentId,
      final String? firstName,
      final String? lastName,
      final String? type,
      final int? age,
      final String? childAgeType,
      final bool isEligible,
      final bool? hasPhoto,
      final String? reason,
      final bool? isVerified,
      final int? remainingTrials,
      final int? paidCoinAccumulator,
      final int? unlockCyclesGranted,
      final int? coinsIntoUnlockCycle,
      final int? coinsToNextUnlock,
      final int? nextUnlockAtTotalPaidCoins,
      final int? unlockThresholdCoin,
      final num? effectiveClassPrice,
      final bool? willUseTrial,
      final String? createdAt,
      final String? updatedAt,
      final String? deletedAt}) = _$EligibleChildImpl;

  factory _EligibleChild.fromJson(Map<String, dynamic> json) =
      _$EligibleChildImpl.fromJson;

  @override
  String? get id;
  @override
  String? get parentId;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get type;
  @override
  int? get age;
  @override
  String? get childAgeType;
  @override
  bool get isEligible;
  @override
  bool? get hasPhoto;
  @override
  String? get reason;
  @override
  bool? get isVerified;
  @override
  int? get remainingTrials;
  @override
  int? get paidCoinAccumulator;
  @override
  int? get unlockCyclesGranted;
  @override
  int? get coinsIntoUnlockCycle;
  @override
  int? get coinsToNextUnlock;
  @override
  int? get nextUnlockAtTotalPaidCoins;
  @override
  int? get unlockThresholdCoin;
  @override
  num? get effectiveClassPrice;
  @override
  bool? get willUseTrial;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  String? get deletedAt;
  @override
  @JsonKey(ignore: true)
  _$$EligibleChildImplCopyWith<_$EligibleChildImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

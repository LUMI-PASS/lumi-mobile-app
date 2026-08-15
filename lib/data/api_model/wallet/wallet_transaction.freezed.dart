// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletTransactionModel _$WalletTransactionModelFromJson(
    Map<String, dynamic> json) {
  return _WalletTransactionModel.fromJson(json);
}

/// @nodoc
mixin _$WalletTransactionModel {
  @JsonKey(name: '_id')
  String? get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'kind')
  String? get kindRaw => throw _privateConstructorUsedError;

  /// Signed integer soum: positive credits, negative debits.
  num get amount => throw _privateConstructorUsedError;
  num get balanceAfter => throw _privateConstructorUsedError;
  String? get orderId => throw _privateConstructorUsedError;
  String? get activityId => throw _privateConstructorUsedError;

  /// Which of the three earn types produced this, when it was an accrual.
  String? get earnType => throw _privateConstructorUsedError;

  /// Percentage applied at the time — snapshotted, so history doesn't move
  /// when the dashboard changes the rate.
  num? get percent => throw _privateConstructorUsedError;
  num? get baseAmount => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WalletTransactionModelCopyWith<WalletTransactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletTransactionModelCopyWith<$Res> {
  factory $WalletTransactionModelCopyWith(WalletTransactionModel value,
          $Res Function(WalletTransactionModel) then) =
      _$WalletTransactionModelCopyWithImpl<$Res, WalletTransactionModel>;
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      @JsonKey(name: 'kind') String? kindRaw,
      num amount,
      num balanceAfter,
      String? orderId,
      String? activityId,
      String? earnType,
      num? percent,
      num? baseAmount,
      String? status,
      String? note,
      String? createdAt});
}

/// @nodoc
class _$WalletTransactionModelCopyWithImpl<$Res,
        $Val extends WalletTransactionModel>
    implements $WalletTransactionModelCopyWith<$Res> {
  _$WalletTransactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? kindRaw = freezed,
    Object? amount = null,
    Object? balanceAfter = null,
    Object? orderId = freezed,
    Object? activityId = freezed,
    Object? earnType = freezed,
    Object? percent = freezed,
    Object? baseAmount = freezed,
    Object? status = freezed,
    Object? note = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      kindRaw: freezed == kindRaw
          ? _value.kindRaw
          : kindRaw // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num,
      balanceAfter: null == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as num,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      activityId: freezed == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String?,
      earnType: freezed == earnType
          ? _value.earnType
          : earnType // ignore: cast_nullable_to_non_nullable
              as String?,
      percent: freezed == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as num?,
      baseAmount: freezed == baseAmount
          ? _value.baseAmount
          : baseAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletTransactionModelImplCopyWith<$Res>
    implements $WalletTransactionModelCopyWith<$Res> {
  factory _$$WalletTransactionModelImplCopyWith(
          _$WalletTransactionModelImpl value,
          $Res Function(_$WalletTransactionModelImpl) then) =
      __$$WalletTransactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: '_id') String? id,
      @JsonKey(name: 'kind') String? kindRaw,
      num amount,
      num balanceAfter,
      String? orderId,
      String? activityId,
      String? earnType,
      num? percent,
      num? baseAmount,
      String? status,
      String? note,
      String? createdAt});
}

/// @nodoc
class __$$WalletTransactionModelImplCopyWithImpl<$Res>
    extends _$WalletTransactionModelCopyWithImpl<$Res,
        _$WalletTransactionModelImpl>
    implements _$$WalletTransactionModelImplCopyWith<$Res> {
  __$$WalletTransactionModelImplCopyWithImpl(
      _$WalletTransactionModelImpl _value,
      $Res Function(_$WalletTransactionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? kindRaw = freezed,
    Object? amount = null,
    Object? balanceAfter = null,
    Object? orderId = freezed,
    Object? activityId = freezed,
    Object? earnType = freezed,
    Object? percent = freezed,
    Object? baseAmount = freezed,
    Object? status = freezed,
    Object? note = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$WalletTransactionModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      kindRaw: freezed == kindRaw
          ? _value.kindRaw
          : kindRaw // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num,
      balanceAfter: null == balanceAfter
          ? _value.balanceAfter
          : balanceAfter // ignore: cast_nullable_to_non_nullable
              as num,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      activityId: freezed == activityId
          ? _value.activityId
          : activityId // ignore: cast_nullable_to_non_nullable
              as String?,
      earnType: freezed == earnType
          ? _value.earnType
          : earnType // ignore: cast_nullable_to_non_nullable
              as String?,
      percent: freezed == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as num?,
      baseAmount: freezed == baseAmount
          ? _value.baseAmount
          : baseAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$WalletTransactionModelImpl extends _WalletTransactionModel {
  const _$WalletTransactionModelImpl(
      {@JsonKey(name: '_id') this.id,
      @JsonKey(name: 'kind') this.kindRaw,
      this.amount = 0,
      this.balanceAfter = 0,
      this.orderId,
      this.activityId,
      this.earnType,
      this.percent,
      this.baseAmount,
      this.status,
      this.note,
      this.createdAt})
      : super._();

  factory _$WalletTransactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletTransactionModelImplFromJson(json);

  @override
  @JsonKey(name: '_id')
  final String? id;
  @override
  @JsonKey(name: 'kind')
  final String? kindRaw;

  /// Signed integer soum: positive credits, negative debits.
  @override
  @JsonKey()
  final num amount;
  @override
  @JsonKey()
  final num balanceAfter;
  @override
  final String? orderId;
  @override
  final String? activityId;

  /// Which of the three earn types produced this, when it was an accrual.
  @override
  final String? earnType;

  /// Percentage applied at the time — snapshotted, so history doesn't move
  /// when the dashboard changes the rate.
  @override
  final num? percent;
  @override
  final num? baseAmount;
  @override
  final String? status;
  @override
  final String? note;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'WalletTransactionModel(id: $id, kindRaw: $kindRaw, amount: $amount, balanceAfter: $balanceAfter, orderId: $orderId, activityId: $activityId, earnType: $earnType, percent: $percent, baseAmount: $baseAmount, status: $status, note: $note, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletTransactionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kindRaw, kindRaw) || other.kindRaw == kindRaw) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.balanceAfter, balanceAfter) ||
                other.balanceAfter == balanceAfter) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.activityId, activityId) ||
                other.activityId == activityId) &&
            (identical(other.earnType, earnType) ||
                other.earnType == earnType) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.baseAmount, baseAmount) ||
                other.baseAmount == baseAmount) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      kindRaw,
      amount,
      balanceAfter,
      orderId,
      activityId,
      earnType,
      percent,
      baseAmount,
      status,
      note,
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletTransactionModelImplCopyWith<_$WalletTransactionModelImpl>
      get copyWith => __$$WalletTransactionModelImplCopyWithImpl<
          _$WalletTransactionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletTransactionModelImplToJson(
      this,
    );
  }
}

abstract class _WalletTransactionModel extends WalletTransactionModel {
  const factory _WalletTransactionModel(
      {@JsonKey(name: '_id') final String? id,
      @JsonKey(name: 'kind') final String? kindRaw,
      final num amount,
      final num balanceAfter,
      final String? orderId,
      final String? activityId,
      final String? earnType,
      final num? percent,
      final num? baseAmount,
      final String? status,
      final String? note,
      final String? createdAt}) = _$WalletTransactionModelImpl;
  const _WalletTransactionModel._() : super._();

  factory _WalletTransactionModel.fromJson(Map<String, dynamic> json) =
      _$WalletTransactionModelImpl.fromJson;

  @override
  @JsonKey(name: '_id')
  String? get id;
  @override
  @JsonKey(name: 'kind')
  String? get kindRaw;
  @override

  /// Signed integer soum: positive credits, negative debits.
  num get amount;
  @override
  num get balanceAfter;
  @override
  String? get orderId;
  @override
  String? get activityId;
  @override

  /// Which of the three earn types produced this, when it was an accrual.
  String? get earnType;
  @override

  /// Percentage applied at the time — snapshotted, so history doesn't move
  /// when the dashboard changes the rate.
  num? get percent;
  @override
  num? get baseAmount;
  @override
  String? get status;
  @override
  String? get note;
  @override
  String? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$WalletTransactionModelImplCopyWith<_$WalletTransactionModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cashback_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CashbackPreview _$CashbackPreviewFromJson(Map<String, dynamic> json) {
  return _CashbackPreview.fromJson(json);
}

/// @nodoc
mixin _$CashbackPreview {
  /// Raw wire value, kept for (de)serialization. Read [earnKind] instead.
  String? get earnType => throw _privateConstructorUsedError;
  num get percent => throw _privateConstructorUsedError;
  num get amount => throw _privateConstructorUsedError;

  /// Per-order ceiling in soum, `null` when uncapped.
  num? get maxCashbackAmount => throw _privateConstructorUsedError;

  /// Orders cheaper than this earn nothing.
  num get minOrderAmount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CashbackPreviewCopyWith<CashbackPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CashbackPreviewCopyWith<$Res> {
  factory $CashbackPreviewCopyWith(
          CashbackPreview value, $Res Function(CashbackPreview) then) =
      _$CashbackPreviewCopyWithImpl<$Res, CashbackPreview>;
  @useResult
  $Res call(
      {String? earnType,
      num percent,
      num amount,
      num? maxCashbackAmount,
      num minOrderAmount,
      String currency});
}

/// @nodoc
class _$CashbackPreviewCopyWithImpl<$Res, $Val extends CashbackPreview>
    implements $CashbackPreviewCopyWith<$Res> {
  _$CashbackPreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? earnType = freezed,
    Object? percent = null,
    Object? amount = null,
    Object? maxCashbackAmount = freezed,
    Object? minOrderAmount = null,
    Object? currency = null,
  }) {
    return _then(_value.copyWith(
      earnType: freezed == earnType
          ? _value.earnType
          : earnType // ignore: cast_nullable_to_non_nullable
              as String?,
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as num,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num,
      maxCashbackAmount: freezed == maxCashbackAmount
          ? _value.maxCashbackAmount
          : maxCashbackAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      minOrderAmount: null == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as num,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CashbackPreviewImplCopyWith<$Res>
    implements $CashbackPreviewCopyWith<$Res> {
  factory _$$CashbackPreviewImplCopyWith(_$CashbackPreviewImpl value,
          $Res Function(_$CashbackPreviewImpl) then) =
      __$$CashbackPreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? earnType,
      num percent,
      num amount,
      num? maxCashbackAmount,
      num minOrderAmount,
      String currency});
}

/// @nodoc
class __$$CashbackPreviewImplCopyWithImpl<$Res>
    extends _$CashbackPreviewCopyWithImpl<$Res, _$CashbackPreviewImpl>
    implements _$$CashbackPreviewImplCopyWith<$Res> {
  __$$CashbackPreviewImplCopyWithImpl(
      _$CashbackPreviewImpl _value, $Res Function(_$CashbackPreviewImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? earnType = freezed,
    Object? percent = null,
    Object? amount = null,
    Object? maxCashbackAmount = freezed,
    Object? minOrderAmount = null,
    Object? currency = null,
  }) {
    return _then(_$CashbackPreviewImpl(
      earnType: freezed == earnType
          ? _value.earnType
          : earnType // ignore: cast_nullable_to_non_nullable
              as String?,
      percent: null == percent
          ? _value.percent
          : percent // ignore: cast_nullable_to_non_nullable
              as num,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num,
      maxCashbackAmount: freezed == maxCashbackAmount
          ? _value.maxCashbackAmount
          : maxCashbackAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      minOrderAmount: null == minOrderAmount
          ? _value.minOrderAmount
          : minOrderAmount // ignore: cast_nullable_to_non_nullable
              as num,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$CashbackPreviewImpl extends _CashbackPreview {
  const _$CashbackPreviewImpl(
      {this.earnType,
      this.percent = 0,
      this.amount = 0,
      this.maxCashbackAmount,
      this.minOrderAmount = 0,
      this.currency = 'UZS'})
      : super._();

  factory _$CashbackPreviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$CashbackPreviewImplFromJson(json);

  /// Raw wire value, kept for (de)serialization. Read [earnKind] instead.
  @override
  final String? earnType;
  @override
  @JsonKey()
  final num percent;
  @override
  @JsonKey()
  final num amount;

  /// Per-order ceiling in soum, `null` when uncapped.
  @override
  final num? maxCashbackAmount;

  /// Orders cheaper than this earn nothing.
  @override
  @JsonKey()
  final num minOrderAmount;
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'CashbackPreview(earnType: $earnType, percent: $percent, amount: $amount, maxCashbackAmount: $maxCashbackAmount, minOrderAmount: $minOrderAmount, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CashbackPreviewImpl &&
            (identical(other.earnType, earnType) ||
                other.earnType == earnType) &&
            (identical(other.percent, percent) || other.percent == percent) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.maxCashbackAmount, maxCashbackAmount) ||
                other.maxCashbackAmount == maxCashbackAmount) &&
            (identical(other.minOrderAmount, minOrderAmount) ||
                other.minOrderAmount == minOrderAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, earnType, percent, amount,
      maxCashbackAmount, minOrderAmount, currency);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CashbackPreviewImplCopyWith<_$CashbackPreviewImpl> get copyWith =>
      __$$CashbackPreviewImplCopyWithImpl<_$CashbackPreviewImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CashbackPreviewImplToJson(
      this,
    );
  }
}

abstract class _CashbackPreview extends CashbackPreview {
  const factory _CashbackPreview(
      {final String? earnType,
      final num percent,
      final num amount,
      final num? maxCashbackAmount,
      final num minOrderAmount,
      final String currency}) = _$CashbackPreviewImpl;
  const _CashbackPreview._() : super._();

  factory _CashbackPreview.fromJson(Map<String, dynamic> json) =
      _$CashbackPreviewImpl.fromJson;

  @override

  /// Raw wire value, kept for (de)serialization. Read [earnKind] instead.
  String? get earnType;
  @override
  num get percent;
  @override
  num get amount;
  @override

  /// Per-order ceiling in soum, `null` when uncapped.
  num? get maxCashbackAmount;
  @override

  /// Orders cheaper than this earn nothing.
  num get minOrderAmount;
  @override
  String get currency;
  @override
  @JsonKey(ignore: true)
  _$$CashbackPreviewImplCopyWith<_$CashbackPreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_balance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletBalance _$WalletBalanceFromJson(Map<String, dynamic> json) {
  return _WalletBalance.fromJson(json);
}

/// @nodoc
mixin _$WalletBalance {
  num get balance => throw _privateConstructorUsedError;
  num get pendingBalance => throw _privateConstructorUsedError;
  num get heldBalance => throw _privateConstructorUsedError;
  @JsonKey(name: 'available')
  num? get availableRaw => throw _privateConstructorUsedError;
  num get lifetimeEarned => throw _privateConstructorUsedError;
  num get lifetimeSpent => throw _privateConstructorUsedError;
  bool get isFrozen => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WalletBalanceCopyWith<WalletBalance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletBalanceCopyWith<$Res> {
  factory $WalletBalanceCopyWith(
          WalletBalance value, $Res Function(WalletBalance) then) =
      _$WalletBalanceCopyWithImpl<$Res, WalletBalance>;
  @useResult
  $Res call(
      {num balance,
      num pendingBalance,
      num heldBalance,
      @JsonKey(name: 'available') num? availableRaw,
      num lifetimeEarned,
      num lifetimeSpent,
      bool isFrozen,
      String currency});
}

/// @nodoc
class _$WalletBalanceCopyWithImpl<$Res, $Val extends WalletBalance>
    implements $WalletBalanceCopyWith<$Res> {
  _$WalletBalanceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? pendingBalance = null,
    Object? heldBalance = null,
    Object? availableRaw = freezed,
    Object? lifetimeEarned = null,
    Object? lifetimeSpent = null,
    Object? isFrozen = null,
    Object? currency = null,
  }) {
    return _then(_value.copyWith(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as num,
      pendingBalance: null == pendingBalance
          ? _value.pendingBalance
          : pendingBalance // ignore: cast_nullable_to_non_nullable
              as num,
      heldBalance: null == heldBalance
          ? _value.heldBalance
          : heldBalance // ignore: cast_nullable_to_non_nullable
              as num,
      availableRaw: freezed == availableRaw
          ? _value.availableRaw
          : availableRaw // ignore: cast_nullable_to_non_nullable
              as num?,
      lifetimeEarned: null == lifetimeEarned
          ? _value.lifetimeEarned
          : lifetimeEarned // ignore: cast_nullable_to_non_nullable
              as num,
      lifetimeSpent: null == lifetimeSpent
          ? _value.lifetimeSpent
          : lifetimeSpent // ignore: cast_nullable_to_non_nullable
              as num,
      isFrozen: null == isFrozen
          ? _value.isFrozen
          : isFrozen // ignore: cast_nullable_to_non_nullable
              as bool,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletBalanceImplCopyWith<$Res>
    implements $WalletBalanceCopyWith<$Res> {
  factory _$$WalletBalanceImplCopyWith(
          _$WalletBalanceImpl value, $Res Function(_$WalletBalanceImpl) then) =
      __$$WalletBalanceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {num balance,
      num pendingBalance,
      num heldBalance,
      @JsonKey(name: 'available') num? availableRaw,
      num lifetimeEarned,
      num lifetimeSpent,
      bool isFrozen,
      String currency});
}

/// @nodoc
class __$$WalletBalanceImplCopyWithImpl<$Res>
    extends _$WalletBalanceCopyWithImpl<$Res, _$WalletBalanceImpl>
    implements _$$WalletBalanceImplCopyWith<$Res> {
  __$$WalletBalanceImplCopyWithImpl(
      _$WalletBalanceImpl _value, $Res Function(_$WalletBalanceImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? pendingBalance = null,
    Object? heldBalance = null,
    Object? availableRaw = freezed,
    Object? lifetimeEarned = null,
    Object? lifetimeSpent = null,
    Object? isFrozen = null,
    Object? currency = null,
  }) {
    return _then(_$WalletBalanceImpl(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as num,
      pendingBalance: null == pendingBalance
          ? _value.pendingBalance
          : pendingBalance // ignore: cast_nullable_to_non_nullable
              as num,
      heldBalance: null == heldBalance
          ? _value.heldBalance
          : heldBalance // ignore: cast_nullable_to_non_nullable
              as num,
      availableRaw: freezed == availableRaw
          ? _value.availableRaw
          : availableRaw // ignore: cast_nullable_to_non_nullable
              as num?,
      lifetimeEarned: null == lifetimeEarned
          ? _value.lifetimeEarned
          : lifetimeEarned // ignore: cast_nullable_to_non_nullable
              as num,
      lifetimeSpent: null == lifetimeSpent
          ? _value.lifetimeSpent
          : lifetimeSpent // ignore: cast_nullable_to_non_nullable
              as num,
      isFrozen: null == isFrozen
          ? _value.isFrozen
          : isFrozen // ignore: cast_nullable_to_non_nullable
              as bool,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$WalletBalanceImpl extends _WalletBalance {
  const _$WalletBalanceImpl(
      {this.balance = 0,
      this.pendingBalance = 0,
      this.heldBalance = 0,
      @JsonKey(name: 'available') this.availableRaw,
      this.lifetimeEarned = 0,
      this.lifetimeSpent = 0,
      this.isFrozen = false,
      this.currency = 'UZS'})
      : super._();

  factory _$WalletBalanceImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletBalanceImplFromJson(json);

  @override
  @JsonKey()
  final num balance;
  @override
  @JsonKey()
  final num pendingBalance;
  @override
  @JsonKey()
  final num heldBalance;
  @override
  @JsonKey(name: 'available')
  final num? availableRaw;
  @override
  @JsonKey()
  final num lifetimeEarned;
  @override
  @JsonKey()
  final num lifetimeSpent;
  @override
  @JsonKey()
  final bool isFrozen;
  @override
  @JsonKey()
  final String currency;

  @override
  String toString() {
    return 'WalletBalance(balance: $balance, pendingBalance: $pendingBalance, heldBalance: $heldBalance, availableRaw: $availableRaw, lifetimeEarned: $lifetimeEarned, lifetimeSpent: $lifetimeSpent, isFrozen: $isFrozen, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletBalanceImpl &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.pendingBalance, pendingBalance) ||
                other.pendingBalance == pendingBalance) &&
            (identical(other.heldBalance, heldBalance) ||
                other.heldBalance == heldBalance) &&
            (identical(other.availableRaw, availableRaw) ||
                other.availableRaw == availableRaw) &&
            (identical(other.lifetimeEarned, lifetimeEarned) ||
                other.lifetimeEarned == lifetimeEarned) &&
            (identical(other.lifetimeSpent, lifetimeSpent) ||
                other.lifetimeSpent == lifetimeSpent) &&
            (identical(other.isFrozen, isFrozen) ||
                other.isFrozen == isFrozen) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      balance,
      pendingBalance,
      heldBalance,
      availableRaw,
      lifetimeEarned,
      lifetimeSpent,
      isFrozen,
      currency);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletBalanceImplCopyWith<_$WalletBalanceImpl> get copyWith =>
      __$$WalletBalanceImplCopyWithImpl<_$WalletBalanceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletBalanceImplToJson(
      this,
    );
  }
}

abstract class _WalletBalance extends WalletBalance {
  const factory _WalletBalance(
      {final num balance,
      final num pendingBalance,
      final num heldBalance,
      @JsonKey(name: 'available') final num? availableRaw,
      final num lifetimeEarned,
      final num lifetimeSpent,
      final bool isFrozen,
      final String currency}) = _$WalletBalanceImpl;
  const _WalletBalance._() : super._();

  factory _WalletBalance.fromJson(Map<String, dynamic> json) =
      _$WalletBalanceImpl.fromJson;

  @override
  num get balance;
  @override
  num get pendingBalance;
  @override
  num get heldBalance;
  @override
  @JsonKey(name: 'available')
  num? get availableRaw;
  @override
  num get lifetimeEarned;
  @override
  num get lifetimeSpent;
  @override
  bool get isFrozen;
  @override
  String get currency;
  @override
  @JsonKey(ignore: true)
  _$$WalletBalanceImplCopyWith<_$WalletBalanceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

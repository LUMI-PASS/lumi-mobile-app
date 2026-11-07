// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AppBuildable {
  /// The live "Lumi Start" packet, or null when the user holds none.
  ///
  /// It decides what every price in the catalogue RENDERS — a covered activity shows an included badge
  /// instead of a figure — so it has to be one value every card watches, not
  /// a fetch per screen. Null the moment it is spent or expires, which is
  /// what brings the prices back.
  PromoPassCoverage? get promoPass => throw _privateConstructorUsedError;

  /// "Lumi Coin": whether packs are on sale and what this user holds.
  ///
  /// Null until the first sync lands, which reads the same as "not on sale"
  /// — every coin surface stays hidden rather than flashing in and out.
  NewCoinsSummary? get newCoins => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppBuildableCopyWith<AppBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppBuildableCopyWith<$Res> {
  factory $AppBuildableCopyWith(
          AppBuildable value, $Res Function(AppBuildable) then) =
      _$AppBuildableCopyWithImpl<$Res, AppBuildable>;
  @useResult
  $Res call({PromoPassCoverage? promoPass, NewCoinsSummary? newCoins});
}

/// @nodoc
class _$AppBuildableCopyWithImpl<$Res, $Val extends AppBuildable>
    implements $AppBuildableCopyWith<$Res> {
  _$AppBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promoPass = freezed,
    Object? newCoins = freezed,
  }) {
    return _then(_value.copyWith(
      promoPass: freezed == promoPass
          ? _value.promoPass
          : promoPass // ignore: cast_nullable_to_non_nullable
              as PromoPassCoverage?,
      newCoins: freezed == newCoins
          ? _value.newCoins
          : newCoins // ignore: cast_nullable_to_non_nullable
              as NewCoinsSummary?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppBuildableImplCopyWith<$Res>
    implements $AppBuildableCopyWith<$Res> {
  factory _$$AppBuildableImplCopyWith(
          _$AppBuildableImpl value, $Res Function(_$AppBuildableImpl) then) =
      __$$AppBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({PromoPassCoverage? promoPass, NewCoinsSummary? newCoins});
}

/// @nodoc
class __$$AppBuildableImplCopyWithImpl<$Res>
    extends _$AppBuildableCopyWithImpl<$Res, _$AppBuildableImpl>
    implements _$$AppBuildableImplCopyWith<$Res> {
  __$$AppBuildableImplCopyWithImpl(
      _$AppBuildableImpl _value, $Res Function(_$AppBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? promoPass = freezed,
    Object? newCoins = freezed,
  }) {
    return _then(_$AppBuildableImpl(
      promoPass: freezed == promoPass
          ? _value.promoPass
          : promoPass // ignore: cast_nullable_to_non_nullable
              as PromoPassCoverage?,
      newCoins: freezed == newCoins
          ? _value.newCoins
          : newCoins // ignore: cast_nullable_to_non_nullable
              as NewCoinsSummary?,
    ));
  }
}

/// @nodoc

class _$AppBuildableImpl implements _AppBuildable {
  const _$AppBuildableImpl({this.promoPass, this.newCoins});

  /// The live "Lumi Start" packet, or null when the user holds none.
  ///
  /// It decides what every price in the catalogue RENDERS — a covered activity shows an included badge
  /// instead of a figure — so it has to be one value every card watches, not
  /// a fetch per screen. Null the moment it is spent or expires, which is
  /// what brings the prices back.
  @override
  final PromoPassCoverage? promoPass;

  /// "Lumi Coin": whether packs are on sale and what this user holds.
  ///
  /// Null until the first sync lands, which reads the same as "not on sale"
  /// — every coin surface stays hidden rather than flashing in and out.
  @override
  final NewCoinsSummary? newCoins;

  @override
  String toString() {
    return 'AppBuildable(promoPass: $promoPass, newCoins: $newCoins)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppBuildableImpl &&
            (identical(other.promoPass, promoPass) ||
                other.promoPass == promoPass) &&
            (identical(other.newCoins, newCoins) ||
                other.newCoins == newCoins));
  }

  @override
  int get hashCode => Object.hash(runtimeType, promoPass, newCoins);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppBuildableImplCopyWith<_$AppBuildableImpl> get copyWith =>
      __$$AppBuildableImplCopyWithImpl<_$AppBuildableImpl>(this, _$identity);
}

abstract class _AppBuildable implements AppBuildable {
  const factory _AppBuildable(
      {final PromoPassCoverage? promoPass,
      final NewCoinsSummary? newCoins}) = _$AppBuildableImpl;

  @override

  /// The live "Lumi Start" packet, or null when the user holds none.
  ///
  /// It decides what every price in the catalogue RENDERS — a covered activity shows an included badge
  /// instead of a figure — so it has to be one value every card watches, not
  /// a fetch per screen. Null the moment it is spent or expires, which is
  /// what brings the prices back.
  PromoPassCoverage? get promoPass;
  @override

  /// "Lumi Coin": whether packs are on sale and what this user holds.
  ///
  /// Null until the first sync lands, which reads the same as "not on sale"
  /// — every coin surface stays hidden rather than flashing in and out.
  NewCoinsSummary? get newCoins;
  @override
  @JsonKey(ignore: true)
  _$$AppBuildableImplCopyWith<_$AppBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AppListenable {}

/// @nodoc
abstract class $AppListenableCopyWith<$Res> {
  factory $AppListenableCopyWith(
          AppListenable value, $Res Function(AppListenable) then) =
      _$AppListenableCopyWithImpl<$Res, AppListenable>;
}

/// @nodoc
class _$AppListenableCopyWithImpl<$Res, $Val extends AppListenable>
    implements $AppListenableCopyWith<$Res> {
  _$AppListenableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AppListenableImplCopyWith<$Res> {
  factory _$$AppListenableImplCopyWith(
          _$AppListenableImpl value, $Res Function(_$AppListenableImpl) then) =
      __$$AppListenableImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AppListenableImplCopyWithImpl<$Res>
    extends _$AppListenableCopyWithImpl<$Res, _$AppListenableImpl>
    implements _$$AppListenableImplCopyWith<$Res> {
  __$$AppListenableImplCopyWithImpl(
      _$AppListenableImpl _value, $Res Function(_$AppListenableImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$AppListenableImpl implements _AppListenable {
  const _$AppListenableImpl();

  @override
  String toString() {
    return 'AppListenable()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AppListenableImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

abstract class _AppListenable implements AppListenable {
  const factory _AppListenable() = _$AppListenableImpl;
}

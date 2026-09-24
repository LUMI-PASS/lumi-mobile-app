// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'referral_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReferralBuildable {
  /// First paint only — a pull-to-refresh keeps the old data on screen.
  bool get isLoading => throw _privateConstructorUsedError;

  /// The first load failed and there is nothing to show.
  bool get hasError => throw _privateConstructorUsedError;
  ReferralMe? get me => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ReferralBuildableCopyWith<ReferralBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralBuildableCopyWith<$Res> {
  factory $ReferralBuildableCopyWith(
          ReferralBuildable value, $Res Function(ReferralBuildable) then) =
      _$ReferralBuildableCopyWithImpl<$Res, ReferralBuildable>;
  @useResult
  $Res call({bool isLoading, bool hasError, ReferralMe? me});
}

/// @nodoc
class _$ReferralBuildableCopyWithImpl<$Res, $Val extends ReferralBuildable>
    implements $ReferralBuildableCopyWith<$Res> {
  _$ReferralBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? hasError = null,
    Object? me = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      me: freezed == me
          ? _value.me
          : me // ignore: cast_nullable_to_non_nullable
              as ReferralMe?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralBuildableImplCopyWith<$Res>
    implements $ReferralBuildableCopyWith<$Res> {
  factory _$$ReferralBuildableImplCopyWith(_$ReferralBuildableImpl value,
          $Res Function(_$ReferralBuildableImpl) then) =
      __$$ReferralBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, bool hasError, ReferralMe? me});
}

/// @nodoc
class __$$ReferralBuildableImplCopyWithImpl<$Res>
    extends _$ReferralBuildableCopyWithImpl<$Res, _$ReferralBuildableImpl>
    implements _$$ReferralBuildableImplCopyWith<$Res> {
  __$$ReferralBuildableImplCopyWithImpl(_$ReferralBuildableImpl _value,
      $Res Function(_$ReferralBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? hasError = null,
    Object? me = freezed,
  }) {
    return _then(_$ReferralBuildableImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      me: freezed == me
          ? _value.me
          : me // ignore: cast_nullable_to_non_nullable
              as ReferralMe?,
    ));
  }
}

/// @nodoc

class _$ReferralBuildableImpl implements _ReferralBuildable {
  const _$ReferralBuildableImpl(
      {this.isLoading = true, this.hasError = false, this.me});

  /// First paint only — a pull-to-refresh keeps the old data on screen.
  @override
  @JsonKey()
  final bool isLoading;

  /// The first load failed and there is nothing to show.
  @override
  @JsonKey()
  final bool hasError;
  @override
  final ReferralMe? me;

  @override
  String toString() {
    return 'ReferralBuildable(isLoading: $isLoading, hasError: $hasError, me: $me)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralBuildableImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.me, me) || other.me == me));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, hasError, me);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralBuildableImplCopyWith<_$ReferralBuildableImpl> get copyWith =>
      __$$ReferralBuildableImplCopyWithImpl<_$ReferralBuildableImpl>(
          this, _$identity);
}

abstract class _ReferralBuildable implements ReferralBuildable {
  const factory _ReferralBuildable(
      {final bool isLoading,
      final bool hasError,
      final ReferralMe? me}) = _$ReferralBuildableImpl;

  @override

  /// First paint only — a pull-to-refresh keeps the old data on screen.
  bool get isLoading;
  @override

  /// The first load failed and there is nothing to show.
  bool get hasError;
  @override
  ReferralMe? get me;
  @override
  @JsonKey(ignore: true)
  _$$ReferralBuildableImplCopyWith<_$ReferralBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ReferralListenable {
  ReferralEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ReferralListenableCopyWith<ReferralListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReferralListenableCopyWith<$Res> {
  factory $ReferralListenableCopyWith(
          ReferralListenable value, $Res Function(ReferralListenable) then) =
      _$ReferralListenableCopyWithImpl<$Res, ReferralListenable>;
  @useResult
  $Res call({ReferralEffect effect});
}

/// @nodoc
class _$ReferralListenableCopyWithImpl<$Res, $Val extends ReferralListenable>
    implements $ReferralListenableCopyWith<$Res> {
  _$ReferralListenableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_value.copyWith(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as ReferralEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReferralListenableImplCopyWith<$Res>
    implements $ReferralListenableCopyWith<$Res> {
  factory _$$ReferralListenableImplCopyWith(_$ReferralListenableImpl value,
          $Res Function(_$ReferralListenableImpl) then) =
      __$$ReferralListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ReferralEffect effect});
}

/// @nodoc
class __$$ReferralListenableImplCopyWithImpl<$Res>
    extends _$ReferralListenableCopyWithImpl<$Res, _$ReferralListenableImpl>
    implements _$$ReferralListenableImplCopyWith<$Res> {
  __$$ReferralListenableImplCopyWithImpl(_$ReferralListenableImpl _value,
      $Res Function(_$ReferralListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$ReferralListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as ReferralEffect,
    ));
  }
}

/// @nodoc

class _$ReferralListenableImpl implements _ReferralListenable {
  const _$ReferralListenableImpl({required this.effect});

  @override
  final ReferralEffect effect;

  @override
  String toString() {
    return 'ReferralListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReferralListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReferralListenableImplCopyWith<_$ReferralListenableImpl> get copyWith =>
      __$$ReferralListenableImplCopyWithImpl<_$ReferralListenableImpl>(
          this, _$identity);
}

abstract class _ReferralListenable implements ReferralListenable {
  const factory _ReferralListenable({required final ReferralEffect effect}) =
      _$ReferralListenableImpl;

  @override
  ReferralEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$ReferralListenableImplCopyWith<_$ReferralListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

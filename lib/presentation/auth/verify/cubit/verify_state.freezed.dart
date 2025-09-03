// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'verify_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$VerifyBuildable {
  bool get loading => throw _privateConstructorUsedError;
  bool get resetLoading => throw _privateConstructorUsedError;
  int get timer => throw _privateConstructorUsedError;
  int? get code => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $VerifyBuildableCopyWith<VerifyBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyBuildableCopyWith<$Res> {
  factory $VerifyBuildableCopyWith(
          VerifyBuildable value, $Res Function(VerifyBuildable) then) =
      _$VerifyBuildableCopyWithImpl<$Res, VerifyBuildable>;
  @useResult
  $Res call(
      {bool loading, bool resetLoading, int timer, int? code, String? error});
}

/// @nodoc
class _$VerifyBuildableCopyWithImpl<$Res, $Val extends VerifyBuildable>
    implements $VerifyBuildableCopyWith<$Res> {
  _$VerifyBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = null,
    Object? resetLoading = null,
    Object? timer = null,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      resetLoading: null == resetLoading
          ? _value.resetLoading
          : resetLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      timer: null == timer
          ? _value.timer
          : timer // ignore: cast_nullable_to_non_nullable
              as int,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerifyBuildableImplCopyWith<$Res>
    implements $VerifyBuildableCopyWith<$Res> {
  factory _$$VerifyBuildableImplCopyWith(_$VerifyBuildableImpl value,
          $Res Function(_$VerifyBuildableImpl) then) =
      __$$VerifyBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool loading, bool resetLoading, int timer, int? code, String? error});
}

/// @nodoc
class __$$VerifyBuildableImplCopyWithImpl<$Res>
    extends _$VerifyBuildableCopyWithImpl<$Res, _$VerifyBuildableImpl>
    implements _$$VerifyBuildableImplCopyWith<$Res> {
  __$$VerifyBuildableImplCopyWithImpl(
      _$VerifyBuildableImpl _value, $Res Function(_$VerifyBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? loading = null,
    Object? resetLoading = null,
    Object? timer = null,
    Object? code = freezed,
    Object? error = freezed,
  }) {
    return _then(_$VerifyBuildableImpl(
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      resetLoading: null == resetLoading
          ? _value.resetLoading
          : resetLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      timer: null == timer
          ? _value.timer
          : timer // ignore: cast_nullable_to_non_nullable
              as int,
      code: freezed == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as int?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$VerifyBuildableImpl implements _VerifyBuildable {
  const _$VerifyBuildableImpl(
      {this.loading = false,
      this.resetLoading = false,
      this.timer = 59,
      this.code = null,
      this.error = null});

  @override
  @JsonKey()
  final bool loading;
  @override
  @JsonKey()
  final bool resetLoading;
  @override
  @JsonKey()
  final int timer;
  @override
  @JsonKey()
  final int? code;
  @override
  @JsonKey()
  final String? error;

  @override
  String toString() {
    return 'VerifyBuildable(loading: $loading, resetLoading: $resetLoading, timer: $timer, code: $code, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyBuildableImpl &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.resetLoading, resetLoading) ||
                other.resetLoading == resetLoading) &&
            (identical(other.timer, timer) || other.timer == timer) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, loading, resetLoading, timer, code, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyBuildableImplCopyWith<_$VerifyBuildableImpl> get copyWith =>
      __$$VerifyBuildableImplCopyWithImpl<_$VerifyBuildableImpl>(
          this, _$identity);
}

abstract class _VerifyBuildable implements VerifyBuildable {
  const factory _VerifyBuildable(
      {final bool loading,
      final bool resetLoading,
      final int timer,
      final int? code,
      final String? error}) = _$VerifyBuildableImpl;

  @override
  bool get loading;
  @override
  bool get resetLoading;
  @override
  int get timer;
  @override
  int? get code;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$VerifyBuildableImplCopyWith<_$VerifyBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$VerifyListenable {
  VerifyEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $VerifyListenableCopyWith<VerifyListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyListenableCopyWith<$Res> {
  factory $VerifyListenableCopyWith(
          VerifyListenable value, $Res Function(VerifyListenable) then) =
      _$VerifyListenableCopyWithImpl<$Res, VerifyListenable>;
  @useResult
  $Res call({VerifyEffect effect});
}

/// @nodoc
class _$VerifyListenableCopyWithImpl<$Res, $Val extends VerifyListenable>
    implements $VerifyListenableCopyWith<$Res> {
  _$VerifyListenableCopyWithImpl(this._value, this._then);

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
              as VerifyEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerifyListenableImplCopyWith<$Res>
    implements $VerifyListenableCopyWith<$Res> {
  factory _$$VerifyListenableImplCopyWith(_$VerifyListenableImpl value,
          $Res Function(_$VerifyListenableImpl) then) =
      __$$VerifyListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({VerifyEffect effect});
}

/// @nodoc
class __$$VerifyListenableImplCopyWithImpl<$Res>
    extends _$VerifyListenableCopyWithImpl<$Res, _$VerifyListenableImpl>
    implements _$$VerifyListenableImplCopyWith<$Res> {
  __$$VerifyListenableImplCopyWithImpl(_$VerifyListenableImpl _value,
      $Res Function(_$VerifyListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$VerifyListenableImpl(
      null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as VerifyEffect,
    ));
  }
}

/// @nodoc

class _$VerifyListenableImpl implements _VerifyListenable {
  const _$VerifyListenableImpl(this.effect);

  @override
  final VerifyEffect effect;

  @override
  String toString() {
    return 'VerifyListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyListenableImplCopyWith<_$VerifyListenableImpl> get copyWith =>
      __$$VerifyListenableImplCopyWithImpl<_$VerifyListenableImpl>(
          this, _$identity);
}

abstract class _VerifyListenable implements VerifyListenable {
  const factory _VerifyListenable(final VerifyEffect effect) =
      _$VerifyListenableImpl;

  @override
  VerifyEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$VerifyListenableImplCopyWith<_$VerifyListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

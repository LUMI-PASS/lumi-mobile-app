// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OnboardingBuildable {
  int get index => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingBuildable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingBuildableCopyWith<OnboardingBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingBuildableCopyWith<$Res> {
  factory $OnboardingBuildableCopyWith(
          OnboardingBuildable value, $Res Function(OnboardingBuildable) then) =
      _$OnboardingBuildableCopyWithImpl<$Res, OnboardingBuildable>;
  @useResult
  $Res call({int index});
}

/// @nodoc
class _$OnboardingBuildableCopyWithImpl<$Res, $Val extends OnboardingBuildable>
    implements $OnboardingBuildableCopyWith<$Res> {
  _$OnboardingBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingBuildable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
  }) {
    return _then(_value.copyWith(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnboardingBuildableImplCopyWith<$Res>
    implements $OnboardingBuildableCopyWith<$Res> {
  factory _$$OnboardingBuildableImplCopyWith(_$OnboardingBuildableImpl value,
          $Res Function(_$OnboardingBuildableImpl) then) =
      __$$OnboardingBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int index});
}

/// @nodoc
class __$$OnboardingBuildableImplCopyWithImpl<$Res>
    extends _$OnboardingBuildableCopyWithImpl<$Res, _$OnboardingBuildableImpl>
    implements _$$OnboardingBuildableImplCopyWith<$Res> {
  __$$OnboardingBuildableImplCopyWithImpl(_$OnboardingBuildableImpl _value,
      $Res Function(_$OnboardingBuildableImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingBuildable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? index = null,
  }) {
    return _then(_$OnboardingBuildableImpl(
      index: null == index
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$OnboardingBuildableImpl implements _OnboardingBuildable {
  const _$OnboardingBuildableImpl({this.index = 0});

  @override
  @JsonKey()
  final int index;

  @override
  String toString() {
    return 'OnboardingBuildable(index: $index)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingBuildableImpl &&
            (identical(other.index, index) || other.index == index));
  }

  @override
  int get hashCode => Object.hash(runtimeType, index);

  /// Create a copy of OnboardingBuildable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingBuildableImplCopyWith<_$OnboardingBuildableImpl> get copyWith =>
      __$$OnboardingBuildableImplCopyWithImpl<_$OnboardingBuildableImpl>(
          this, _$identity);
}

abstract class _OnboardingBuildable implements OnboardingBuildable {
  const factory _OnboardingBuildable({final int index}) =
      _$OnboardingBuildableImpl;

  @override
  int get index;

  /// Create a copy of OnboardingBuildable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingBuildableImplCopyWith<_$OnboardingBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$OnboardingListenable {
  OnboardEffect get effect => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingListenable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingListenableCopyWith<OnboardingListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingListenableCopyWith<$Res> {
  factory $OnboardingListenableCopyWith(OnboardingListenable value,
          $Res Function(OnboardingListenable) then) =
      _$OnboardingListenableCopyWithImpl<$Res, OnboardingListenable>;
  @useResult
  $Res call({OnboardEffect effect});
}

/// @nodoc
class _$OnboardingListenableCopyWithImpl<$Res,
        $Val extends OnboardingListenable>
    implements $OnboardingListenableCopyWith<$Res> {
  _$OnboardingListenableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingListenable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_value.copyWith(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as OnboardEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OnboardingListenableImplCopyWith<$Res>
    implements $OnboardingListenableCopyWith<$Res> {
  factory _$$OnboardingListenableImplCopyWith(_$OnboardingListenableImpl value,
          $Res Function(_$OnboardingListenableImpl) then) =
      __$$OnboardingListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({OnboardEffect effect});
}

/// @nodoc
class __$$OnboardingListenableImplCopyWithImpl<$Res>
    extends _$OnboardingListenableCopyWithImpl<$Res, _$OnboardingListenableImpl>
    implements _$$OnboardingListenableImplCopyWith<$Res> {
  __$$OnboardingListenableImplCopyWithImpl(_$OnboardingListenableImpl _value,
      $Res Function(_$OnboardingListenableImpl) _then)
      : super(_value, _then);

  /// Create a copy of OnboardingListenable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$OnboardingListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as OnboardEffect,
    ));
  }
}

/// @nodoc

class _$OnboardingListenableImpl implements _OnboardingListenable {
  const _$OnboardingListenableImpl({required this.effect});

  @override
  final OnboardEffect effect;

  @override
  String toString() {
    return 'OnboardingListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  /// Create a copy of OnboardingListenable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingListenableImplCopyWith<_$OnboardingListenableImpl>
      get copyWith =>
          __$$OnboardingListenableImplCopyWithImpl<_$OnboardingListenableImpl>(
              this, _$identity);
}

abstract class _OnboardingListenable implements OnboardingListenable {
  const factory _OnboardingListenable({required final OnboardEffect effect}) =
      _$OnboardingListenableImpl;

  @override
  OnboardEffect get effect;

  /// Create a copy of OnboardingListenable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingListenableImplCopyWith<_$OnboardingListenableImpl>
      get copyWith => throw _privateConstructorUsedError;
}

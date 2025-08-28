// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'register_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RegisterBuildable {
  bool get isSelected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorPhone => throw _privateConstructorUsedError;

  /// Create a copy of RegisterBuildable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterBuildableCopyWith<RegisterBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterBuildableCopyWith<$Res> {
  factory $RegisterBuildableCopyWith(
          RegisterBuildable value, $Res Function(RegisterBuildable) then) =
      _$RegisterBuildableCopyWithImpl<$Res, RegisterBuildable>;
  @useResult
  $Res call({bool isSelected, bool isLoading, String? errorPhone});
}

/// @nodoc
class _$RegisterBuildableCopyWithImpl<$Res, $Val extends RegisterBuildable>
    implements $RegisterBuildableCopyWith<$Res> {
  _$RegisterBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterBuildable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? errorPhone = freezed,
  }) {
    return _then(_value.copyWith(
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorPhone: freezed == errorPhone
          ? _value.errorPhone
          : errorPhone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterBuildableImplCopyWith<$Res>
    implements $RegisterBuildableCopyWith<$Res> {
  factory _$$RegisterBuildableImplCopyWith(_$RegisterBuildableImpl value,
          $Res Function(_$RegisterBuildableImpl) then) =
      __$$RegisterBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isSelected, bool isLoading, String? errorPhone});
}

/// @nodoc
class __$$RegisterBuildableImplCopyWithImpl<$Res>
    extends _$RegisterBuildableCopyWithImpl<$Res, _$RegisterBuildableImpl>
    implements _$$RegisterBuildableImplCopyWith<$Res> {
  __$$RegisterBuildableImplCopyWithImpl(_$RegisterBuildableImpl _value,
      $Res Function(_$RegisterBuildableImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterBuildable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? errorPhone = freezed,
  }) {
    return _then(_$RegisterBuildableImpl(
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorPhone: freezed == errorPhone
          ? _value.errorPhone
          : errorPhone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RegisterBuildableImpl implements _RegisterBuildable {
  const _$RegisterBuildableImpl(
      {this.isSelected = false,
      this.isLoading = false,
      this.errorPhone = null});

  @override
  @JsonKey()
  final bool isSelected;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final String? errorPhone;

  @override
  String toString() {
    return 'RegisterBuildable(isSelected: $isSelected, isLoading: $isLoading, errorPhone: $errorPhone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterBuildableImpl &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorPhone, errorPhone) ||
                other.errorPhone == errorPhone));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isSelected, isLoading, errorPhone);

  /// Create a copy of RegisterBuildable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterBuildableImplCopyWith<_$RegisterBuildableImpl> get copyWith =>
      __$$RegisterBuildableImplCopyWithImpl<_$RegisterBuildableImpl>(
          this, _$identity);
}

abstract class _RegisterBuildable implements RegisterBuildable {
  const factory _RegisterBuildable(
      {final bool isSelected,
      final bool isLoading,
      final String? errorPhone}) = _$RegisterBuildableImpl;

  @override
  bool get isSelected;
  @override
  bool get isLoading;
  @override
  String? get errorPhone;

  /// Create a copy of RegisterBuildable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterBuildableImplCopyWith<_$RegisterBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RegisterListenable {
  RegisterEffect get effect => throw _privateConstructorUsedError;

  /// Create a copy of RegisterListenable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RegisterListenableCopyWith<RegisterListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterListenableCopyWith<$Res> {
  factory $RegisterListenableCopyWith(
          RegisterListenable value, $Res Function(RegisterListenable) then) =
      _$RegisterListenableCopyWithImpl<$Res, RegisterListenable>;
  @useResult
  $Res call({RegisterEffect effect});
}

/// @nodoc
class _$RegisterListenableCopyWithImpl<$Res, $Val extends RegisterListenable>
    implements $RegisterListenableCopyWith<$Res> {
  _$RegisterListenableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RegisterListenable
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
              as RegisterEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterListenableImplCopyWith<$Res>
    implements $RegisterListenableCopyWith<$Res> {
  factory _$$RegisterListenableImplCopyWith(_$RegisterListenableImpl value,
          $Res Function(_$RegisterListenableImpl) then) =
      __$$RegisterListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RegisterEffect effect});
}

/// @nodoc
class __$$RegisterListenableImplCopyWithImpl<$Res>
    extends _$RegisterListenableCopyWithImpl<$Res, _$RegisterListenableImpl>
    implements _$$RegisterListenableImplCopyWith<$Res> {
  __$$RegisterListenableImplCopyWithImpl(_$RegisterListenableImpl _value,
      $Res Function(_$RegisterListenableImpl) _then)
      : super(_value, _then);

  /// Create a copy of RegisterListenable
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$RegisterListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as RegisterEffect,
    ));
  }
}

/// @nodoc

class _$RegisterListenableImpl implements _RegisterListenable {
  const _$RegisterListenableImpl({required this.effect});

  @override
  final RegisterEffect effect;

  @override
  String toString() {
    return 'RegisterListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  /// Create a copy of RegisterListenable
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterListenableImplCopyWith<_$RegisterListenableImpl> get copyWith =>
      __$$RegisterListenableImplCopyWithImpl<_$RegisterListenableImpl>(
          this, _$identity);
}

abstract class _RegisterListenable implements RegisterListenable {
  const factory _RegisterListenable({required final RegisterEffect effect}) =
      _$RegisterListenableImpl;

  @override
  RegisterEffect get effect;

  /// Create a copy of RegisterListenable
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RegisterListenableImplCopyWith<_$RegisterListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LoginBuildable {
  bool get isSelected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get errorPhone => throw _privateConstructorUsedError;
  String? get errorPassword => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LoginBuildableCopyWith<LoginBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginBuildableCopyWith<$Res> {
  factory $LoginBuildableCopyWith(
          LoginBuildable value, $Res Function(LoginBuildable) then) =
      _$LoginBuildableCopyWithImpl<$Res, LoginBuildable>;
  @useResult
  $Res call(
      {bool isSelected,
      bool isLoading,
      bool success,
      String? errorPhone,
      String? errorPassword});
}

/// @nodoc
class _$LoginBuildableCopyWithImpl<$Res, $Val extends LoginBuildable>
    implements $LoginBuildableCopyWith<$Res> {
  _$LoginBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? success = null,
    Object? errorPhone = freezed,
    Object? errorPassword = freezed,
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
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      errorPhone: freezed == errorPhone
          ? _value.errorPhone
          : errorPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      errorPassword: freezed == errorPassword
          ? _value.errorPassword
          : errorPassword // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginBuildableImplCopyWith<$Res>
    implements $LoginBuildableCopyWith<$Res> {
  factory _$$LoginBuildableImplCopyWith(_$LoginBuildableImpl value,
          $Res Function(_$LoginBuildableImpl) then) =
      __$$LoginBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSelected,
      bool isLoading,
      bool success,
      String? errorPhone,
      String? errorPassword});
}

/// @nodoc
class __$$LoginBuildableImplCopyWithImpl<$Res>
    extends _$LoginBuildableCopyWithImpl<$Res, _$LoginBuildableImpl>
    implements _$$LoginBuildableImplCopyWith<$Res> {
  __$$LoginBuildableImplCopyWithImpl(
      _$LoginBuildableImpl _value, $Res Function(_$LoginBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? success = null,
    Object? errorPhone = freezed,
    Object? errorPassword = freezed,
  }) {
    return _then(_$LoginBuildableImpl(
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      errorPhone: freezed == errorPhone
          ? _value.errorPhone
          : errorPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      errorPassword: freezed == errorPassword
          ? _value.errorPassword
          : errorPassword // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$LoginBuildableImpl implements _LoginBuildable {
  const _$LoginBuildableImpl(
      {this.isSelected = false,
      this.isLoading = false,
      this.success = false,
      this.errorPhone = null,
      this.errorPassword = null});

  @override
  @JsonKey()
  final bool isSelected;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool success;
  @override
  @JsonKey()
  final String? errorPhone;
  @override
  @JsonKey()
  final String? errorPassword;

  @override
  String toString() {
    return 'LoginBuildable(isSelected: $isSelected, isLoading: $isLoading, success: $success, errorPhone: $errorPhone, errorPassword: $errorPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginBuildableImpl &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.errorPhone, errorPhone) ||
                other.errorPhone == errorPhone) &&
            (identical(other.errorPassword, errorPassword) ||
                other.errorPassword == errorPassword));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, isSelected, isLoading, success, errorPhone, errorPassword);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginBuildableImplCopyWith<_$LoginBuildableImpl> get copyWith =>
      __$$LoginBuildableImplCopyWithImpl<_$LoginBuildableImpl>(
          this, _$identity);
}

abstract class _LoginBuildable implements LoginBuildable {
  const factory _LoginBuildable(
      {final bool isSelected,
      final bool isLoading,
      final bool success,
      final String? errorPhone,
      final String? errorPassword}) = _$LoginBuildableImpl;

  @override
  bool get isSelected;
  @override
  bool get isLoading;
  @override
  bool get success;
  @override
  String? get errorPhone;
  @override
  String? get errorPassword;
  @override
  @JsonKey(ignore: true)
  _$$LoginBuildableImplCopyWith<_$LoginBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$LoginListenable {
  LoginEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LoginListenableCopyWith<LoginListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginListenableCopyWith<$Res> {
  factory $LoginListenableCopyWith(
          LoginListenable value, $Res Function(LoginListenable) then) =
      _$LoginListenableCopyWithImpl<$Res, LoginListenable>;
  @useResult
  $Res call({LoginEffect effect});
}

/// @nodoc
class _$LoginListenableCopyWithImpl<$Res, $Val extends LoginListenable>
    implements $LoginListenableCopyWith<$Res> {
  _$LoginListenableCopyWithImpl(this._value, this._then);

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
              as LoginEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginListenableImplCopyWith<$Res>
    implements $LoginListenableCopyWith<$Res> {
  factory _$$LoginListenableImplCopyWith(_$LoginListenableImpl value,
          $Res Function(_$LoginListenableImpl) then) =
      __$$LoginListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({LoginEffect effect});
}

/// @nodoc
class __$$LoginListenableImplCopyWithImpl<$Res>
    extends _$LoginListenableCopyWithImpl<$Res, _$LoginListenableImpl>
    implements _$$LoginListenableImplCopyWith<$Res> {
  __$$LoginListenableImplCopyWithImpl(
      _$LoginListenableImpl _value, $Res Function(_$LoginListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$LoginListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as LoginEffect,
    ));
  }
}

/// @nodoc

class _$LoginListenableImpl implements _LoginListenable {
  const _$LoginListenableImpl({required this.effect});

  @override
  final LoginEffect effect;

  @override
  String toString() {
    return 'LoginListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginListenableImplCopyWith<_$LoginListenableImpl> get copyWith =>
      __$$LoginListenableImplCopyWithImpl<_$LoginListenableImpl>(
          this, _$identity);
}

abstract class _LoginListenable implements LoginListenable {
  const factory _LoginListenable({required final LoginEffect effect}) =
      _$LoginListenableImpl;

  @override
  LoginEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$LoginListenableImplCopyWith<_$LoginListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

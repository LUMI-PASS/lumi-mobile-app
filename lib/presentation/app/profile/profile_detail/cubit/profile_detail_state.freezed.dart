// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_detail_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileDetailBuildable {
  bool get isSelected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  HomForUser? get homeModel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileDetailBuildableCopyWith<ProfileDetailBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileDetailBuildableCopyWith<$Res> {
  factory $ProfileDetailBuildableCopyWith(ProfileDetailBuildable value,
          $Res Function(ProfileDetailBuildable) then) =
      _$ProfileDetailBuildableCopyWithImpl<$Res, ProfileDetailBuildable>;
  @useResult
  $Res call(
      {bool isSelected, bool isLoading, bool success, HomForUser? homeModel});

  $HomForUserCopyWith<$Res>? get homeModel;
}

/// @nodoc
class _$ProfileDetailBuildableCopyWithImpl<$Res,
        $Val extends ProfileDetailBuildable>
    implements $ProfileDetailBuildableCopyWith<$Res> {
  _$ProfileDetailBuildableCopyWithImpl(this._value, this._then);

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
    Object? homeModel = freezed,
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
      homeModel: freezed == homeModel
          ? _value.homeModel
          : homeModel // ignore: cast_nullable_to_non_nullable
              as HomForUser?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomForUserCopyWith<$Res>? get homeModel {
    if (_value.homeModel == null) {
      return null;
    }

    return $HomForUserCopyWith<$Res>(_value.homeModel!, (value) {
      return _then(_value.copyWith(homeModel: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileDetailBuildableImplCopyWith<$Res>
    implements $ProfileDetailBuildableCopyWith<$Res> {
  factory _$$ProfileDetailBuildableImplCopyWith(
          _$ProfileDetailBuildableImpl value,
          $Res Function(_$ProfileDetailBuildableImpl) then) =
      __$$ProfileDetailBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSelected, bool isLoading, bool success, HomForUser? homeModel});

  @override
  $HomForUserCopyWith<$Res>? get homeModel;
}

/// @nodoc
class __$$ProfileDetailBuildableImplCopyWithImpl<$Res>
    extends _$ProfileDetailBuildableCopyWithImpl<$Res,
        _$ProfileDetailBuildableImpl>
    implements _$$ProfileDetailBuildableImplCopyWith<$Res> {
  __$$ProfileDetailBuildableImplCopyWithImpl(
      _$ProfileDetailBuildableImpl _value,
      $Res Function(_$ProfileDetailBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? success = null,
    Object? homeModel = freezed,
  }) {
    return _then(_$ProfileDetailBuildableImpl(
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
      homeModel: freezed == homeModel
          ? _value.homeModel
          : homeModel // ignore: cast_nullable_to_non_nullable
              as HomForUser?,
    ));
  }
}

/// @nodoc

class _$ProfileDetailBuildableImpl implements _ProfileDetailBuildable {
  const _$ProfileDetailBuildableImpl(
      {this.isSelected = false,
      this.isLoading = false,
      this.success = false,
      this.homeModel});

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
  final HomForUser? homeModel;

  @override
  String toString() {
    return 'ProfileDetailBuildable(isSelected: $isSelected, isLoading: $isLoading, success: $success, homeModel: $homeModel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileDetailBuildableImpl &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.homeModel, homeModel) ||
                other.homeModel == homeModel));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isSelected, isLoading, success, homeModel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileDetailBuildableImplCopyWith<_$ProfileDetailBuildableImpl>
      get copyWith => __$$ProfileDetailBuildableImplCopyWithImpl<
          _$ProfileDetailBuildableImpl>(this, _$identity);
}

abstract class _ProfileDetailBuildable implements ProfileDetailBuildable {
  const factory _ProfileDetailBuildable(
      {final bool isSelected,
      final bool isLoading,
      final bool success,
      final HomForUser? homeModel}) = _$ProfileDetailBuildableImpl;

  @override
  bool get isSelected;
  @override
  bool get isLoading;
  @override
  bool get success;
  @override
  HomForUser? get homeModel;
  @override
  @JsonKey(ignore: true)
  _$$ProfileDetailBuildableImplCopyWith<_$ProfileDetailBuildableImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ProfileDetailListenable {
  ProfileDetailEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileDetailListenableCopyWith<ProfileDetailListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileDetailListenableCopyWith<$Res> {
  factory $ProfileDetailListenableCopyWith(ProfileDetailListenable value,
          $Res Function(ProfileDetailListenable) then) =
      _$ProfileDetailListenableCopyWithImpl<$Res, ProfileDetailListenable>;
  @useResult
  $Res call({ProfileDetailEffect effect});
}

/// @nodoc
class _$ProfileDetailListenableCopyWithImpl<$Res,
        $Val extends ProfileDetailListenable>
    implements $ProfileDetailListenableCopyWith<$Res> {
  _$ProfileDetailListenableCopyWithImpl(this._value, this._then);

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
              as ProfileDetailEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileDetailListenableImplCopyWith<$Res>
    implements $ProfileDetailListenableCopyWith<$Res> {
  factory _$$ProfileDetailListenableImplCopyWith(
          _$ProfileDetailListenableImpl value,
          $Res Function(_$ProfileDetailListenableImpl) then) =
      __$$ProfileDetailListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ProfileDetailEffect effect});
}

/// @nodoc
class __$$ProfileDetailListenableImplCopyWithImpl<$Res>
    extends _$ProfileDetailListenableCopyWithImpl<$Res,
        _$ProfileDetailListenableImpl>
    implements _$$ProfileDetailListenableImplCopyWith<$Res> {
  __$$ProfileDetailListenableImplCopyWithImpl(
      _$ProfileDetailListenableImpl _value,
      $Res Function(_$ProfileDetailListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$ProfileDetailListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as ProfileDetailEffect,
    ));
  }
}

/// @nodoc

class _$ProfileDetailListenableImpl implements _ProfileDetailListenable {
  const _$ProfileDetailListenableImpl({required this.effect});

  @override
  final ProfileDetailEffect effect;

  @override
  String toString() {
    return 'ProfileDetailListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileDetailListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileDetailListenableImplCopyWith<_$ProfileDetailListenableImpl>
      get copyWith => __$$ProfileDetailListenableImplCopyWithImpl<
          _$ProfileDetailListenableImpl>(this, _$identity);
}

abstract class _ProfileDetailListenable implements ProfileDetailListenable {
  const factory _ProfileDetailListenable(
          {required final ProfileDetailEffect effect}) =
      _$ProfileDetailListenableImpl;

  @override
  ProfileDetailEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$ProfileDetailListenableImplCopyWith<_$ProfileDetailListenableImpl>
      get copyWith => throw _privateConstructorUsedError;
}

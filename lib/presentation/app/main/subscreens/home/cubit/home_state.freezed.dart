// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HomeBuildable {
  bool get isSelected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  HomeModel? get homeModel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeBuildableCopyWith<HomeBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeBuildableCopyWith<$Res> {
  factory $HomeBuildableCopyWith(
          HomeBuildable value, $Res Function(HomeBuildable) then) =
      _$HomeBuildableCopyWithImpl<$Res, HomeBuildable>;
  @useResult
  $Res call(
      {bool isSelected, bool isLoading, bool success, HomeModel? homeModel});

  $HomeModelCopyWith<$Res>? get homeModel;
}

/// @nodoc
class _$HomeBuildableCopyWithImpl<$Res, $Val extends HomeBuildable>
    implements $HomeBuildableCopyWith<$Res> {
  _$HomeBuildableCopyWithImpl(this._value, this._then);

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
              as HomeModel?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomeModelCopyWith<$Res>? get homeModel {
    if (_value.homeModel == null) {
      return null;
    }

    return $HomeModelCopyWith<$Res>(_value.homeModel!, (value) {
      return _then(_value.copyWith(homeModel: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeBuildableImplCopyWith<$Res>
    implements $HomeBuildableCopyWith<$Res> {
  factory _$$HomeBuildableImplCopyWith(
          _$HomeBuildableImpl value, $Res Function(_$HomeBuildableImpl) then) =
      __$$HomeBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSelected, bool isLoading, bool success, HomeModel? homeModel});

  @override
  $HomeModelCopyWith<$Res>? get homeModel;
}

/// @nodoc
class __$$HomeBuildableImplCopyWithImpl<$Res>
    extends _$HomeBuildableCopyWithImpl<$Res, _$HomeBuildableImpl>
    implements _$$HomeBuildableImplCopyWith<$Res> {
  __$$HomeBuildableImplCopyWithImpl(
      _$HomeBuildableImpl _value, $Res Function(_$HomeBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? success = null,
    Object? homeModel = freezed,
  }) {
    return _then(_$HomeBuildableImpl(
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
              as HomeModel?,
    ));
  }
}

/// @nodoc

class _$HomeBuildableImpl implements _HomeBuildable {
  const _$HomeBuildableImpl(
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
  final HomeModel? homeModel;

  @override
  String toString() {
    return 'HomeBuildable(isSelected: $isSelected, isLoading: $isLoading, success: $success, homeModel: $homeModel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeBuildableImpl &&
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
  _$$HomeBuildableImplCopyWith<_$HomeBuildableImpl> get copyWith =>
      __$$HomeBuildableImplCopyWithImpl<_$HomeBuildableImpl>(this, _$identity);
}

abstract class _HomeBuildable implements HomeBuildable {
  const factory _HomeBuildable(
      {final bool isSelected,
      final bool isLoading,
      final bool success,
      final HomeModel? homeModel}) = _$HomeBuildableImpl;

  @override
  bool get isSelected;
  @override
  bool get isLoading;
  @override
  bool get success;
  @override
  HomeModel? get homeModel;
  @override
  @JsonKey(ignore: true)
  _$$HomeBuildableImplCopyWith<_$HomeBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HomeListenable {
  HomeEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeListenableCopyWith<HomeListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeListenableCopyWith<$Res> {
  factory $HomeListenableCopyWith(
          HomeListenable value, $Res Function(HomeListenable) then) =
      _$HomeListenableCopyWithImpl<$Res, HomeListenable>;
  @useResult
  $Res call({HomeEffect effect});
}

/// @nodoc
class _$HomeListenableCopyWithImpl<$Res, $Val extends HomeListenable>
    implements $HomeListenableCopyWith<$Res> {
  _$HomeListenableCopyWithImpl(this._value, this._then);

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
              as HomeEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeListenableImplCopyWith<$Res>
    implements $HomeListenableCopyWith<$Res> {
  factory _$$HomeListenableImplCopyWith(_$HomeListenableImpl value,
          $Res Function(_$HomeListenableImpl) then) =
      __$$HomeListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({HomeEffect effect});
}

/// @nodoc
class __$$HomeListenableImplCopyWithImpl<$Res>
    extends _$HomeListenableCopyWithImpl<$Res, _$HomeListenableImpl>
    implements _$$HomeListenableImplCopyWith<$Res> {
  __$$HomeListenableImplCopyWithImpl(
      _$HomeListenableImpl _value, $Res Function(_$HomeListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$HomeListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as HomeEffect,
    ));
  }
}

/// @nodoc

class _$HomeListenableImpl implements _HomeListenable {
  const _$HomeListenableImpl({required this.effect});

  @override
  final HomeEffect effect;

  @override
  String toString() {
    return 'HomeListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeListenableImplCopyWith<_$HomeListenableImpl> get copyWith =>
      __$$HomeListenableImplCopyWithImpl<_$HomeListenableImpl>(
          this, _$identity);
}

abstract class _HomeListenable implements HomeListenable {
  const factory _HomeListenable({required final HomeEffect effect}) =
      _$HomeListenableImpl;

  @override
  HomeEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$HomeListenableImplCopyWith<_$HomeListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

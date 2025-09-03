// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'children_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ChildrenBuildable {
  bool get isLoading => throw _privateConstructorUsedError;
  int get selectedIndex => throw _privateConstructorUsedError;
  HomForUser? get homeModel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChildrenBuildableCopyWith<ChildrenBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildrenBuildableCopyWith<$Res> {
  factory $ChildrenBuildableCopyWith(
          ChildrenBuildable value, $Res Function(ChildrenBuildable) then) =
      _$ChildrenBuildableCopyWithImpl<$Res, ChildrenBuildable>;
  @useResult
  $Res call({bool isLoading, int selectedIndex, HomForUser? homeModel});

  $HomForUserCopyWith<$Res>? get homeModel;
}

/// @nodoc
class _$ChildrenBuildableCopyWithImpl<$Res, $Val extends ChildrenBuildable>
    implements $ChildrenBuildableCopyWith<$Res> {
  _$ChildrenBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? selectedIndex = null,
    Object? homeModel = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedIndex: null == selectedIndex
          ? _value.selectedIndex
          : selectedIndex // ignore: cast_nullable_to_non_nullable
              as int,
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
abstract class _$$ChildrenBuildableImplCopyWith<$Res>
    implements $ChildrenBuildableCopyWith<$Res> {
  factory _$$ChildrenBuildableImplCopyWith(_$ChildrenBuildableImpl value,
          $Res Function(_$ChildrenBuildableImpl) then) =
      __$$ChildrenBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, int selectedIndex, HomForUser? homeModel});

  @override
  $HomForUserCopyWith<$Res>? get homeModel;
}

/// @nodoc
class __$$ChildrenBuildableImplCopyWithImpl<$Res>
    extends _$ChildrenBuildableCopyWithImpl<$Res, _$ChildrenBuildableImpl>
    implements _$$ChildrenBuildableImplCopyWith<$Res> {
  __$$ChildrenBuildableImplCopyWithImpl(_$ChildrenBuildableImpl _value,
      $Res Function(_$ChildrenBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? selectedIndex = null,
    Object? homeModel = freezed,
  }) {
    return _then(_$ChildrenBuildableImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedIndex: null == selectedIndex
          ? _value.selectedIndex
          : selectedIndex // ignore: cast_nullable_to_non_nullable
              as int,
      homeModel: freezed == homeModel
          ? _value.homeModel
          : homeModel // ignore: cast_nullable_to_non_nullable
              as HomForUser?,
    ));
  }
}

/// @nodoc

class _$ChildrenBuildableImpl implements _ChildrenBuildable {
  const _$ChildrenBuildableImpl(
      {this.isLoading = false, this.selectedIndex = 0, this.homeModel});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final int selectedIndex;
  @override
  final HomForUser? homeModel;

  @override
  String toString() {
    return 'ChildrenBuildable(isLoading: $isLoading, selectedIndex: $selectedIndex, homeModel: $homeModel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildrenBuildableImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.selectedIndex, selectedIndex) ||
                other.selectedIndex == selectedIndex) &&
            (identical(other.homeModel, homeModel) ||
                other.homeModel == homeModel));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isLoading, selectedIndex, homeModel);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildrenBuildableImplCopyWith<_$ChildrenBuildableImpl> get copyWith =>
      __$$ChildrenBuildableImplCopyWithImpl<_$ChildrenBuildableImpl>(
          this, _$identity);
}

abstract class _ChildrenBuildable implements ChildrenBuildable {
  const factory _ChildrenBuildable(
      {final bool isLoading,
      final int selectedIndex,
      final HomForUser? homeModel}) = _$ChildrenBuildableImpl;

  @override
  bool get isLoading;
  @override
  int get selectedIndex;
  @override
  HomForUser? get homeModel;
  @override
  @JsonKey(ignore: true)
  _$$ChildrenBuildableImplCopyWith<_$ChildrenBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ChildrenListenable {
  ChildrenEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ChildrenListenableCopyWith<ChildrenListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChildrenListenableCopyWith<$Res> {
  factory $ChildrenListenableCopyWith(
          ChildrenListenable value, $Res Function(ChildrenListenable) then) =
      _$ChildrenListenableCopyWithImpl<$Res, ChildrenListenable>;
  @useResult
  $Res call({ChildrenEffect effect});
}

/// @nodoc
class _$ChildrenListenableCopyWithImpl<$Res, $Val extends ChildrenListenable>
    implements $ChildrenListenableCopyWith<$Res> {
  _$ChildrenListenableCopyWithImpl(this._value, this._then);

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
              as ChildrenEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChildrenListenableImplCopyWith<$Res>
    implements $ChildrenListenableCopyWith<$Res> {
  factory _$$ChildrenListenableImplCopyWith(_$ChildrenListenableImpl value,
          $Res Function(_$ChildrenListenableImpl) then) =
      __$$ChildrenListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ChildrenEffect effect});
}

/// @nodoc
class __$$ChildrenListenableImplCopyWithImpl<$Res>
    extends _$ChildrenListenableCopyWithImpl<$Res, _$ChildrenListenableImpl>
    implements _$$ChildrenListenableImplCopyWith<$Res> {
  __$$ChildrenListenableImplCopyWithImpl(_$ChildrenListenableImpl _value,
      $Res Function(_$ChildrenListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$ChildrenListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as ChildrenEffect,
    ));
  }
}

/// @nodoc

class _$ChildrenListenableImpl implements _ChildrenListenable {
  const _$ChildrenListenableImpl({required this.effect});

  @override
  final ChildrenEffect effect;

  @override
  String toString() {
    return 'ChildrenListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChildrenListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ChildrenListenableImplCopyWith<_$ChildrenListenableImpl> get copyWith =>
      __$$ChildrenListenableImplCopyWithImpl<_$ChildrenListenableImpl>(
          this, _$identity);
}

abstract class _ChildrenListenable implements ChildrenListenable {
  const factory _ChildrenListenable({required final ChildrenEffect effect}) =
      _$ChildrenListenableImpl;

  @override
  ChildrenEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$ChildrenListenableImplCopyWith<_$ChildrenListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

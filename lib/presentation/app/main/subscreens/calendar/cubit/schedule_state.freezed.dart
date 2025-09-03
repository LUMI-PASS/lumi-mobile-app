// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'schedule_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ScheduleBuildable {
  bool get isSelected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  List<ScheduleItem>? get homeModel => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScheduleBuildableCopyWith<ScheduleBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleBuildableCopyWith<$Res> {
  factory $ScheduleBuildableCopyWith(
          ScheduleBuildable value, $Res Function(ScheduleBuildable) then) =
      _$ScheduleBuildableCopyWithImpl<$Res, ScheduleBuildable>;
  @useResult
  $Res call(
      {bool isSelected,
      bool isLoading,
      bool success,
      List<ScheduleItem>? homeModel});
}

/// @nodoc
class _$ScheduleBuildableCopyWithImpl<$Res, $Val extends ScheduleBuildable>
    implements $ScheduleBuildableCopyWith<$Res> {
  _$ScheduleBuildableCopyWithImpl(this._value, this._then);

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
              as List<ScheduleItem>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleBuildableImplCopyWith<$Res>
    implements $ScheduleBuildableCopyWith<$Res> {
  factory _$$ScheduleBuildableImplCopyWith(_$ScheduleBuildableImpl value,
          $Res Function(_$ScheduleBuildableImpl) then) =
      __$$ScheduleBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSelected,
      bool isLoading,
      bool success,
      List<ScheduleItem>? homeModel});
}

/// @nodoc
class __$$ScheduleBuildableImplCopyWithImpl<$Res>
    extends _$ScheduleBuildableCopyWithImpl<$Res, _$ScheduleBuildableImpl>
    implements _$$ScheduleBuildableImplCopyWith<$Res> {
  __$$ScheduleBuildableImplCopyWithImpl(_$ScheduleBuildableImpl _value,
      $Res Function(_$ScheduleBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? success = null,
    Object? homeModel = freezed,
  }) {
    return _then(_$ScheduleBuildableImpl(
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
          ? _value._homeModel
          : homeModel // ignore: cast_nullable_to_non_nullable
              as List<ScheduleItem>?,
    ));
  }
}

/// @nodoc

class _$ScheduleBuildableImpl implements _ScheduleBuildable {
  const _$ScheduleBuildableImpl(
      {this.isSelected = false,
      this.isLoading = false,
      this.success = false,
      final List<ScheduleItem>? homeModel})
      : _homeModel = homeModel;

  @override
  @JsonKey()
  final bool isSelected;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool success;
  final List<ScheduleItem>? _homeModel;
  @override
  List<ScheduleItem>? get homeModel {
    final value = _homeModel;
    if (value == null) return null;
    if (_homeModel is EqualUnmodifiableListView) return _homeModel;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'ScheduleBuildable(isSelected: $isSelected, isLoading: $isLoading, success: $success, homeModel: $homeModel)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleBuildableImpl &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality()
                .equals(other._homeModel, _homeModel));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isSelected, isLoading, success,
      const DeepCollectionEquality().hash(_homeModel));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleBuildableImplCopyWith<_$ScheduleBuildableImpl> get copyWith =>
      __$$ScheduleBuildableImplCopyWithImpl<_$ScheduleBuildableImpl>(
          this, _$identity);
}

abstract class _ScheduleBuildable implements ScheduleBuildable {
  const factory _ScheduleBuildable(
      {final bool isSelected,
      final bool isLoading,
      final bool success,
      final List<ScheduleItem>? homeModel}) = _$ScheduleBuildableImpl;

  @override
  bool get isSelected;
  @override
  bool get isLoading;
  @override
  bool get success;
  @override
  List<ScheduleItem>? get homeModel;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleBuildableImplCopyWith<_$ScheduleBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ScheduleListenable {
  ScheduleEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ScheduleListenableCopyWith<ScheduleListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScheduleListenableCopyWith<$Res> {
  factory $ScheduleListenableCopyWith(
          ScheduleListenable value, $Res Function(ScheduleListenable) then) =
      _$ScheduleListenableCopyWithImpl<$Res, ScheduleListenable>;
  @useResult
  $Res call({ScheduleEffect effect});
}

/// @nodoc
class _$ScheduleListenableCopyWithImpl<$Res, $Val extends ScheduleListenable>
    implements $ScheduleListenableCopyWith<$Res> {
  _$ScheduleListenableCopyWithImpl(this._value, this._then);

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
              as ScheduleEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScheduleListenableImplCopyWith<$Res>
    implements $ScheduleListenableCopyWith<$Res> {
  factory _$$ScheduleListenableImplCopyWith(_$ScheduleListenableImpl value,
          $Res Function(_$ScheduleListenableImpl) then) =
      __$$ScheduleListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ScheduleEffect effect});
}

/// @nodoc
class __$$ScheduleListenableImplCopyWithImpl<$Res>
    extends _$ScheduleListenableCopyWithImpl<$Res, _$ScheduleListenableImpl>
    implements _$$ScheduleListenableImplCopyWith<$Res> {
  __$$ScheduleListenableImplCopyWithImpl(_$ScheduleListenableImpl _value,
      $Res Function(_$ScheduleListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$ScheduleListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as ScheduleEffect,
    ));
  }
}

/// @nodoc

class _$ScheduleListenableImpl implements _ScheduleListenable {
  const _$ScheduleListenableImpl({required this.effect});

  @override
  final ScheduleEffect effect;

  @override
  String toString() {
    return 'ScheduleListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleListenableImplCopyWith<_$ScheduleListenableImpl> get copyWith =>
      __$$ScheduleListenableImplCopyWithImpl<_$ScheduleListenableImpl>(
          this, _$identity);
}

abstract class _ScheduleListenable implements ScheduleListenable {
  const factory _ScheduleListenable({required final ScheduleEffect effect}) =
      _$ScheduleListenableImpl;

  @override
  ScheduleEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$ScheduleListenableImplCopyWith<_$ScheduleListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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
  bool get isLoading => throw _privateConstructorUsedError;
  List<UserOrder> get orders => throw _privateConstructorUsedError;

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
  $Res call({bool isLoading, List<UserOrder> orders});
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
    Object? isLoading = null,
    Object? orders = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      orders: null == orders
          ? _value.orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<UserOrder>,
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
  $Res call({bool isLoading, List<UserOrder> orders});
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
    Object? isLoading = null,
    Object? orders = null,
  }) {
    return _then(_$ScheduleBuildableImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      orders: null == orders
          ? _value._orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<UserOrder>,
    ));
  }
}

/// @nodoc

class _$ScheduleBuildableImpl implements _ScheduleBuildable {
  const _$ScheduleBuildableImpl(
      {this.isLoading = false, final List<UserOrder> orders = const []})
      : _orders = orders;

  @override
  @JsonKey()
  final bool isLoading;
  final List<UserOrder> _orders;
  @override
  @JsonKey()
  List<UserOrder> get orders {
    if (_orders is EqualUnmodifiableListView) return _orders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orders);
  }

  @override
  String toString() {
    return 'ScheduleBuildable(isLoading: $isLoading, orders: $orders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScheduleBuildableImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality().equals(other._orders, _orders));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, isLoading, const DeepCollectionEquality().hash(_orders));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ScheduleBuildableImplCopyWith<_$ScheduleBuildableImpl> get copyWith =>
      __$$ScheduleBuildableImplCopyWithImpl<_$ScheduleBuildableImpl>(
          this, _$identity);
}

abstract class _ScheduleBuildable implements ScheduleBuildable {
  const factory _ScheduleBuildable(
      {final bool isLoading,
      final List<UserOrder> orders}) = _$ScheduleBuildableImpl;

  @override
  bool get isLoading;
  @override
  List<UserOrder> get orders;
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

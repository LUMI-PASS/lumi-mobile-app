// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WalletBuildable {
  bool get isSelected => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  List<Tariff>? get tariffs => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WalletBuildableCopyWith<WalletBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletBuildableCopyWith<$Res> {
  factory $WalletBuildableCopyWith(
          WalletBuildable value, $Res Function(WalletBuildable) then) =
      _$WalletBuildableCopyWithImpl<$Res, WalletBuildable>;
  @useResult
  $Res call(
      {bool isSelected, bool isLoading, bool success, List<Tariff>? tariffs});
}

/// @nodoc
class _$WalletBuildableCopyWithImpl<$Res, $Val extends WalletBuildable>
    implements $WalletBuildableCopyWith<$Res> {
  _$WalletBuildableCopyWithImpl(this._value, this._then);

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
    Object? tariffs = freezed,
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
      tariffs: freezed == tariffs
          ? _value.tariffs
          : tariffs // ignore: cast_nullable_to_non_nullable
              as List<Tariff>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletBuildableImplCopyWith<$Res>
    implements $WalletBuildableCopyWith<$Res> {
  factory _$$WalletBuildableImplCopyWith(_$WalletBuildableImpl value,
          $Res Function(_$WalletBuildableImpl) then) =
      __$$WalletBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSelected, bool isLoading, bool success, List<Tariff>? tariffs});
}

/// @nodoc
class __$$WalletBuildableImplCopyWithImpl<$Res>
    extends _$WalletBuildableCopyWithImpl<$Res, _$WalletBuildableImpl>
    implements _$$WalletBuildableImplCopyWith<$Res> {
  __$$WalletBuildableImplCopyWithImpl(
      _$WalletBuildableImpl _value, $Res Function(_$WalletBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? success = null,
    Object? tariffs = freezed,
  }) {
    return _then(_$WalletBuildableImpl(
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
      tariffs: freezed == tariffs
          ? _value._tariffs
          : tariffs // ignore: cast_nullable_to_non_nullable
              as List<Tariff>?,
    ));
  }
}

/// @nodoc

class _$WalletBuildableImpl implements _WalletBuildable {
  const _$WalletBuildableImpl(
      {this.isSelected = false,
      this.isLoading = false,
      this.success = false,
      final List<Tariff>? tariffs})
      : _tariffs = tariffs;

  @override
  @JsonKey()
  final bool isSelected;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool success;
  final List<Tariff>? _tariffs;
  @override
  List<Tariff>? get tariffs {
    final value = _tariffs;
    if (value == null) return null;
    if (_tariffs is EqualUnmodifiableListView) return _tariffs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'WalletBuildable(isSelected: $isSelected, isLoading: $isLoading, success: $success, tariffs: $tariffs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletBuildableImpl &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._tariffs, _tariffs));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isSelected, isLoading, success,
      const DeepCollectionEquality().hash(_tariffs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletBuildableImplCopyWith<_$WalletBuildableImpl> get copyWith =>
      __$$WalletBuildableImplCopyWithImpl<_$WalletBuildableImpl>(
          this, _$identity);
}

abstract class _WalletBuildable implements WalletBuildable {
  const factory _WalletBuildable(
      {final bool isSelected,
      final bool isLoading,
      final bool success,
      final List<Tariff>? tariffs}) = _$WalletBuildableImpl;

  @override
  bool get isSelected;
  @override
  bool get isLoading;
  @override
  bool get success;
  @override
  List<Tariff>? get tariffs;
  @override
  @JsonKey(ignore: true)
  _$$WalletBuildableImplCopyWith<_$WalletBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WalletListenable {
  WalletEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WalletListenableCopyWith<WalletListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletListenableCopyWith<$Res> {
  factory $WalletListenableCopyWith(
          WalletListenable value, $Res Function(WalletListenable) then) =
      _$WalletListenableCopyWithImpl<$Res, WalletListenable>;
  @useResult
  $Res call({WalletEffect effect});
}

/// @nodoc
class _$WalletListenableCopyWithImpl<$Res, $Val extends WalletListenable>
    implements $WalletListenableCopyWith<$Res> {
  _$WalletListenableCopyWithImpl(this._value, this._then);

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
              as WalletEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletListenableImplCopyWith<$Res>
    implements $WalletListenableCopyWith<$Res> {
  factory _$$WalletListenableImplCopyWith(_$WalletListenableImpl value,
          $Res Function(_$WalletListenableImpl) then) =
      __$$WalletListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({WalletEffect effect});
}

/// @nodoc
class __$$WalletListenableImplCopyWithImpl<$Res>
    extends _$WalletListenableCopyWithImpl<$Res, _$WalletListenableImpl>
    implements _$$WalletListenableImplCopyWith<$Res> {
  __$$WalletListenableImplCopyWithImpl(_$WalletListenableImpl _value,
      $Res Function(_$WalletListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$WalletListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as WalletEffect,
    ));
  }
}

/// @nodoc

class _$WalletListenableImpl implements _WalletListenable {
  const _$WalletListenableImpl({required this.effect});

  @override
  final WalletEffect effect;

  @override
  String toString() {
    return 'WalletListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletListenableImplCopyWith<_$WalletListenableImpl> get copyWith =>
      __$$WalletListenableImplCopyWithImpl<_$WalletListenableImpl>(
          this, _$identity);
}

abstract class _WalletListenable implements WalletListenable {
  const factory _WalletListenable({required final WalletEffect effect}) =
      _$WalletListenableImpl;

  @override
  WalletEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$WalletListenableImplCopyWith<_$WalletListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

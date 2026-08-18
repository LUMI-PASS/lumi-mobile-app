// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'my_cards_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MyCardsBuildable {
  bool get isLoading => throw _privateConstructorUsedError;

  /// Set when the list itself couldn't be read. Distinct from a failed
  /// delete, which leaves the list intact and only shows a toast.
  String? get error => throw _privateConstructorUsedError;
  List<SavedCard> get cards => throw _privateConstructorUsedError;

  /// The row currently being deleted — fades it and swaps its trash icon for
  /// a spinner, so a slow gateway doesn't look like a dead tap.
  String? get removingId => throw _privateConstructorUsedError;

  /// False when the server says card management is unavailable (503 — the
  /// gateway or the encryption key isn't configured). The screen then
  /// explains that instead of offering an Add button that can't work.
  bool get isAvailable => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MyCardsBuildableCopyWith<MyCardsBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyCardsBuildableCopyWith<$Res> {
  factory $MyCardsBuildableCopyWith(
          MyCardsBuildable value, $Res Function(MyCardsBuildable) then) =
      _$MyCardsBuildableCopyWithImpl<$Res, MyCardsBuildable>;
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      List<SavedCard> cards,
      String? removingId,
      bool isAvailable});
}

/// @nodoc
class _$MyCardsBuildableCopyWithImpl<$Res, $Val extends MyCardsBuildable>
    implements $MyCardsBuildableCopyWith<$Res> {
  _$MyCardsBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? cards = null,
    Object? removingId = freezed,
    Object? isAvailable = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      cards: null == cards
          ? _value.cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<SavedCard>,
      removingId: freezed == removingId
          ? _value.removingId
          : removingId // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MyCardsBuildableImplCopyWith<$Res>
    implements $MyCardsBuildableCopyWith<$Res> {
  factory _$$MyCardsBuildableImplCopyWith(_$MyCardsBuildableImpl value,
          $Res Function(_$MyCardsBuildableImpl) then) =
      __$$MyCardsBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      String? error,
      List<SavedCard> cards,
      String? removingId,
      bool isAvailable});
}

/// @nodoc
class __$$MyCardsBuildableImplCopyWithImpl<$Res>
    extends _$MyCardsBuildableCopyWithImpl<$Res, _$MyCardsBuildableImpl>
    implements _$$MyCardsBuildableImplCopyWith<$Res> {
  __$$MyCardsBuildableImplCopyWithImpl(_$MyCardsBuildableImpl _value,
      $Res Function(_$MyCardsBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? error = freezed,
    Object? cards = null,
    Object? removingId = freezed,
    Object? isAvailable = null,
  }) {
    return _then(_$MyCardsBuildableImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      cards: null == cards
          ? _value._cards
          : cards // ignore: cast_nullable_to_non_nullable
              as List<SavedCard>,
      removingId: freezed == removingId
          ? _value.removingId
          : removingId // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$MyCardsBuildableImpl extends _MyCardsBuildable {
  const _$MyCardsBuildableImpl(
      {this.isLoading = true,
      this.error,
      final List<SavedCard> cards = const [],
      this.removingId,
      this.isAvailable = true})
      : _cards = cards,
        super._();

  @override
  @JsonKey()
  final bool isLoading;

  /// Set when the list itself couldn't be read. Distinct from a failed
  /// delete, which leaves the list intact and only shows a toast.
  @override
  final String? error;
  final List<SavedCard> _cards;
  @override
  @JsonKey()
  List<SavedCard> get cards {
    if (_cards is EqualUnmodifiableListView) return _cards;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cards);
  }

  /// The row currently being deleted — fades it and swaps its trash icon for
  /// a spinner, so a slow gateway doesn't look like a dead tap.
  @override
  final String? removingId;

  /// False when the server says card management is unavailable (503 — the
  /// gateway or the encryption key isn't configured). The screen then
  /// explains that instead of offering an Add button that can't work.
  @override
  @JsonKey()
  final bool isAvailable;

  @override
  String toString() {
    return 'MyCardsBuildable(isLoading: $isLoading, error: $error, cards: $cards, removingId: $removingId, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyCardsBuildableImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality().equals(other._cards, _cards) &&
            (identical(other.removingId, removingId) ||
                other.removingId == removingId) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, error,
      const DeepCollectionEquality().hash(_cards), removingId, isAvailable);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MyCardsBuildableImplCopyWith<_$MyCardsBuildableImpl> get copyWith =>
      __$$MyCardsBuildableImplCopyWithImpl<_$MyCardsBuildableImpl>(
          this, _$identity);
}

abstract class _MyCardsBuildable extends MyCardsBuildable {
  const factory _MyCardsBuildable(
      {final bool isLoading,
      final String? error,
      final List<SavedCard> cards,
      final String? removingId,
      final bool isAvailable}) = _$MyCardsBuildableImpl;
  const _MyCardsBuildable._() : super._();

  @override
  bool get isLoading;
  @override

  /// Set when the list itself couldn't be read. Distinct from a failed
  /// delete, which leaves the list intact and only shows a toast.
  String? get error;
  @override
  List<SavedCard> get cards;
  @override

  /// The row currently being deleted — fades it and swaps its trash icon for
  /// a spinner, so a slow gateway doesn't look like a dead tap.
  String? get removingId;
  @override

  /// False when the server says card management is unavailable (503 — the
  /// gateway or the encryption key isn't configured). The screen then
  /// explains that instead of offering an Add button that can't work.
  bool get isAvailable;
  @override
  @JsonKey(ignore: true)
  _$$MyCardsBuildableImplCopyWith<_$MyCardsBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$MyCardsListenable {
  MyCardsEffect get effect => throw _privateConstructorUsedError;

  /// Message for [MyCardsEffect.deleteFailed].
  String? get message => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MyCardsListenableCopyWith<MyCardsListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MyCardsListenableCopyWith<$Res> {
  factory $MyCardsListenableCopyWith(
          MyCardsListenable value, $Res Function(MyCardsListenable) then) =
      _$MyCardsListenableCopyWithImpl<$Res, MyCardsListenable>;
  @useResult
  $Res call({MyCardsEffect effect, String? message});
}

/// @nodoc
class _$MyCardsListenableCopyWithImpl<$Res, $Val extends MyCardsListenable>
    implements $MyCardsListenableCopyWith<$Res> {
  _$MyCardsListenableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
    Object? message = freezed,
  }) {
    return _then(_value.copyWith(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as MyCardsEffect,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MyCardsListenableImplCopyWith<$Res>
    implements $MyCardsListenableCopyWith<$Res> {
  factory _$$MyCardsListenableImplCopyWith(_$MyCardsListenableImpl value,
          $Res Function(_$MyCardsListenableImpl) then) =
      __$$MyCardsListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({MyCardsEffect effect, String? message});
}

/// @nodoc
class __$$MyCardsListenableImplCopyWithImpl<$Res>
    extends _$MyCardsListenableCopyWithImpl<$Res, _$MyCardsListenableImpl>
    implements _$$MyCardsListenableImplCopyWith<$Res> {
  __$$MyCardsListenableImplCopyWithImpl(_$MyCardsListenableImpl _value,
      $Res Function(_$MyCardsListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
    Object? message = freezed,
  }) {
    return _then(_$MyCardsListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as MyCardsEffect,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MyCardsListenableImpl implements _MyCardsListenable {
  const _$MyCardsListenableImpl({required this.effect, this.message});

  @override
  final MyCardsEffect effect;

  /// Message for [MyCardsEffect.deleteFailed].
  @override
  final String? message;

  @override
  String toString() {
    return 'MyCardsListenable(effect: $effect, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MyCardsListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MyCardsListenableImplCopyWith<_$MyCardsListenableImpl> get copyWith =>
      __$$MyCardsListenableImplCopyWithImpl<_$MyCardsListenableImpl>(
          this, _$identity);
}

abstract class _MyCardsListenable implements MyCardsListenable {
  const factory _MyCardsListenable(
      {required final MyCardsEffect effect,
      final String? message}) = _$MyCardsListenableImpl;

  @override
  MyCardsEffect get effect;
  @override

  /// Message for [MyCardsEffect.deleteFailed].
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$MyCardsListenableImplCopyWith<_$MyCardsListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

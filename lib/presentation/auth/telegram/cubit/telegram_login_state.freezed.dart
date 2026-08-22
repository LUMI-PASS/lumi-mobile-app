// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'telegram_login_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TelegramLoginBuildable {
  /// Opening the bot chat, before the user has anywhere to type a code.
  bool get openingBot => throw _privateConstructorUsedError;
  bool get loading => throw _privateConstructorUsedError;

  /// Digits the bot's code has. The server owns this number; 6 is only the
  /// value assumed until /telegram/link answers.
  int get codeLength => throw _privateConstructorUsedError;
  String? get botUsername => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// What is currently in the code field. Held here so the Confirm button
  /// enables as the user types — a TextEditingController read during build
  /// is a snapshot, and nothing rebuilds when it changes.
  String get code => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TelegramLoginBuildableCopyWith<TelegramLoginBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TelegramLoginBuildableCopyWith<$Res> {
  factory $TelegramLoginBuildableCopyWith(TelegramLoginBuildable value,
          $Res Function(TelegramLoginBuildable) then) =
      _$TelegramLoginBuildableCopyWithImpl<$Res, TelegramLoginBuildable>;
  @useResult
  $Res call(
      {bool openingBot,
      bool loading,
      int codeLength,
      String? botUsername,
      String? error,
      String code});
}

/// @nodoc
class _$TelegramLoginBuildableCopyWithImpl<$Res,
        $Val extends TelegramLoginBuildable>
    implements $TelegramLoginBuildableCopyWith<$Res> {
  _$TelegramLoginBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? openingBot = null,
    Object? loading = null,
    Object? codeLength = null,
    Object? botUsername = freezed,
    Object? error = freezed,
    Object? code = null,
  }) {
    return _then(_value.copyWith(
      openingBot: null == openingBot
          ? _value.openingBot
          : openingBot // ignore: cast_nullable_to_non_nullable
              as bool,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      codeLength: null == codeLength
          ? _value.codeLength
          : codeLength // ignore: cast_nullable_to_non_nullable
              as int,
      botUsername: freezed == botUsername
          ? _value.botUsername
          : botUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TelegramLoginBuildableImplCopyWith<$Res>
    implements $TelegramLoginBuildableCopyWith<$Res> {
  factory _$$TelegramLoginBuildableImplCopyWith(
          _$TelegramLoginBuildableImpl value,
          $Res Function(_$TelegramLoginBuildableImpl) then) =
      __$$TelegramLoginBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool openingBot,
      bool loading,
      int codeLength,
      String? botUsername,
      String? error,
      String code});
}

/// @nodoc
class __$$TelegramLoginBuildableImplCopyWithImpl<$Res>
    extends _$TelegramLoginBuildableCopyWithImpl<$Res,
        _$TelegramLoginBuildableImpl>
    implements _$$TelegramLoginBuildableImplCopyWith<$Res> {
  __$$TelegramLoginBuildableImplCopyWithImpl(
      _$TelegramLoginBuildableImpl _value,
      $Res Function(_$TelegramLoginBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? openingBot = null,
    Object? loading = null,
    Object? codeLength = null,
    Object? botUsername = freezed,
    Object? error = freezed,
    Object? code = null,
  }) {
    return _then(_$TelegramLoginBuildableImpl(
      openingBot: null == openingBot
          ? _value.openingBot
          : openingBot // ignore: cast_nullable_to_non_nullable
              as bool,
      loading: null == loading
          ? _value.loading
          : loading // ignore: cast_nullable_to_non_nullable
              as bool,
      codeLength: null == codeLength
          ? _value.codeLength
          : codeLength // ignore: cast_nullable_to_non_nullable
              as int,
      botUsername: freezed == botUsername
          ? _value.botUsername
          : botUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TelegramLoginBuildableImpl implements _TelegramLoginBuildable {
  const _$TelegramLoginBuildableImpl(
      {this.openingBot = false,
      this.loading = false,
      this.codeLength = 6,
      this.botUsername = null,
      this.error = null,
      this.code = ''});

  /// Opening the bot chat, before the user has anywhere to type a code.
  @override
  @JsonKey()
  final bool openingBot;
  @override
  @JsonKey()
  final bool loading;

  /// Digits the bot's code has. The server owns this number; 6 is only the
  /// value assumed until /telegram/link answers.
  @override
  @JsonKey()
  final int codeLength;
  @override
  @JsonKey()
  final String? botUsername;
  @override
  @JsonKey()
  final String? error;

  /// What is currently in the code field. Held here so the Confirm button
  /// enables as the user types — a TextEditingController read during build
  /// is a snapshot, and nothing rebuilds when it changes.
  @override
  @JsonKey()
  final String code;

  @override
  String toString() {
    return 'TelegramLoginBuildable(openingBot: $openingBot, loading: $loading, codeLength: $codeLength, botUsername: $botUsername, error: $error, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelegramLoginBuildableImpl &&
            (identical(other.openingBot, openingBot) ||
                other.openingBot == openingBot) &&
            (identical(other.loading, loading) || other.loading == loading) &&
            (identical(other.codeLength, codeLength) ||
                other.codeLength == codeLength) &&
            (identical(other.botUsername, botUsername) ||
                other.botUsername == botUsername) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.code, code) || other.code == code));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, openingBot, loading, codeLength, botUsername, error, code);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TelegramLoginBuildableImplCopyWith<_$TelegramLoginBuildableImpl>
      get copyWith => __$$TelegramLoginBuildableImplCopyWithImpl<
          _$TelegramLoginBuildableImpl>(this, _$identity);
}

abstract class _TelegramLoginBuildable implements TelegramLoginBuildable {
  const factory _TelegramLoginBuildable(
      {final bool openingBot,
      final bool loading,
      final int codeLength,
      final String? botUsername,
      final String? error,
      final String code}) = _$TelegramLoginBuildableImpl;

  @override

  /// Opening the bot chat, before the user has anywhere to type a code.
  bool get openingBot;
  @override
  bool get loading;
  @override

  /// Digits the bot's code has. The server owns this number; 6 is only the
  /// value assumed until /telegram/link answers.
  int get codeLength;
  @override
  String? get botUsername;
  @override
  String? get error;
  @override

  /// What is currently in the code field. Held here so the Confirm button
  /// enables as the user types — a TextEditingController read during build
  /// is a snapshot, and nothing rebuilds when it changes.
  String get code;
  @override
  @JsonKey(ignore: true)
  _$$TelegramLoginBuildableImplCopyWith<_$TelegramLoginBuildableImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TelegramLoginListenable {
  TelegramLoginEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TelegramLoginListenableCopyWith<TelegramLoginListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TelegramLoginListenableCopyWith<$Res> {
  factory $TelegramLoginListenableCopyWith(TelegramLoginListenable value,
          $Res Function(TelegramLoginListenable) then) =
      _$TelegramLoginListenableCopyWithImpl<$Res, TelegramLoginListenable>;
  @useResult
  $Res call({TelegramLoginEffect effect});
}

/// @nodoc
class _$TelegramLoginListenableCopyWithImpl<$Res,
        $Val extends TelegramLoginListenable>
    implements $TelegramLoginListenableCopyWith<$Res> {
  _$TelegramLoginListenableCopyWithImpl(this._value, this._then);

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
              as TelegramLoginEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TelegramLoginListenableImplCopyWith<$Res>
    implements $TelegramLoginListenableCopyWith<$Res> {
  factory _$$TelegramLoginListenableImplCopyWith(
          _$TelegramLoginListenableImpl value,
          $Res Function(_$TelegramLoginListenableImpl) then) =
      __$$TelegramLoginListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({TelegramLoginEffect effect});
}

/// @nodoc
class __$$TelegramLoginListenableImplCopyWithImpl<$Res>
    extends _$TelegramLoginListenableCopyWithImpl<$Res,
        _$TelegramLoginListenableImpl>
    implements _$$TelegramLoginListenableImplCopyWith<$Res> {
  __$$TelegramLoginListenableImplCopyWithImpl(
      _$TelegramLoginListenableImpl _value,
      $Res Function(_$TelegramLoginListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$TelegramLoginListenableImpl(
      null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as TelegramLoginEffect,
    ));
  }
}

/// @nodoc

class _$TelegramLoginListenableImpl implements _TelegramLoginListenable {
  const _$TelegramLoginListenableImpl(this.effect);

  @override
  final TelegramLoginEffect effect;

  @override
  String toString() {
    return 'TelegramLoginListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TelegramLoginListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TelegramLoginListenableImplCopyWith<_$TelegramLoginListenableImpl>
      get copyWith => __$$TelegramLoginListenableImplCopyWithImpl<
          _$TelegramLoginListenableImpl>(this, _$identity);
}

abstract class _TelegramLoginListenable implements TelegramLoginListenable {
  const factory _TelegramLoginListenable(final TelegramLoginEffect effect) =
      _$TelegramLoginListenableImpl;

  @override
  TelegramLoginEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$TelegramLoginListenableImplCopyWith<_$TelegramLoginListenableImpl>
      get copyWith => throw _privateConstructorUsedError;
}

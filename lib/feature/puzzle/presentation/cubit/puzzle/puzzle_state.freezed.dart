// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'puzzle_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PuzzleState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)
        loaded,
    required TResult Function() empty,
    required TResult Function(ChessException exception) failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult? Function()? empty,
    TResult? Function(ChessException exception)? failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult Function()? empty,
    TResult Function(ChessException exception)? failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PuzzleInitialState value) initial,
    required TResult Function(PuzzleLoadingState value) loading,
    required TResult Function(PuzzleLoadedState value) loaded,
    required TResult Function(PuzzleEmptyState value) empty,
    required TResult Function(PuzzleFailedState value) failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PuzzleInitialState value)? initial,
    TResult? Function(PuzzleLoadingState value)? loading,
    TResult? Function(PuzzleLoadedState value)? loaded,
    TResult? Function(PuzzleEmptyState value)? empty,
    TResult? Function(PuzzleFailedState value)? failed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PuzzleInitialState value)? initial,
    TResult Function(PuzzleLoadingState value)? loading,
    TResult Function(PuzzleLoadedState value)? loaded,
    TResult Function(PuzzleEmptyState value)? empty,
    TResult Function(PuzzleFailedState value)? failed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PuzzleStateCopyWith<$Res> {
  factory $PuzzleStateCopyWith(
          PuzzleState value, $Res Function(PuzzleState) then) =
      _$PuzzleStateCopyWithImpl<$Res, PuzzleState>;
}

/// @nodoc
class _$PuzzleStateCopyWithImpl<$Res, $Val extends PuzzleState>
    implements $PuzzleStateCopyWith<$Res> {
  _$PuzzleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$PuzzleInitialStateImplCopyWith<$Res> {
  factory _$$PuzzleInitialStateImplCopyWith(_$PuzzleInitialStateImpl value,
          $Res Function(_$PuzzleInitialStateImpl) then) =
      __$$PuzzleInitialStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PuzzleInitialStateImplCopyWithImpl<$Res>
    extends _$PuzzleStateCopyWithImpl<$Res, _$PuzzleInitialStateImpl>
    implements _$$PuzzleInitialStateImplCopyWith<$Res> {
  __$$PuzzleInitialStateImplCopyWithImpl(_$PuzzleInitialStateImpl _value,
      $Res Function(_$PuzzleInitialStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$PuzzleInitialStateImpl implements PuzzleInitialState {
  const _$PuzzleInitialStateImpl();

  @override
  String toString() {
    return 'PuzzleState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PuzzleInitialStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)
        loaded,
    required TResult Function() empty,
    required TResult Function(ChessException exception) failed,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult? Function()? empty,
    TResult? Function(ChessException exception)? failed,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult Function()? empty,
    TResult Function(ChessException exception)? failed,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PuzzleInitialState value) initial,
    required TResult Function(PuzzleLoadingState value) loading,
    required TResult Function(PuzzleLoadedState value) loaded,
    required TResult Function(PuzzleEmptyState value) empty,
    required TResult Function(PuzzleFailedState value) failed,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PuzzleInitialState value)? initial,
    TResult? Function(PuzzleLoadingState value)? loading,
    TResult? Function(PuzzleLoadedState value)? loaded,
    TResult? Function(PuzzleEmptyState value)? empty,
    TResult? Function(PuzzleFailedState value)? failed,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PuzzleInitialState value)? initial,
    TResult Function(PuzzleLoadingState value)? loading,
    TResult Function(PuzzleLoadedState value)? loaded,
    TResult Function(PuzzleEmptyState value)? empty,
    TResult Function(PuzzleFailedState value)? failed,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class PuzzleInitialState implements PuzzleState {
  const factory PuzzleInitialState() = _$PuzzleInitialStateImpl;
}

/// @nodoc
abstract class _$$PuzzleLoadingStateImplCopyWith<$Res> {
  factory _$$PuzzleLoadingStateImplCopyWith(_$PuzzleLoadingStateImpl value,
          $Res Function(_$PuzzleLoadingStateImpl) then) =
      __$$PuzzleLoadingStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PuzzleLoadingStateImplCopyWithImpl<$Res>
    extends _$PuzzleStateCopyWithImpl<$Res, _$PuzzleLoadingStateImpl>
    implements _$$PuzzleLoadingStateImplCopyWith<$Res> {
  __$$PuzzleLoadingStateImplCopyWithImpl(_$PuzzleLoadingStateImpl _value,
      $Res Function(_$PuzzleLoadingStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$PuzzleLoadingStateImpl implements PuzzleLoadingState {
  const _$PuzzleLoadingStateImpl();

  @override
  String toString() {
    return 'PuzzleState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PuzzleLoadingStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)
        loaded,
    required TResult Function() empty,
    required TResult Function(ChessException exception) failed,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult? Function()? empty,
    TResult? Function(ChessException exception)? failed,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult Function()? empty,
    TResult Function(ChessException exception)? failed,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PuzzleInitialState value) initial,
    required TResult Function(PuzzleLoadingState value) loading,
    required TResult Function(PuzzleLoadedState value) loaded,
    required TResult Function(PuzzleEmptyState value) empty,
    required TResult Function(PuzzleFailedState value) failed,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PuzzleInitialState value)? initial,
    TResult? Function(PuzzleLoadingState value)? loading,
    TResult? Function(PuzzleLoadedState value)? loaded,
    TResult? Function(PuzzleEmptyState value)? empty,
    TResult? Function(PuzzleFailedState value)? failed,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PuzzleInitialState value)? initial,
    TResult Function(PuzzleLoadingState value)? loading,
    TResult Function(PuzzleLoadedState value)? loaded,
    TResult Function(PuzzleEmptyState value)? empty,
    TResult Function(PuzzleFailedState value)? failed,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class PuzzleLoadingState implements PuzzleState {
  const factory PuzzleLoadingState() = _$PuzzleLoadingStateImpl;
}

/// @nodoc
abstract class _$$PuzzleLoadedStateImplCopyWith<$Res> {
  factory _$$PuzzleLoadedStateImplCopyWith(_$PuzzleLoadedStateImpl value,
          $Res Function(_$PuzzleLoadedStateImpl) then) =
      __$$PuzzleLoadedStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {PuzzleData puzzle,
      bool isHintShowed,
      bool isRetried,
      bool submittingMove,
      int retriesCount,
      int elapsedTime,
      bool? isCorrect});
}

/// @nodoc
class __$$PuzzleLoadedStateImplCopyWithImpl<$Res>
    extends _$PuzzleStateCopyWithImpl<$Res, _$PuzzleLoadedStateImpl>
    implements _$$PuzzleLoadedStateImplCopyWith<$Res> {
  __$$PuzzleLoadedStateImplCopyWithImpl(_$PuzzleLoadedStateImpl _value,
      $Res Function(_$PuzzleLoadedStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? puzzle = null,
    Object? isHintShowed = null,
    Object? isRetried = null,
    Object? submittingMove = null,
    Object? retriesCount = null,
    Object? elapsedTime = null,
    Object? isCorrect = freezed,
  }) {
    return _then(_$PuzzleLoadedStateImpl(
      puzzle: null == puzzle
          ? _value.puzzle
          : puzzle // ignore: cast_nullable_to_non_nullable
              as PuzzleData,
      isHintShowed: null == isHintShowed
          ? _value.isHintShowed
          : isHintShowed // ignore: cast_nullable_to_non_nullable
              as bool,
      isRetried: null == isRetried
          ? _value.isRetried
          : isRetried // ignore: cast_nullable_to_non_nullable
              as bool,
      submittingMove: null == submittingMove
          ? _value.submittingMove
          : submittingMove // ignore: cast_nullable_to_non_nullable
              as bool,
      retriesCount: null == retriesCount
          ? _value.retriesCount
          : retriesCount // ignore: cast_nullable_to_non_nullable
              as int,
      elapsedTime: null == elapsedTime
          ? _value.elapsedTime
          : elapsedTime // ignore: cast_nullable_to_non_nullable
              as int,
      isCorrect: freezed == isCorrect
          ? _value.isCorrect
          : isCorrect // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc

class _$PuzzleLoadedStateImpl implements PuzzleLoadedState {
  const _$PuzzleLoadedStateImpl(
      {required this.puzzle,
      this.isHintShowed = false,
      this.isRetried = false,
      this.submittingMove = false,
      this.retriesCount = 0,
      this.elapsedTime = 0,
      this.isCorrect});

  @override
  final PuzzleData puzzle;
  @override
  @JsonKey()
  final bool isHintShowed;
  @override
  @JsonKey()
  final bool isRetried;
  @override
  @JsonKey()
  final bool submittingMove;
  @override
  @JsonKey()
  final int retriesCount;
  @override
  @JsonKey()
  final int elapsedTime;
  @override
  final bool? isCorrect;

  @override
  String toString() {
    return 'PuzzleState.loaded(puzzle: $puzzle, isHintShowed: $isHintShowed, isRetried: $isRetried, submittingMove: $submittingMove, retriesCount: $retriesCount, elapsedTime: $elapsedTime, isCorrect: $isCorrect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PuzzleLoadedStateImpl &&
            (identical(other.puzzle, puzzle) || other.puzzle == puzzle) &&
            (identical(other.isHintShowed, isHintShowed) ||
                other.isHintShowed == isHintShowed) &&
            (identical(other.isRetried, isRetried) ||
                other.isRetried == isRetried) &&
            (identical(other.submittingMove, submittingMove) ||
                other.submittingMove == submittingMove) &&
            (identical(other.retriesCount, retriesCount) ||
                other.retriesCount == retriesCount) &&
            (identical(other.elapsedTime, elapsedTime) ||
                other.elapsedTime == elapsedTime) &&
            (identical(other.isCorrect, isCorrect) ||
                other.isCorrect == isCorrect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, puzzle, isHintShowed, isRetried,
      submittingMove, retriesCount, elapsedTime, isCorrect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PuzzleLoadedStateImplCopyWith<_$PuzzleLoadedStateImpl> get copyWith =>
      __$$PuzzleLoadedStateImplCopyWithImpl<_$PuzzleLoadedStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)
        loaded,
    required TResult Function() empty,
    required TResult Function(ChessException exception) failed,
  }) {
    return loaded(puzzle, isHintShowed, isRetried, submittingMove, retriesCount,
        elapsedTime, isCorrect);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult? Function()? empty,
    TResult? Function(ChessException exception)? failed,
  }) {
    return loaded?.call(puzzle, isHintShowed, isRetried, submittingMove,
        retriesCount, elapsedTime, isCorrect);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult Function()? empty,
    TResult Function(ChessException exception)? failed,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(puzzle, isHintShowed, isRetried, submittingMove,
          retriesCount, elapsedTime, isCorrect);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PuzzleInitialState value) initial,
    required TResult Function(PuzzleLoadingState value) loading,
    required TResult Function(PuzzleLoadedState value) loaded,
    required TResult Function(PuzzleEmptyState value) empty,
    required TResult Function(PuzzleFailedState value) failed,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PuzzleInitialState value)? initial,
    TResult? Function(PuzzleLoadingState value)? loading,
    TResult? Function(PuzzleLoadedState value)? loaded,
    TResult? Function(PuzzleEmptyState value)? empty,
    TResult? Function(PuzzleFailedState value)? failed,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PuzzleInitialState value)? initial,
    TResult Function(PuzzleLoadingState value)? loading,
    TResult Function(PuzzleLoadedState value)? loaded,
    TResult Function(PuzzleEmptyState value)? empty,
    TResult Function(PuzzleFailedState value)? failed,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class PuzzleLoadedState implements PuzzleState {
  const factory PuzzleLoadedState(
      {required final PuzzleData puzzle,
      final bool isHintShowed,
      final bool isRetried,
      final bool submittingMove,
      final int retriesCount,
      final int elapsedTime,
      final bool? isCorrect}) = _$PuzzleLoadedStateImpl;

  PuzzleData get puzzle;
  bool get isHintShowed;
  bool get isRetried;
  bool get submittingMove;
  int get retriesCount;
  int get elapsedTime;
  bool? get isCorrect;
  @JsonKey(ignore: true)
  _$$PuzzleLoadedStateImplCopyWith<_$PuzzleLoadedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PuzzleEmptyStateImplCopyWith<$Res> {
  factory _$$PuzzleEmptyStateImplCopyWith(_$PuzzleEmptyStateImpl value,
          $Res Function(_$PuzzleEmptyStateImpl) then) =
      __$$PuzzleEmptyStateImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PuzzleEmptyStateImplCopyWithImpl<$Res>
    extends _$PuzzleStateCopyWithImpl<$Res, _$PuzzleEmptyStateImpl>
    implements _$$PuzzleEmptyStateImplCopyWith<$Res> {
  __$$PuzzleEmptyStateImplCopyWithImpl(_$PuzzleEmptyStateImpl _value,
      $Res Function(_$PuzzleEmptyStateImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$PuzzleEmptyStateImpl implements PuzzleEmptyState {
  const _$PuzzleEmptyStateImpl();

  @override
  String toString() {
    return 'PuzzleState.empty()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PuzzleEmptyStateImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)
        loaded,
    required TResult Function() empty,
    required TResult Function(ChessException exception) failed,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult? Function()? empty,
    TResult? Function(ChessException exception)? failed,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult Function()? empty,
    TResult Function(ChessException exception)? failed,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PuzzleInitialState value) initial,
    required TResult Function(PuzzleLoadingState value) loading,
    required TResult Function(PuzzleLoadedState value) loaded,
    required TResult Function(PuzzleEmptyState value) empty,
    required TResult Function(PuzzleFailedState value) failed,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PuzzleInitialState value)? initial,
    TResult? Function(PuzzleLoadingState value)? loading,
    TResult? Function(PuzzleLoadedState value)? loaded,
    TResult? Function(PuzzleEmptyState value)? empty,
    TResult? Function(PuzzleFailedState value)? failed,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PuzzleInitialState value)? initial,
    TResult Function(PuzzleLoadingState value)? loading,
    TResult Function(PuzzleLoadedState value)? loaded,
    TResult Function(PuzzleEmptyState value)? empty,
    TResult Function(PuzzleFailedState value)? failed,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class PuzzleEmptyState implements PuzzleState {
  const factory PuzzleEmptyState() = _$PuzzleEmptyStateImpl;
}

/// @nodoc
abstract class _$$PuzzleFailedStateImplCopyWith<$Res> {
  factory _$$PuzzleFailedStateImplCopyWith(_$PuzzleFailedStateImpl value,
          $Res Function(_$PuzzleFailedStateImpl) then) =
      __$$PuzzleFailedStateImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ChessException exception});
}

/// @nodoc
class __$$PuzzleFailedStateImplCopyWithImpl<$Res>
    extends _$PuzzleStateCopyWithImpl<$Res, _$PuzzleFailedStateImpl>
    implements _$$PuzzleFailedStateImplCopyWith<$Res> {
  __$$PuzzleFailedStateImplCopyWithImpl(_$PuzzleFailedStateImpl _value,
      $Res Function(_$PuzzleFailedStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? exception = null,
  }) {
    return _then(_$PuzzleFailedStateImpl(
      null == exception
          ? _value.exception
          : exception // ignore: cast_nullable_to_non_nullable
              as ChessException,
    ));
  }
}

/// @nodoc

class _$PuzzleFailedStateImpl implements PuzzleFailedState {
  const _$PuzzleFailedStateImpl(this.exception);

  @override
  final ChessException exception;

  @override
  String toString() {
    return 'PuzzleState.failed(exception: $exception)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PuzzleFailedStateImpl &&
            (identical(other.exception, exception) ||
                other.exception == exception));
  }

  @override
  int get hashCode => Object.hash(runtimeType, exception);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PuzzleFailedStateImplCopyWith<_$PuzzleFailedStateImpl> get copyWith =>
      __$$PuzzleFailedStateImplCopyWithImpl<_$PuzzleFailedStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)
        loaded,
    required TResult Function() empty,
    required TResult Function(ChessException exception) failed,
  }) {
    return failed(exception);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult? Function()? empty,
    TResult? Function(ChessException exception)? failed,
  }) {
    return failed?.call(exception);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            PuzzleData puzzle,
            bool isHintShowed,
            bool isRetried,
            bool submittingMove,
            int retriesCount,
            int elapsedTime,
            bool? isCorrect)?
        loaded,
    TResult Function()? empty,
    TResult Function(ChessException exception)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(exception);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(PuzzleInitialState value) initial,
    required TResult Function(PuzzleLoadingState value) loading,
    required TResult Function(PuzzleLoadedState value) loaded,
    required TResult Function(PuzzleEmptyState value) empty,
    required TResult Function(PuzzleFailedState value) failed,
  }) {
    return failed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(PuzzleInitialState value)? initial,
    TResult? Function(PuzzleLoadingState value)? loading,
    TResult? Function(PuzzleLoadedState value)? loaded,
    TResult? Function(PuzzleEmptyState value)? empty,
    TResult? Function(PuzzleFailedState value)? failed,
  }) {
    return failed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(PuzzleInitialState value)? initial,
    TResult Function(PuzzleLoadingState value)? loading,
    TResult Function(PuzzleLoadedState value)? loaded,
    TResult Function(PuzzleEmptyState value)? empty,
    TResult Function(PuzzleFailedState value)? failed,
    required TResult orElse(),
  }) {
    if (failed != null) {
      return failed(this);
    }
    return orElse();
  }
}

abstract class PuzzleFailedState implements PuzzleState {
  const factory PuzzleFailedState(final ChessException exception) =
      _$PuzzleFailedStateImpl;

  ChessException get exception;
  @JsonKey(ignore: true)
  _$$PuzzleFailedStateImplCopyWith<_$PuzzleFailedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

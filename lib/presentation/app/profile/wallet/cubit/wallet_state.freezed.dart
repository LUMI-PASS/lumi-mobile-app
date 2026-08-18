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
  /// First paint only. Paging in more rows must not blank the screen, which
  /// is why appending has its own flag.
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;

  /// Null until the balance lands. The hero renders zeros rather than a
  /// spinner-shaped hole, so the card doesn't jump when it arrives.
  WalletBalance? get wallet => throw _privateConstructorUsedError;
  List<WalletTransactionModel> get entries =>
      throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  /// Drives the empty state's "earn 2% back" line. Absent or disabled just
  /// drops that sentence — it never blocks the screen.
  CashbackConfig? get config => throw _privateConstructorUsedError;

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
      {bool isLoading,
      bool isLoadingMore,
      WalletBalance? wallet,
      List<WalletTransactionModel> entries,
      int page,
      int totalPages,
      CashbackConfig? config});

  $WalletBalanceCopyWith<$Res>? get wallet;
  $CashbackConfigCopyWith<$Res>? get config;
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
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? wallet = freezed,
    Object? entries = null,
    Object? page = null,
    Object? totalPages = null,
    Object? config = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      wallet: freezed == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as WalletBalance?,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<WalletTransactionModel>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      config: freezed == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as CashbackConfig?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WalletBalanceCopyWith<$Res>? get wallet {
    if (_value.wallet == null) {
      return null;
    }

    return $WalletBalanceCopyWith<$Res>(_value.wallet!, (value) {
      return _then(_value.copyWith(wallet: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $CashbackConfigCopyWith<$Res>? get config {
    if (_value.config == null) {
      return null;
    }

    return $CashbackConfigCopyWith<$Res>(_value.config!, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
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
      {bool isLoading,
      bool isLoadingMore,
      WalletBalance? wallet,
      List<WalletTransactionModel> entries,
      int page,
      int totalPages,
      CashbackConfig? config});

  @override
  $WalletBalanceCopyWith<$Res>? get wallet;
  @override
  $CashbackConfigCopyWith<$Res>? get config;
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
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? wallet = freezed,
    Object? entries = null,
    Object? page = null,
    Object? totalPages = null,
    Object? config = freezed,
  }) {
    return _then(_$WalletBuildableImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      wallet: freezed == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as WalletBalance?,
      entries: null == entries
          ? _value._entries
          : entries // ignore: cast_nullable_to_non_nullable
              as List<WalletTransactionModel>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      config: freezed == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as CashbackConfig?,
    ));
  }
}

/// @nodoc

class _$WalletBuildableImpl extends _WalletBuildable {
  const _$WalletBuildableImpl(
      {this.isLoading = true,
      this.isLoadingMore = false,
      this.wallet,
      final List<WalletTransactionModel> entries = const [],
      this.page = 1,
      this.totalPages = 1,
      this.config})
      : _entries = entries,
        super._();

  /// First paint only. Paging in more rows must not blank the screen, which
  /// is why appending has its own flag.
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;

  /// Null until the balance lands. The hero renders zeros rather than a
  /// spinner-shaped hole, so the card doesn't jump when it arrives.
  @override
  final WalletBalance? wallet;
  final List<WalletTransactionModel> _entries;
  @override
  @JsonKey()
  List<WalletTransactionModel> get entries {
    if (_entries is EqualUnmodifiableListView) return _entries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_entries);
  }

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int totalPages;

  /// Drives the empty state's "earn 2% back" line. Absent or disabled just
  /// drops that sentence — it never blocks the screen.
  @override
  final CashbackConfig? config;

  @override
  String toString() {
    return 'WalletBuildable(isLoading: $isLoading, isLoadingMore: $isLoadingMore, wallet: $wallet, entries: $entries, page: $page, totalPages: $totalPages, config: $config)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletBuildableImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.wallet, wallet) || other.wallet == wallet) &&
            const DeepCollectionEquality().equals(other._entries, _entries) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.config, config) || other.config == config));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isLoadingMore, wallet,
      const DeepCollectionEquality().hash(_entries), page, totalPages, config);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletBuildableImplCopyWith<_$WalletBuildableImpl> get copyWith =>
      __$$WalletBuildableImplCopyWithImpl<_$WalletBuildableImpl>(
          this, _$identity);
}

abstract class _WalletBuildable extends WalletBuildable {
  const factory _WalletBuildable(
      {final bool isLoading,
      final bool isLoadingMore,
      final WalletBalance? wallet,
      final List<WalletTransactionModel> entries,
      final int page,
      final int totalPages,
      final CashbackConfig? config}) = _$WalletBuildableImpl;
  const _WalletBuildable._() : super._();

  @override

  /// First paint only. Paging in more rows must not blank the screen, which
  /// is why appending has its own flag.
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override

  /// Null until the balance lands. The hero renders zeros rather than a
  /// spinner-shaped hole, so the card doesn't jump when it arrives.
  WalletBalance? get wallet;
  @override
  List<WalletTransactionModel> get entries;
  @override
  int get page;
  @override
  int get totalPages;
  @override

  /// Drives the empty state's "earn 2% back" line. Absent or disabled just
  /// drops that sentence — it never blocks the screen.
  CashbackConfig? get config;
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

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ShopBuildable {
  /// First paint only. Paging in more products must not blank the grid,
  /// which is why appending has its own flag.
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  List<ShopProduct> get products => throw _privateConstructorUsedError;
  int get page => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;

  /// What the buyer can spend. Null for a guest, and for anybody whose
  /// balance has not landed yet — the header renders nothing rather than a
  /// zero, because "0 coins" and "we don't know yet" are different claims.
  WalletBalance? get wallet => throw _privateConstructorUsedError;

  /// The buyer's own purchases, for the "my orders" entry point. Only the
  /// count is used on this screen; the list screen loads its own.
  List<ShopOrder> get orders => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ShopBuildableCopyWith<ShopBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopBuildableCopyWith<$Res> {
  factory $ShopBuildableCopyWith(
          ShopBuildable value, $Res Function(ShopBuildable) then) =
      _$ShopBuildableCopyWithImpl<$Res, ShopBuildable>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isLoadingMore,
      bool hasError,
      List<ShopProduct> products,
      int page,
      int totalPages,
      WalletBalance? wallet,
      List<ShopOrder> orders});

  $WalletBalanceCopyWith<$Res>? get wallet;
}

/// @nodoc
class _$ShopBuildableCopyWithImpl<$Res, $Val extends ShopBuildable>
    implements $ShopBuildableCopyWith<$Res> {
  _$ShopBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasError = null,
    Object? products = null,
    Object? page = null,
    Object? totalPages = null,
    Object? wallet = freezed,
    Object? orders = null,
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
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      products: null == products
          ? _value.products
          : products // ignore: cast_nullable_to_non_nullable
              as List<ShopProduct>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      wallet: freezed == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as WalletBalance?,
      orders: null == orders
          ? _value.orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<ShopOrder>,
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
}

/// @nodoc
abstract class _$$ShopBuildableImplCopyWith<$Res>
    implements $ShopBuildableCopyWith<$Res> {
  factory _$$ShopBuildableImplCopyWith(
          _$ShopBuildableImpl value, $Res Function(_$ShopBuildableImpl) then) =
      __$$ShopBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isLoadingMore,
      bool hasError,
      List<ShopProduct> products,
      int page,
      int totalPages,
      WalletBalance? wallet,
      List<ShopOrder> orders});

  @override
  $WalletBalanceCopyWith<$Res>? get wallet;
}

/// @nodoc
class __$$ShopBuildableImplCopyWithImpl<$Res>
    extends _$ShopBuildableCopyWithImpl<$Res, _$ShopBuildableImpl>
    implements _$$ShopBuildableImplCopyWith<$Res> {
  __$$ShopBuildableImplCopyWithImpl(
      _$ShopBuildableImpl _value, $Res Function(_$ShopBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasError = null,
    Object? products = null,
    Object? page = null,
    Object? totalPages = null,
    Object? wallet = freezed,
    Object? orders = null,
  }) {
    return _then(_$ShopBuildableImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      products: null == products
          ? _value._products
          : products // ignore: cast_nullable_to_non_nullable
              as List<ShopProduct>,
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      totalPages: null == totalPages
          ? _value.totalPages
          : totalPages // ignore: cast_nullable_to_non_nullable
              as int,
      wallet: freezed == wallet
          ? _value.wallet
          : wallet // ignore: cast_nullable_to_non_nullable
              as WalletBalance?,
      orders: null == orders
          ? _value._orders
          : orders // ignore: cast_nullable_to_non_nullable
              as List<ShopOrder>,
    ));
  }
}

/// @nodoc

class _$ShopBuildableImpl extends _ShopBuildable {
  const _$ShopBuildableImpl(
      {this.isLoading = true,
      this.isLoadingMore = false,
      this.hasError = false,
      final List<ShopProduct> products = const [],
      this.page = 1,
      this.totalPages = 1,
      this.wallet,
      final List<ShopOrder> orders = const []})
      : _products = products,
        _orders = orders,
        super._();

  /// First paint only. Paging in more products must not blank the grid,
  /// which is why appending has its own flag.
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool hasError;
  final List<ShopProduct> _products;
  @override
  @JsonKey()
  List<ShopProduct> get products {
    if (_products is EqualUnmodifiableListView) return _products;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_products);
  }

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey()
  final int totalPages;

  /// What the buyer can spend. Null for a guest, and for anybody whose
  /// balance has not landed yet — the header renders nothing rather than a
  /// zero, because "0 coins" and "we don't know yet" are different claims.
  @override
  final WalletBalance? wallet;

  /// The buyer's own purchases, for the "my orders" entry point. Only the
  /// count is used on this screen; the list screen loads its own.
  final List<ShopOrder> _orders;

  /// The buyer's own purchases, for the "my orders" entry point. Only the
  /// count is used on this screen; the list screen loads its own.
  @override
  @JsonKey()
  List<ShopOrder> get orders {
    if (_orders is EqualUnmodifiableListView) return _orders;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_orders);
  }

  @override
  String toString() {
    return 'ShopBuildable(isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasError: $hasError, products: $products, page: $page, totalPages: $totalPages, wallet: $wallet, orders: $orders)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopBuildableImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            const DeepCollectionEquality().equals(other._products, _products) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.wallet, wallet) || other.wallet == wallet) &&
            const DeepCollectionEquality().equals(other._orders, _orders));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isLoadingMore,
      hasError,
      const DeepCollectionEquality().hash(_products),
      page,
      totalPages,
      wallet,
      const DeepCollectionEquality().hash(_orders));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopBuildableImplCopyWith<_$ShopBuildableImpl> get copyWith =>
      __$$ShopBuildableImplCopyWithImpl<_$ShopBuildableImpl>(this, _$identity);
}

abstract class _ShopBuildable extends ShopBuildable {
  const factory _ShopBuildable(
      {final bool isLoading,
      final bool isLoadingMore,
      final bool hasError,
      final List<ShopProduct> products,
      final int page,
      final int totalPages,
      final WalletBalance? wallet,
      final List<ShopOrder> orders}) = _$ShopBuildableImpl;
  const _ShopBuildable._() : super._();

  @override

  /// First paint only. Paging in more products must not blank the grid,
  /// which is why appending has its own flag.
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get hasError;
  @override
  List<ShopProduct> get products;
  @override
  int get page;
  @override
  int get totalPages;
  @override

  /// What the buyer can spend. Null for a guest, and for anybody whose
  /// balance has not landed yet — the header renders nothing rather than a
  /// zero, because "0 coins" and "we don't know yet" are different claims.
  WalletBalance? get wallet;
  @override

  /// The buyer's own purchases, for the "my orders" entry point. Only the
  /// count is used on this screen; the list screen loads its own.
  List<ShopOrder> get orders;
  @override
  @JsonKey(ignore: true)
  _$$ShopBuildableImplCopyWith<_$ShopBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ShopListenable {
  ShopEffect get effect => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ShopListenableCopyWith<ShopListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopListenableCopyWith<$Res> {
  factory $ShopListenableCopyWith(
          ShopListenable value, $Res Function(ShopListenable) then) =
      _$ShopListenableCopyWithImpl<$Res, ShopListenable>;
  @useResult
  $Res call({ShopEffect effect, String? message});
}

/// @nodoc
class _$ShopListenableCopyWithImpl<$Res, $Val extends ShopListenable>
    implements $ShopListenableCopyWith<$Res> {
  _$ShopListenableCopyWithImpl(this._value, this._then);

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
              as ShopEffect,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShopListenableImplCopyWith<$Res>
    implements $ShopListenableCopyWith<$Res> {
  factory _$$ShopListenableImplCopyWith(_$ShopListenableImpl value,
          $Res Function(_$ShopListenableImpl) then) =
      __$$ShopListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ShopEffect effect, String? message});
}

/// @nodoc
class __$$ShopListenableImplCopyWithImpl<$Res>
    extends _$ShopListenableCopyWithImpl<$Res, _$ShopListenableImpl>
    implements _$$ShopListenableImplCopyWith<$Res> {
  __$$ShopListenableImplCopyWithImpl(
      _$ShopListenableImpl _value, $Res Function(_$ShopListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
    Object? message = freezed,
  }) {
    return _then(_$ShopListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as ShopEffect,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ShopListenableImpl implements _ShopListenable {
  const _$ShopListenableImpl({required this.effect, this.message});

  @override
  final ShopEffect effect;
  @override
  final String? message;

  @override
  String toString() {
    return 'ShopListenable(effect: $effect, message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect) &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopListenableImplCopyWith<_$ShopListenableImpl> get copyWith =>
      __$$ShopListenableImplCopyWithImpl<_$ShopListenableImpl>(
          this, _$identity);
}

abstract class _ShopListenable implements ShopListenable {
  const factory _ShopListenable(
      {required final ShopEffect effect,
      final String? message}) = _$ShopListenableImpl;

  @override
  ShopEffect get effect;
  @override
  String? get message;
  @override
  @JsonKey(ignore: true)
  _$$ShopListenableImplCopyWith<_$ShopListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

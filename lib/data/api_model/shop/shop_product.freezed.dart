// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShopProduct _$ShopProductFromJson(Map<String, dynamic> json) {
  return _ShopProduct.fromJson(json);
}

/// @nodoc
mixin _$ShopProduct {
  String get id => throw _privateConstructorUsedError;
  Map<String, dynamic> get name => throw _privateConstructorUsedError;
  Map<String, dynamic>? get description => throw _privateConstructorUsedError;
  List<String> get images => throw _privateConstructorUsedError;
  num get price => throw _privateConstructorUsedError;
  num? get oldPrice => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// What can actually be put in a basket right now — stock minus whatever
  /// unpaid checkouts are holding. The raw stock figure is deliberately not
  /// sent to the app: it would promise units that are already spoken for.
  int get available => throw _privateConstructorUsedError;
  bool get inStock => throw _privateConstructorUsedError;
  int get maxPerOrder => throw _privateConstructorUsedError;
  int get soldCount => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShopProductCopyWith<ShopProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopProductCopyWith<$Res> {
  factory $ShopProductCopyWith(
          ShopProduct value, $Res Function(ShopProduct) then) =
      _$ShopProductCopyWithImpl<$Res, ShopProduct>;
  @useResult
  $Res call(
      {String id,
      Map<String, dynamic> name,
      Map<String, dynamic>? description,
      List<String> images,
      num price,
      num? oldPrice,
      String currency,
      int available,
      bool inStock,
      int maxPerOrder,
      int soldCount,
      List<String> tags});
}

/// @nodoc
class _$ShopProductCopyWithImpl<$Res, $Val extends ShopProduct>
    implements $ShopProductCopyWith<$Res> {
  _$ShopProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? images = null,
    Object? price = null,
    Object? oldPrice = freezed,
    Object? currency = null,
    Object? available = null,
    Object? inStock = null,
    Object? maxPerOrder = null,
    Object? soldCount = null,
    Object? tags = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num,
      oldPrice: freezed == oldPrice
          ? _value.oldPrice
          : oldPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      maxPerOrder: null == maxPerOrder
          ? _value.maxPerOrder
          : maxPerOrder // ignore: cast_nullable_to_non_nullable
              as int,
      soldCount: null == soldCount
          ? _value.soldCount
          : soldCount // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShopProductImplCopyWith<$Res>
    implements $ShopProductCopyWith<$Res> {
  factory _$$ShopProductImplCopyWith(
          _$ShopProductImpl value, $Res Function(_$ShopProductImpl) then) =
      __$$ShopProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      Map<String, dynamic> name,
      Map<String, dynamic>? description,
      List<String> images,
      num price,
      num? oldPrice,
      String currency,
      int available,
      bool inStock,
      int maxPerOrder,
      int soldCount,
      List<String> tags});
}

/// @nodoc
class __$$ShopProductImplCopyWithImpl<$Res>
    extends _$ShopProductCopyWithImpl<$Res, _$ShopProductImpl>
    implements _$$ShopProductImplCopyWith<$Res> {
  __$$ShopProductImplCopyWithImpl(
      _$ShopProductImpl _value, $Res Function(_$ShopProductImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? images = null,
    Object? price = null,
    Object? oldPrice = freezed,
    Object? currency = null,
    Object? available = null,
    Object? inStock = null,
    Object? maxPerOrder = null,
    Object? soldCount = null,
    Object? tags = null,
  }) {
    return _then(_$ShopProductImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value._name
          : name // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      description: freezed == description
          ? _value._description
          : description // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      images: null == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num,
      oldPrice: freezed == oldPrice
          ? _value.oldPrice
          : oldPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      available: null == available
          ? _value.available
          : available // ignore: cast_nullable_to_non_nullable
              as int,
      inStock: null == inStock
          ? _value.inStock
          : inStock // ignore: cast_nullable_to_non_nullable
              as bool,
      maxPerOrder: null == maxPerOrder
          ? _value.maxPerOrder
          : maxPerOrder // ignore: cast_nullable_to_non_nullable
              as int,
      soldCount: null == soldCount
          ? _value.soldCount
          : soldCount // ignore: cast_nullable_to_non_nullable
              as int,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ShopProductImpl extends _ShopProduct {
  const _$ShopProductImpl(
      {this.id = '',
      final Map<String, dynamic> name = const {},
      final Map<String, dynamic>? description = null,
      final List<String> images = const [],
      this.price = 0,
      this.oldPrice,
      this.currency = 'UZS',
      this.available = 0,
      this.inStock = false,
      this.maxPerOrder = 5,
      this.soldCount = 0,
      final List<String> tags = const []})
      : _name = name,
        _description = description,
        _images = images,
        _tags = tags,
        super._();

  factory _$ShopProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopProductImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  final Map<String, dynamic> _name;
  @override
  @JsonKey()
  Map<String, dynamic> get name {
    if (_name is EqualUnmodifiableMapView) return _name;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_name);
  }

  final Map<String, dynamic>? _description;
  @override
  @JsonKey()
  Map<String, dynamic>? get description {
    final value = _description;
    if (value == null) return null;
    if (_description is EqualUnmodifiableMapView) return _description;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final List<String> _images;
  @override
  @JsonKey()
  List<String> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  @override
  @JsonKey()
  final num price;
  @override
  final num? oldPrice;
  @override
  @JsonKey()
  final String currency;

  /// What can actually be put in a basket right now — stock minus whatever
  /// unpaid checkouts are holding. The raw stock figure is deliberately not
  /// sent to the app: it would promise units that are already spoken for.
  @override
  @JsonKey()
  final int available;
  @override
  @JsonKey()
  final bool inStock;
  @override
  @JsonKey()
  final int maxPerOrder;
  @override
  @JsonKey()
  final int soldCount;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  String toString() {
    return 'ShopProduct(id: $id, name: $name, description: $description, images: $images, price: $price, oldPrice: $oldPrice, currency: $currency, available: $available, inStock: $inStock, maxPerOrder: $maxPerOrder, soldCount: $soldCount, tags: $tags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._name, _name) &&
            const DeepCollectionEquality()
                .equals(other._description, _description) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.oldPrice, oldPrice) ||
                other.oldPrice == oldPrice) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.available, available) ||
                other.available == available) &&
            (identical(other.inStock, inStock) || other.inStock == inStock) &&
            (identical(other.maxPerOrder, maxPerOrder) ||
                other.maxPerOrder == maxPerOrder) &&
            (identical(other.soldCount, soldCount) ||
                other.soldCount == soldCount) &&
            const DeepCollectionEquality().equals(other._tags, _tags));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_name),
      const DeepCollectionEquality().hash(_description),
      const DeepCollectionEquality().hash(_images),
      price,
      oldPrice,
      currency,
      available,
      inStock,
      maxPerOrder,
      soldCount,
      const DeepCollectionEquality().hash(_tags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopProductImplCopyWith<_$ShopProductImpl> get copyWith =>
      __$$ShopProductImplCopyWithImpl<_$ShopProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopProductImplToJson(
      this,
    );
  }
}

abstract class _ShopProduct extends ShopProduct {
  const factory _ShopProduct(
      {final String id,
      final Map<String, dynamic> name,
      final Map<String, dynamic>? description,
      final List<String> images,
      final num price,
      final num? oldPrice,
      final String currency,
      final int available,
      final bool inStock,
      final int maxPerOrder,
      final int soldCount,
      final List<String> tags}) = _$ShopProductImpl;
  const _ShopProduct._() : super._();

  factory _ShopProduct.fromJson(Map<String, dynamic> json) =
      _$ShopProductImpl.fromJson;

  @override
  String get id;
  @override
  Map<String, dynamic> get name;
  @override
  Map<String, dynamic>? get description;
  @override
  List<String> get images;
  @override
  num get price;
  @override
  num? get oldPrice;
  @override
  String get currency;
  @override

  /// What can actually be put in a basket right now — stock minus whatever
  /// unpaid checkouts are holding. The raw stock figure is deliberately not
  /// sent to the app: it would promise units that are already spoken for.
  int get available;
  @override
  bool get inStock;
  @override
  int get maxPerOrder;
  @override
  int get soldCount;
  @override
  List<String> get tags;
  @override
  @JsonKey(ignore: true)
  _$$ShopProductImplCopyWith<_$ShopProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

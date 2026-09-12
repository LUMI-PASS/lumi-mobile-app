// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shop_order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShopDelivery _$ShopDeliveryFromJson(Map<String, dynamic> json) {
  return _ShopDelivery.fromJson(json);
}

/// @nodoc
mixin _$ShopDelivery {
  double get lat => throw _privateConstructorUsedError;
  double get lng => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  String? get contactName => throw _privateConstructorUsedError;
  String get contactPhone => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShopDeliveryCopyWith<ShopDelivery> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopDeliveryCopyWith<$Res> {
  factory $ShopDeliveryCopyWith(
          ShopDelivery value, $Res Function(ShopDelivery) then) =
      _$ShopDeliveryCopyWithImpl<$Res, ShopDelivery>;
  @useResult
  $Res call(
      {double lat,
      double lng,
      String address,
      String? contactName,
      String contactPhone,
      String? comment});
}

/// @nodoc
class _$ShopDeliveryCopyWithImpl<$Res, $Val extends ShopDelivery>
    implements $ShopDeliveryCopyWith<$Res> {
  _$ShopDeliveryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? address = null,
    Object? contactName = freezed,
    Object? contactPhone = null,
    Object? comment = freezed,
  }) {
    return _then(_value.copyWith(
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShopDeliveryImplCopyWith<$Res>
    implements $ShopDeliveryCopyWith<$Res> {
  factory _$$ShopDeliveryImplCopyWith(
          _$ShopDeliveryImpl value, $Res Function(_$ShopDeliveryImpl) then) =
      __$$ShopDeliveryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double lat,
      double lng,
      String address,
      String? contactName,
      String contactPhone,
      String? comment});
}

/// @nodoc
class __$$ShopDeliveryImplCopyWithImpl<$Res>
    extends _$ShopDeliveryCopyWithImpl<$Res, _$ShopDeliveryImpl>
    implements _$$ShopDeliveryImplCopyWith<$Res> {
  __$$ShopDeliveryImplCopyWithImpl(
      _$ShopDeliveryImpl _value, $Res Function(_$ShopDeliveryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = null,
    Object? lng = null,
    Object? address = null,
    Object? contactName = freezed,
    Object? contactPhone = null,
    Object? comment = freezed,
  }) {
    return _then(_$ShopDeliveryImpl(
      lat: null == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double,
      lng: null == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      contactName: freezed == contactName
          ? _value.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: null == contactPhone
          ? _value.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ShopDeliveryImpl implements _ShopDelivery {
  const _$ShopDeliveryImpl(
      {this.lat = 0,
      this.lng = 0,
      this.address = '',
      this.contactName,
      this.contactPhone = '',
      this.comment});

  factory _$ShopDeliveryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopDeliveryImplFromJson(json);

  @override
  @JsonKey()
  final double lat;
  @override
  @JsonKey()
  final double lng;
  @override
  @JsonKey()
  final String address;
  @override
  final String? contactName;
  @override
  @JsonKey()
  final String contactPhone;
  @override
  final String? comment;

  @override
  String toString() {
    return 'ShopDelivery(lat: $lat, lng: $lng, address: $address, contactName: $contactName, contactPhone: $contactPhone, comment: $comment)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopDeliveryImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.comment, comment) || other.comment == comment));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, lat, lng, address, contactName, contactPhone, comment);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopDeliveryImplCopyWith<_$ShopDeliveryImpl> get copyWith =>
      __$$ShopDeliveryImplCopyWithImpl<_$ShopDeliveryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopDeliveryImplToJson(
      this,
    );
  }
}

abstract class _ShopDelivery implements ShopDelivery {
  const factory _ShopDelivery(
      {final double lat,
      final double lng,
      final String address,
      final String? contactName,
      final String contactPhone,
      final String? comment}) = _$ShopDeliveryImpl;

  factory _ShopDelivery.fromJson(Map<String, dynamic> json) =
      _$ShopDeliveryImpl.fromJson;

  @override
  double get lat;
  @override
  double get lng;
  @override
  String get address;
  @override
  String? get contactName;
  @override
  String get contactPhone;
  @override
  String? get comment;
  @override
  @JsonKey(ignore: true)
  _$$ShopDeliveryImplCopyWith<_$ShopDeliveryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopOrderItem _$ShopOrderItemFromJson(Map<String, dynamic> json) {
  return _ShopOrderItem.fromJson(json);
}

/// @nodoc
mixin _$ShopOrderItem {
  String get productId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get name => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  num get unitPrice => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShopOrderItemCopyWith<ShopOrderItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopOrderItemCopyWith<$Res> {
  factory $ShopOrderItemCopyWith(
          ShopOrderItem value, $Res Function(ShopOrderItem) then) =
      _$ShopOrderItemCopyWithImpl<$Res, ShopOrderItem>;
  @useResult
  $Res call(
      {String productId,
      Map<String, dynamic>? name,
      String? image,
      num unitPrice,
      int count});
}

/// @nodoc
class _$ShopOrderItemCopyWithImpl<$Res, $Val extends ShopOrderItem>
    implements $ShopOrderItemCopyWith<$Res> {
  _$ShopOrderItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? name = freezed,
    Object? image = freezed,
    Object? unitPrice = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as num,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShopOrderItemImplCopyWith<$Res>
    implements $ShopOrderItemCopyWith<$Res> {
  factory _$$ShopOrderItemImplCopyWith(
          _$ShopOrderItemImpl value, $Res Function(_$ShopOrderItemImpl) then) =
      __$$ShopOrderItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String productId,
      Map<String, dynamic>? name,
      String? image,
      num unitPrice,
      int count});
}

/// @nodoc
class __$$ShopOrderItemImplCopyWithImpl<$Res>
    extends _$ShopOrderItemCopyWithImpl<$Res, _$ShopOrderItemImpl>
    implements _$$ShopOrderItemImplCopyWith<$Res> {
  __$$ShopOrderItemImplCopyWithImpl(
      _$ShopOrderItemImpl _value, $Res Function(_$ShopOrderItemImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? productId = null,
    Object? name = freezed,
    Object? image = freezed,
    Object? unitPrice = null,
    Object? count = null,
  }) {
    return _then(_$ShopOrderItemImpl(
      productId: null == productId
          ? _value.productId
          : productId // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value._name
          : name // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      unitPrice: null == unitPrice
          ? _value.unitPrice
          : unitPrice // ignore: cast_nullable_to_non_nullable
              as num,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ShopOrderItemImpl extends _ShopOrderItem {
  const _$ShopOrderItemImpl(
      {this.productId = '',
      final Map<String, dynamic>? name = null,
      this.image,
      this.unitPrice = 0,
      this.count = 1})
      : _name = name,
        super._();

  factory _$ShopOrderItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopOrderItemImplFromJson(json);

  @override
  @JsonKey()
  final String productId;
  final Map<String, dynamic>? _name;
  @override
  @JsonKey()
  Map<String, dynamic>? get name {
    final value = _name;
    if (value == null) return null;
    if (_name is EqualUnmodifiableMapView) return _name;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  final String? image;
  @override
  @JsonKey()
  final num unitPrice;
  @override
  @JsonKey()
  final int count;

  @override
  String toString() {
    return 'ShopOrderItem(productId: $productId, name: $name, image: $image, unitPrice: $unitPrice, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopOrderItemImpl &&
            (identical(other.productId, productId) ||
                other.productId == productId) &&
            const DeepCollectionEquality().equals(other._name, _name) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.unitPrice, unitPrice) ||
                other.unitPrice == unitPrice) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, productId,
      const DeepCollectionEquality().hash(_name), image, unitPrice, count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopOrderItemImplCopyWith<_$ShopOrderItemImpl> get copyWith =>
      __$$ShopOrderItemImplCopyWithImpl<_$ShopOrderItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopOrderItemImplToJson(
      this,
    );
  }
}

abstract class _ShopOrderItem extends ShopOrderItem {
  const factory _ShopOrderItem(
      {final String productId,
      final Map<String, dynamic>? name,
      final String? image,
      final num unitPrice,
      final int count}) = _$ShopOrderItemImpl;
  const _ShopOrderItem._() : super._();

  factory _ShopOrderItem.fromJson(Map<String, dynamic> json) =
      _$ShopOrderItemImpl.fromJson;

  @override
  String get productId;
  @override
  Map<String, dynamic>? get name;
  @override
  String? get image;
  @override
  num get unitPrice;
  @override
  int get count;
  @override
  @JsonKey(ignore: true)
  _$$ShopOrderItemImplCopyWith<_$ShopOrderItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopOrderEvent _$ShopOrderEventFromJson(Map<String, dynamic> json) {
  return _ShopOrderEvent.fromJson(json);
}

/// @nodoc
mixin _$ShopOrderEvent {
  ShopOrderStatus get status => throw _privateConstructorUsedError;
  DateTime? get at => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShopOrderEventCopyWith<ShopOrderEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopOrderEventCopyWith<$Res> {
  factory $ShopOrderEventCopyWith(
          ShopOrderEvent value, $Res Function(ShopOrderEvent) then) =
      _$ShopOrderEventCopyWithImpl<$Res, ShopOrderEvent>;
  @useResult
  $Res call({ShopOrderStatus status, DateTime? at, String? note});
}

/// @nodoc
class _$ShopOrderEventCopyWithImpl<$Res, $Val extends ShopOrderEvent>
    implements $ShopOrderEventCopyWith<$Res> {
  _$ShopOrderEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? at = freezed,
    Object? note = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShopOrderStatus,
      at: freezed == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShopOrderEventImplCopyWith<$Res>
    implements $ShopOrderEventCopyWith<$Res> {
  factory _$$ShopOrderEventImplCopyWith(_$ShopOrderEventImpl value,
          $Res Function(_$ShopOrderEventImpl) then) =
      __$$ShopOrderEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ShopOrderStatus status, DateTime? at, String? note});
}

/// @nodoc
class __$$ShopOrderEventImplCopyWithImpl<$Res>
    extends _$ShopOrderEventCopyWithImpl<$Res, _$ShopOrderEventImpl>
    implements _$$ShopOrderEventImplCopyWith<$Res> {
  __$$ShopOrderEventImplCopyWithImpl(
      _$ShopOrderEventImpl _value, $Res Function(_$ShopOrderEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? at = freezed,
    Object? note = freezed,
  }) {
    return _then(_$ShopOrderEventImpl(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShopOrderStatus,
      at: freezed == at
          ? _value.at
          : at // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      note: freezed == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShopOrderEventImpl implements _ShopOrderEvent {
  const _$ShopOrderEventImpl({required this.status, this.at, this.note});

  factory _$ShopOrderEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopOrderEventImplFromJson(json);

  @override
  final ShopOrderStatus status;
  @override
  final DateTime? at;
  @override
  final String? note;

  @override
  String toString() {
    return 'ShopOrderEvent(status: $status, at: $at, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopOrderEventImpl &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.at, at) || other.at == at) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, status, at, note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopOrderEventImplCopyWith<_$ShopOrderEventImpl> get copyWith =>
      __$$ShopOrderEventImplCopyWithImpl<_$ShopOrderEventImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopOrderEventImplToJson(
      this,
    );
  }
}

abstract class _ShopOrderEvent implements ShopOrderEvent {
  const factory _ShopOrderEvent(
      {required final ShopOrderStatus status,
      final DateTime? at,
      final String? note}) = _$ShopOrderEventImpl;

  factory _ShopOrderEvent.fromJson(Map<String, dynamic> json) =
      _$ShopOrderEventImpl.fromJson;

  @override
  ShopOrderStatus get status;
  @override
  DateTime? get at;
  @override
  String? get note;
  @override
  @JsonKey(ignore: true)
  _$$ShopOrderEventImplCopyWith<_$ShopOrderEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ShopOrder _$ShopOrderFromJson(Map<String, dynamic> json) {
  return _ShopOrder.fromJson(json);
}

/// @nodoc
mixin _$ShopOrder {
  String get id => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String? get orderId => throw _privateConstructorUsedError;
  ShopOrderStatus get status => throw _privateConstructorUsedError;
  List<ShopOrderItem> get items => throw _privateConstructorUsedError;
  ShopDelivery? get delivery => throw _privateConstructorUsedError;
  num get totalAmount => throw _privateConstructorUsedError;

  /// The part settled from the wallet — i.e. paid in Lumi coins.
  num get walletAmount => throw _privateConstructorUsedError;

  /// The part actually charged to a card.
  num get paidAmount => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  /// paid_at + 3 days. What the app promises and what the buyer is waiting on.
  DateTime? get promisedBy => throw _privateConstructorUsedError;
  DateTime? get paidAt => throw _privateConstructorUsedError;
  DateTime? get deliveredAt => throw _privateConstructorUsedError;
  DateTime? get canceledAt => throw _privateConstructorUsedError;
  List<ShopOrderEvent> get timeline => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShopOrderCopyWith<ShopOrder> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShopOrderCopyWith<$Res> {
  factory $ShopOrderCopyWith(ShopOrder value, $Res Function(ShopOrder) then) =
      _$ShopOrderCopyWithImpl<$Res, ShopOrder>;
  @useResult
  $Res call(
      {String id,
      String code,
      String? orderId,
      ShopOrderStatus status,
      List<ShopOrderItem> items,
      ShopDelivery? delivery,
      num totalAmount,
      num walletAmount,
      num paidAmount,
      String currency,
      DateTime? promisedBy,
      DateTime? paidAt,
      DateTime? deliveredAt,
      DateTime? canceledAt,
      List<ShopOrderEvent> timeline,
      DateTime? createdAt});

  $ShopDeliveryCopyWith<$Res>? get delivery;
}

/// @nodoc
class _$ShopOrderCopyWithImpl<$Res, $Val extends ShopOrder>
    implements $ShopOrderCopyWith<$Res> {
  _$ShopOrderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? orderId = freezed,
    Object? status = null,
    Object? items = null,
    Object? delivery = freezed,
    Object? totalAmount = null,
    Object? walletAmount = null,
    Object? paidAmount = null,
    Object? currency = null,
    Object? promisedBy = freezed,
    Object? paidAt = freezed,
    Object? deliveredAt = freezed,
    Object? canceledAt = freezed,
    Object? timeline = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShopOrderStatus,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ShopOrderItem>,
      delivery: freezed == delivery
          ? _value.delivery
          : delivery // ignore: cast_nullable_to_non_nullable
              as ShopDelivery?,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as num,
      walletAmount: null == walletAmount
          ? _value.walletAmount
          : walletAmount // ignore: cast_nullable_to_non_nullable
              as num,
      paidAmount: null == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as num,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      promisedBy: freezed == promisedBy
          ? _value.promisedBy
          : promisedBy // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      canceledAt: freezed == canceledAt
          ? _value.canceledAt
          : canceledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeline: null == timeline
          ? _value.timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<ShopOrderEvent>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ShopDeliveryCopyWith<$Res>? get delivery {
    if (_value.delivery == null) {
      return null;
    }

    return $ShopDeliveryCopyWith<$Res>(_value.delivery!, (value) {
      return _then(_value.copyWith(delivery: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ShopOrderImplCopyWith<$Res>
    implements $ShopOrderCopyWith<$Res> {
  factory _$$ShopOrderImplCopyWith(
          _$ShopOrderImpl value, $Res Function(_$ShopOrderImpl) then) =
      __$$ShopOrderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String code,
      String? orderId,
      ShopOrderStatus status,
      List<ShopOrderItem> items,
      ShopDelivery? delivery,
      num totalAmount,
      num walletAmount,
      num paidAmount,
      String currency,
      DateTime? promisedBy,
      DateTime? paidAt,
      DateTime? deliveredAt,
      DateTime? canceledAt,
      List<ShopOrderEvent> timeline,
      DateTime? createdAt});

  @override
  $ShopDeliveryCopyWith<$Res>? get delivery;
}

/// @nodoc
class __$$ShopOrderImplCopyWithImpl<$Res>
    extends _$ShopOrderCopyWithImpl<$Res, _$ShopOrderImpl>
    implements _$$ShopOrderImplCopyWith<$Res> {
  __$$ShopOrderImplCopyWithImpl(
      _$ShopOrderImpl _value, $Res Function(_$ShopOrderImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? orderId = freezed,
    Object? status = null,
    Object? items = null,
    Object? delivery = freezed,
    Object? totalAmount = null,
    Object? walletAmount = null,
    Object? paidAmount = null,
    Object? currency = null,
    Object? promisedBy = freezed,
    Object? paidAt = freezed,
    Object? deliveredAt = freezed,
    Object? canceledAt = freezed,
    Object? timeline = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$ShopOrderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      orderId: freezed == orderId
          ? _value.orderId
          : orderId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ShopOrderStatus,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<ShopOrderItem>,
      delivery: freezed == delivery
          ? _value.delivery
          : delivery // ignore: cast_nullable_to_non_nullable
              as ShopDelivery?,
      totalAmount: null == totalAmount
          ? _value.totalAmount
          : totalAmount // ignore: cast_nullable_to_non_nullable
              as num,
      walletAmount: null == walletAmount
          ? _value.walletAmount
          : walletAmount // ignore: cast_nullable_to_non_nullable
              as num,
      paidAmount: null == paidAmount
          ? _value.paidAmount
          : paidAmount // ignore: cast_nullable_to_non_nullable
              as num,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      promisedBy: freezed == promisedBy
          ? _value.promisedBy
          : promisedBy // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      paidAt: freezed == paidAt
          ? _value.paidAt
          : paidAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deliveredAt: freezed == deliveredAt
          ? _value.deliveredAt
          : deliveredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      canceledAt: freezed == canceledAt
          ? _value.canceledAt
          : canceledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      timeline: null == timeline
          ? _value._timeline
          : timeline // ignore: cast_nullable_to_non_nullable
              as List<ShopOrderEvent>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ShopOrderImpl extends _ShopOrder {
  const _$ShopOrderImpl(
      {this.id = '',
      this.code = '',
      this.orderId,
      this.status = ShopOrderStatus.isNew,
      final List<ShopOrderItem> items = const [],
      this.delivery,
      this.totalAmount = 0,
      this.walletAmount = 0,
      this.paidAmount = 0,
      this.currency = 'UZS',
      this.promisedBy,
      this.paidAt,
      this.deliveredAt,
      this.canceledAt,
      final List<ShopOrderEvent> timeline = const [],
      this.createdAt})
      : _items = items,
        _timeline = timeline,
        super._();

  factory _$ShopOrderImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShopOrderImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String code;
  @override
  final String? orderId;
  @override
  @JsonKey()
  final ShopOrderStatus status;
  final List<ShopOrderItem> _items;
  @override
  @JsonKey()
  List<ShopOrderItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final ShopDelivery? delivery;
  @override
  @JsonKey()
  final num totalAmount;

  /// The part settled from the wallet — i.e. paid in Lumi coins.
  @override
  @JsonKey()
  final num walletAmount;

  /// The part actually charged to a card.
  @override
  @JsonKey()
  final num paidAmount;
  @override
  @JsonKey()
  final String currency;

  /// paid_at + 3 days. What the app promises and what the buyer is waiting on.
  @override
  final DateTime? promisedBy;
  @override
  final DateTime? paidAt;
  @override
  final DateTime? deliveredAt;
  @override
  final DateTime? canceledAt;
  final List<ShopOrderEvent> _timeline;
  @override
  @JsonKey()
  List<ShopOrderEvent> get timeline {
    if (_timeline is EqualUnmodifiableListView) return _timeline;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeline);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'ShopOrder(id: $id, code: $code, orderId: $orderId, status: $status, items: $items, delivery: $delivery, totalAmount: $totalAmount, walletAmount: $walletAmount, paidAmount: $paidAmount, currency: $currency, promisedBy: $promisedBy, paidAt: $paidAt, deliveredAt: $deliveredAt, canceledAt: $canceledAt, timeline: $timeline, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShopOrderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.orderId, orderId) || other.orderId == orderId) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.delivery, delivery) ||
                other.delivery == delivery) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.walletAmount, walletAmount) ||
                other.walletAmount == walletAmount) &&
            (identical(other.paidAmount, paidAmount) ||
                other.paidAmount == paidAmount) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.promisedBy, promisedBy) ||
                other.promisedBy == promisedBy) &&
            (identical(other.paidAt, paidAt) || other.paidAt == paidAt) &&
            (identical(other.deliveredAt, deliveredAt) ||
                other.deliveredAt == deliveredAt) &&
            (identical(other.canceledAt, canceledAt) ||
                other.canceledAt == canceledAt) &&
            const DeepCollectionEquality().equals(other._timeline, _timeline) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      orderId,
      status,
      const DeepCollectionEquality().hash(_items),
      delivery,
      totalAmount,
      walletAmount,
      paidAmount,
      currency,
      promisedBy,
      paidAt,
      deliveredAt,
      canceledAt,
      const DeepCollectionEquality().hash(_timeline),
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShopOrderImplCopyWith<_$ShopOrderImpl> get copyWith =>
      __$$ShopOrderImplCopyWithImpl<_$ShopOrderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShopOrderImplToJson(
      this,
    );
  }
}

abstract class _ShopOrder extends ShopOrder {
  const factory _ShopOrder(
      {final String id,
      final String code,
      final String? orderId,
      final ShopOrderStatus status,
      final List<ShopOrderItem> items,
      final ShopDelivery? delivery,
      final num totalAmount,
      final num walletAmount,
      final num paidAmount,
      final String currency,
      final DateTime? promisedBy,
      final DateTime? paidAt,
      final DateTime? deliveredAt,
      final DateTime? canceledAt,
      final List<ShopOrderEvent> timeline,
      final DateTime? createdAt}) = _$ShopOrderImpl;
  const _ShopOrder._() : super._();

  factory _ShopOrder.fromJson(Map<String, dynamic> json) =
      _$ShopOrderImpl.fromJson;

  @override
  String get id;
  @override
  String get code;
  @override
  String? get orderId;
  @override
  ShopOrderStatus get status;
  @override
  List<ShopOrderItem> get items;
  @override
  ShopDelivery? get delivery;
  @override
  num get totalAmount;
  @override

  /// The part settled from the wallet — i.e. paid in Lumi coins.
  num get walletAmount;
  @override

  /// The part actually charged to a card.
  num get paidAmount;
  @override
  String get currency;
  @override

  /// paid_at + 3 days. What the app promises and what the buyer is waiting on.
  DateTime? get promisedBy;
  @override
  DateTime? get paidAt;
  @override
  DateTime? get deliveredAt;
  @override
  DateTime? get canceledAt;
  @override
  List<ShopOrderEvent> get timeline;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ShopOrderImplCopyWith<_$ShopOrderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

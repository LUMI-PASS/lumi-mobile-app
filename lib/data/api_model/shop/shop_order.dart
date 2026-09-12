import 'package:freezed_annotation/freezed_annotation.dart';

part 'shop_order.freezed.dart';
part 'shop_order.g.dart';

/// Where a paid merch order has got to. Mirrors `ShopOrderStatus` server-side.
enum ShopOrderStatus {
  @JsonValue('new')
  isNew,
  @JsonValue('confirmed')
  confirmed,
  @JsonValue('delivering')
  delivering,
  @JsonValue('delivered')
  delivered,
  @JsonValue('canceled')
  canceled,
}

extension ShopOrderStatusX on ShopOrderStatus {
  /// Translation key for the status chip and the timeline.
  String get labelKey => switch (this) {
        ShopOrderStatus.isNew => 'shop_status_new',
        ShopOrderStatus.confirmed => 'shop_status_confirmed',
        ShopOrderStatus.delivering => 'shop_status_delivering',
        ShopOrderStatus.delivered => 'shop_status_delivered',
        ShopOrderStatus.canceled => 'shop_status_canceled',
      };

  /// Only an order nobody has picked up yet can be called off from the app.
  /// Past that it is a phone call, and the server says so too.
  bool get isCancelable => this == ShopOrderStatus.isNew;

  bool get isFinished =>
      this == ShopOrderStatus.delivered || this == ShopOrderStatus.canceled;
}

/// Where the courier is going.
@freezed
class ShopDelivery with _$ShopDelivery {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ShopDelivery({
    @Default(0) double lat,
    @Default(0) double lng,
    @Default('') String address,
    String? contactName,
    @Default('') String contactPhone,
    String? comment,
  }) = _ShopDelivery;

  factory ShopDelivery.fromJson(Map<String, dynamic> json) =>
      _$ShopDeliveryFromJson(json);
}

/// One line of an order, with the product as it was AT PURCHASE TIME — the
/// name and price are snapshots, so a later rename or repricing cannot change
/// what a receipt from last month says.
@freezed
class ShopOrderItem with _$ShopOrderItem {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ShopOrderItem({
    @Default('') String productId,
    @Default(null) Map<String, dynamic>? name,
    String? image,
    @Default(0) num unitPrice,
    @Default(1) int count,
  }) = _ShopOrderItem;

  const ShopOrderItem._();

  factory ShopOrderItem.fromJson(Map<String, dynamic> json) =>
      _$ShopOrderItemFromJson(json);

  num get lineTotal => unitPrice * count;
}

/// One step of the delivery history.
@freezed
class ShopOrderEvent with _$ShopOrderEvent {
  const factory ShopOrderEvent({
    required ShopOrderStatus status,
    DateTime? at,
    String? note,
  }) = _ShopOrderEvent;

  factory ShopOrderEvent.fromJson(Map<String, dynamic> json) =>
      _$ShopOrderEventFromJson(json);
}

/// A paid merch purchase, from `GET /api/shop/orders`.
@freezed
class ShopOrder with _$ShopOrder {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ShopOrder({
    @Default('') String id,
    @Default('') String code,
    String? orderId,
    @Default(ShopOrderStatus.isNew) ShopOrderStatus status,
    @Default([]) List<ShopOrderItem> items,
    ShopDelivery? delivery,
    @Default(0) num totalAmount,

    /// The part settled from the wallet — i.e. paid in Lumi coins.
    @Default(0) num walletAmount,

    /// The part actually charged to a card.
    @Default(0) num paidAmount,
    @Default('UZS') String currency,

    /// paid_at + 3 days. What the app promises and what the buyer is waiting on.
    DateTime? promisedBy,
    DateTime? paidAt,
    DateTime? deliveredAt,
    DateTime? canceledAt,
    @Default([]) List<ShopOrderEvent> timeline,
    DateTime? createdAt,
  }) = _ShopOrder;

  const ShopOrder._();

  factory ShopOrder.fromJson(Map<String, dynamic> json) =>
      _$ShopOrderFromJson(json);

  int get itemCount => items.fold(0, (sum, item) => sum + item.count);

  /// Whether the buyer may still call it off themselves.
  bool get isCancelable => status.isCancelable;
}

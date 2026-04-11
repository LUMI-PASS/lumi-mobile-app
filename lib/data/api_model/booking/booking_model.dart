import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_model.freezed.dart';
part 'booking_model.g.dart';

@freezed
class BookingRequest with _$BookingRequest {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory BookingRequest({
    required String scheduleId,
    required String childId,
    required String subscriptionId,
  }) = _BookingRequest;

  factory BookingRequest.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestFromJson(json);
}

@freezed
class BookingResponse with _$BookingResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory BookingResponse({
    String? id,
    String? scheduleId,
    String? childId,
    String? bookingStatus,
    num? chargedCoinAmount,
    bool? isTrialBooking,
    String? attendanceStatus,
    String? createdAt,
    String? updatedAt,
  }) = _BookingResponse;

  factory BookingResponse.fromJson(Map<String, dynamic> json) =>
      _$BookingResponseFromJson(json);
}

@freezed
class PurchaseResponse with _$PurchaseResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PurchaseResponse({
    String? id,
    String? parentId,
    String? tariffId,
    String? startDate,
    String? endDate,
    String? status,
    int? coins,
    int? amount,
    PurchaseTransaction? transaction,
    String? createdAt,
    String? updatedAt,
  }) = _PurchaseResponse;

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) =>
      _$PurchaseResponseFromJson(json);
}

@freezed
class PurchaseTransaction with _$PurchaseTransaction {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PurchaseTransaction({
    String? id,
    String? paymentMethod,
    String? status,
    String? checkoutUrl,
    String? createdAt,
    String? updatedAt,
  }) = _PurchaseTransaction;

  factory PurchaseTransaction.fromJson(Map<String, dynamic> json) =>
      _$PurchaseTransactionFromJson(json);
}

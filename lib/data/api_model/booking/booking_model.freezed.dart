// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BookingRequest _$BookingRequestFromJson(Map<String, dynamic> json) {
  return _BookingRequest.fromJson(json);
}

/// @nodoc
mixin _$BookingRequest {
  String get scheduleId => throw _privateConstructorUsedError;
  String get childId => throw _privateConstructorUsedError;
  String get subscriptionId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingRequestCopyWith<BookingRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingRequestCopyWith<$Res> {
  factory $BookingRequestCopyWith(
          BookingRequest value, $Res Function(BookingRequest) then) =
      _$BookingRequestCopyWithImpl<$Res, BookingRequest>;
  @useResult
  $Res call({String scheduleId, String childId, String subscriptionId});
}

/// @nodoc
class _$BookingRequestCopyWithImpl<$Res, $Val extends BookingRequest>
    implements $BookingRequestCopyWith<$Res> {
  _$BookingRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleId = null,
    Object? childId = null,
    Object? subscriptionId = null,
  }) {
    return _then(_value.copyWith(
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionId: null == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingRequestImplCopyWith<$Res>
    implements $BookingRequestCopyWith<$Res> {
  factory _$$BookingRequestImplCopyWith(_$BookingRequestImpl value,
          $Res Function(_$BookingRequestImpl) then) =
      __$$BookingRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String scheduleId, String childId, String subscriptionId});
}

/// @nodoc
class __$$BookingRequestImplCopyWithImpl<$Res>
    extends _$BookingRequestCopyWithImpl<$Res, _$BookingRequestImpl>
    implements _$$BookingRequestImplCopyWith<$Res> {
  __$$BookingRequestImplCopyWithImpl(
      _$BookingRequestImpl _value, $Res Function(_$BookingRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduleId = null,
    Object? childId = null,
    Object? subscriptionId = null,
  }) {
    return _then(_$BookingRequestImpl(
      scheduleId: null == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String,
      childId: null == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String,
      subscriptionId: null == subscriptionId
          ? _value.subscriptionId
          : subscriptionId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$BookingRequestImpl implements _BookingRequest {
  const _$BookingRequestImpl(
      {required this.scheduleId,
      required this.childId,
      required this.subscriptionId});

  factory _$BookingRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingRequestImplFromJson(json);

  @override
  final String scheduleId;
  @override
  final String childId;
  @override
  final String subscriptionId;

  @override
  String toString() {
    return 'BookingRequest(scheduleId: $scheduleId, childId: $childId, subscriptionId: $subscriptionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingRequestImpl &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.subscriptionId, subscriptionId) ||
                other.subscriptionId == subscriptionId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, scheduleId, childId, subscriptionId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingRequestImplCopyWith<_$BookingRequestImpl> get copyWith =>
      __$$BookingRequestImplCopyWithImpl<_$BookingRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingRequestImplToJson(
      this,
    );
  }
}

abstract class _BookingRequest implements BookingRequest {
  const factory _BookingRequest(
      {required final String scheduleId,
      required final String childId,
      required final String subscriptionId}) = _$BookingRequestImpl;

  factory _BookingRequest.fromJson(Map<String, dynamic> json) =
      _$BookingRequestImpl.fromJson;

  @override
  String get scheduleId;
  @override
  String get childId;
  @override
  String get subscriptionId;
  @override
  @JsonKey(ignore: true)
  _$$BookingRequestImplCopyWith<_$BookingRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BookingResponse _$BookingResponseFromJson(Map<String, dynamic> json) {
  return _BookingResponse.fromJson(json);
}

/// @nodoc
mixin _$BookingResponse {
  String? get id => throw _privateConstructorUsedError;
  String? get scheduleId => throw _privateConstructorUsedError;
  String? get childId => throw _privateConstructorUsedError;
  String? get bookingStatus => throw _privateConstructorUsedError;
  num? get chargedCoinAmount => throw _privateConstructorUsedError;
  bool? get isTrialBooking => throw _privateConstructorUsedError;
  String? get attendanceStatus => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BookingResponseCopyWith<BookingResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingResponseCopyWith<$Res> {
  factory $BookingResponseCopyWith(
          BookingResponse value, $Res Function(BookingResponse) then) =
      _$BookingResponseCopyWithImpl<$Res, BookingResponse>;
  @useResult
  $Res call(
      {String? id,
      String? scheduleId,
      String? childId,
      String? bookingStatus,
      num? chargedCoinAmount,
      bool? isTrialBooking,
      String? attendanceStatus,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class _$BookingResponseCopyWithImpl<$Res, $Val extends BookingResponse>
    implements $BookingResponseCopyWith<$Res> {
  _$BookingResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? scheduleId = freezed,
    Object? childId = freezed,
    Object? bookingStatus = freezed,
    Object? chargedCoinAmount = freezed,
    Object? isTrialBooking = freezed,
    Object? attendanceStatus = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      chargedCoinAmount: freezed == chargedCoinAmount
          ? _value.chargedCoinAmount
          : chargedCoinAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      isTrialBooking: freezed == isTrialBooking
          ? _value.isTrialBooking
          : isTrialBooking // ignore: cast_nullable_to_non_nullable
              as bool?,
      attendanceStatus: freezed == attendanceStatus
          ? _value.attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingResponseImplCopyWith<$Res>
    implements $BookingResponseCopyWith<$Res> {
  factory _$$BookingResponseImplCopyWith(_$BookingResponseImpl value,
          $Res Function(_$BookingResponseImpl) then) =
      __$$BookingResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? scheduleId,
      String? childId,
      String? bookingStatus,
      num? chargedCoinAmount,
      bool? isTrialBooking,
      String? attendanceStatus,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class __$$BookingResponseImplCopyWithImpl<$Res>
    extends _$BookingResponseCopyWithImpl<$Res, _$BookingResponseImpl>
    implements _$$BookingResponseImplCopyWith<$Res> {
  __$$BookingResponseImplCopyWithImpl(
      _$BookingResponseImpl _value, $Res Function(_$BookingResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? scheduleId = freezed,
    Object? childId = freezed,
    Object? bookingStatus = freezed,
    Object? chargedCoinAmount = freezed,
    Object? isTrialBooking = freezed,
    Object? attendanceStatus = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$BookingResponseImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      chargedCoinAmount: freezed == chargedCoinAmount
          ? _value.chargedCoinAmount
          : chargedCoinAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      isTrialBooking: freezed == isTrialBooking
          ? _value.isTrialBooking
          : isTrialBooking // ignore: cast_nullable_to_non_nullable
              as bool?,
      attendanceStatus: freezed == attendanceStatus
          ? _value.attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$BookingResponseImpl implements _BookingResponse {
  const _$BookingResponseImpl(
      {this.id,
      this.scheduleId,
      this.childId,
      this.bookingStatus,
      this.chargedCoinAmount,
      this.isTrialBooking,
      this.attendanceStatus,
      this.createdAt,
      this.updatedAt});

  factory _$BookingResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookingResponseImplFromJson(json);

  @override
  final String? id;
  @override
  final String? scheduleId;
  @override
  final String? childId;
  @override
  final String? bookingStatus;
  @override
  final num? chargedCoinAmount;
  @override
  final bool? isTrialBooking;
  @override
  final String? attendanceStatus;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'BookingResponse(id: $id, scheduleId: $scheduleId, childId: $childId, bookingStatus: $bookingStatus, chargedCoinAmount: $chargedCoinAmount, isTrialBooking: $isTrialBooking, attendanceStatus: $attendanceStatus, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.chargedCoinAmount, chargedCoinAmount) ||
                other.chargedCoinAmount == chargedCoinAmount) &&
            (identical(other.isTrialBooking, isTrialBooking) ||
                other.isTrialBooking == isTrialBooking) &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      scheduleId,
      childId,
      bookingStatus,
      chargedCoinAmount,
      isTrialBooking,
      attendanceStatus,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingResponseImplCopyWith<_$BookingResponseImpl> get copyWith =>
      __$$BookingResponseImplCopyWithImpl<_$BookingResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BookingResponseImplToJson(
      this,
    );
  }
}

abstract class _BookingResponse implements BookingResponse {
  const factory _BookingResponse(
      {final String? id,
      final String? scheduleId,
      final String? childId,
      final String? bookingStatus,
      final num? chargedCoinAmount,
      final bool? isTrialBooking,
      final String? attendanceStatus,
      final String? createdAt,
      final String? updatedAt}) = _$BookingResponseImpl;

  factory _BookingResponse.fromJson(Map<String, dynamic> json) =
      _$BookingResponseImpl.fromJson;

  @override
  String? get id;
  @override
  String? get scheduleId;
  @override
  String? get childId;
  @override
  String? get bookingStatus;
  @override
  num? get chargedCoinAmount;
  @override
  bool? get isTrialBooking;
  @override
  String? get attendanceStatus;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$BookingResponseImplCopyWith<_$BookingResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseResponse _$PurchaseResponseFromJson(Map<String, dynamic> json) {
  return _PurchaseResponse.fromJson(json);
}

/// @nodoc
mixin _$PurchaseResponse {
  String? get id => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String? get tariffId => throw _privateConstructorUsedError;
  String? get startDate => throw _privateConstructorUsedError;
  String? get endDate => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  int? get coins => throw _privateConstructorUsedError;
  int? get amount => throw _privateConstructorUsedError;
  PurchaseTransaction? get transaction => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseResponseCopyWith<PurchaseResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseResponseCopyWith<$Res> {
  factory $PurchaseResponseCopyWith(
          PurchaseResponse value, $Res Function(PurchaseResponse) then) =
      _$PurchaseResponseCopyWithImpl<$Res, PurchaseResponse>;
  @useResult
  $Res call(
      {String? id,
      String? parentId,
      String? tariffId,
      String? startDate,
      String? endDate,
      String? status,
      int? coins,
      int? amount,
      PurchaseTransaction? transaction,
      String? createdAt,
      String? updatedAt});

  $PurchaseTransactionCopyWith<$Res>? get transaction;
}

/// @nodoc
class _$PurchaseResponseCopyWithImpl<$Res, $Val extends PurchaseResponse>
    implements $PurchaseResponseCopyWith<$Res> {
  _$PurchaseResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? parentId = freezed,
    Object? tariffId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? status = freezed,
    Object? coins = freezed,
    Object? amount = freezed,
    Object? transaction = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      tariffId: freezed == tariffId
          ? _value.tariffId
          : tariffId // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      coins: freezed == coins
          ? _value.coins
          : coins // ignore: cast_nullable_to_non_nullable
              as int?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as PurchaseTransaction?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PurchaseTransactionCopyWith<$Res>? get transaction {
    if (_value.transaction == null) {
      return null;
    }

    return $PurchaseTransactionCopyWith<$Res>(_value.transaction!, (value) {
      return _then(_value.copyWith(transaction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PurchaseResponseImplCopyWith<$Res>
    implements $PurchaseResponseCopyWith<$Res> {
  factory _$$PurchaseResponseImplCopyWith(_$PurchaseResponseImpl value,
          $Res Function(_$PurchaseResponseImpl) then) =
      __$$PurchaseResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? parentId,
      String? tariffId,
      String? startDate,
      String? endDate,
      String? status,
      int? coins,
      int? amount,
      PurchaseTransaction? transaction,
      String? createdAt,
      String? updatedAt});

  @override
  $PurchaseTransactionCopyWith<$Res>? get transaction;
}

/// @nodoc
class __$$PurchaseResponseImplCopyWithImpl<$Res>
    extends _$PurchaseResponseCopyWithImpl<$Res, _$PurchaseResponseImpl>
    implements _$$PurchaseResponseImplCopyWith<$Res> {
  __$$PurchaseResponseImplCopyWithImpl(_$PurchaseResponseImpl _value,
      $Res Function(_$PurchaseResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? parentId = freezed,
    Object? tariffId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? status = freezed,
    Object? coins = freezed,
    Object? amount = freezed,
    Object? transaction = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PurchaseResponseImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      tariffId: freezed == tariffId
          ? _value.tariffId
          : tariffId // ignore: cast_nullable_to_non_nullable
              as String?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      coins: freezed == coins
          ? _value.coins
          : coins // ignore: cast_nullable_to_non_nullable
              as int?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as int?,
      transaction: freezed == transaction
          ? _value.transaction
          : transaction // ignore: cast_nullable_to_non_nullable
              as PurchaseTransaction?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$PurchaseResponseImpl implements _PurchaseResponse {
  const _$PurchaseResponseImpl(
      {this.id,
      this.parentId,
      this.tariffId,
      this.startDate,
      this.endDate,
      this.status,
      this.coins,
      this.amount,
      this.transaction,
      this.createdAt,
      this.updatedAt});

  factory _$PurchaseResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseResponseImplFromJson(json);

  @override
  final String? id;
  @override
  final String? parentId;
  @override
  final String? tariffId;
  @override
  final String? startDate;
  @override
  final String? endDate;
  @override
  final String? status;
  @override
  final int? coins;
  @override
  final int? amount;
  @override
  final PurchaseTransaction? transaction;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'PurchaseResponse(id: $id, parentId: $parentId, tariffId: $tariffId, startDate: $startDate, endDate: $endDate, status: $status, coins: $coins, amount: $amount, transaction: $transaction, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseResponseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.tariffId, tariffId) ||
                other.tariffId == tariffId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.coins, coins) || other.coins == coins) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.transaction, transaction) ||
                other.transaction == transaction) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      parentId,
      tariffId,
      startDate,
      endDate,
      status,
      coins,
      amount,
      transaction,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseResponseImplCopyWith<_$PurchaseResponseImpl> get copyWith =>
      __$$PurchaseResponseImplCopyWithImpl<_$PurchaseResponseImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseResponseImplToJson(
      this,
    );
  }
}

abstract class _PurchaseResponse implements PurchaseResponse {
  const factory _PurchaseResponse(
      {final String? id,
      final String? parentId,
      final String? tariffId,
      final String? startDate,
      final String? endDate,
      final String? status,
      final int? coins,
      final int? amount,
      final PurchaseTransaction? transaction,
      final String? createdAt,
      final String? updatedAt}) = _$PurchaseResponseImpl;

  factory _PurchaseResponse.fromJson(Map<String, dynamic> json) =
      _$PurchaseResponseImpl.fromJson;

  @override
  String? get id;
  @override
  String? get parentId;
  @override
  String? get tariffId;
  @override
  String? get startDate;
  @override
  String? get endDate;
  @override
  String? get status;
  @override
  int? get coins;
  @override
  int? get amount;
  @override
  PurchaseTransaction? get transaction;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseResponseImplCopyWith<_$PurchaseResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PurchaseTransaction _$PurchaseTransactionFromJson(Map<String, dynamic> json) {
  return _PurchaseTransaction.fromJson(json);
}

/// @nodoc
mixin _$PurchaseTransaction {
  String? get id => throw _privateConstructorUsedError;
  String? get paymentMethod => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get checkoutUrl => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PurchaseTransactionCopyWith<PurchaseTransaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PurchaseTransactionCopyWith<$Res> {
  factory $PurchaseTransactionCopyWith(
          PurchaseTransaction value, $Res Function(PurchaseTransaction) then) =
      _$PurchaseTransactionCopyWithImpl<$Res, PurchaseTransaction>;
  @useResult
  $Res call(
      {String? id,
      String? paymentMethod,
      String? status,
      String? checkoutUrl,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class _$PurchaseTransactionCopyWithImpl<$Res, $Val extends PurchaseTransaction>
    implements $PurchaseTransactionCopyWith<$Res> {
  _$PurchaseTransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? paymentMethod = freezed,
    Object? status = freezed,
    Object? checkoutUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      checkoutUrl: freezed == checkoutUrl
          ? _value.checkoutUrl
          : checkoutUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PurchaseTransactionImplCopyWith<$Res>
    implements $PurchaseTransactionCopyWith<$Res> {
  factory _$$PurchaseTransactionImplCopyWith(_$PurchaseTransactionImpl value,
          $Res Function(_$PurchaseTransactionImpl) then) =
      __$$PurchaseTransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? paymentMethod,
      String? status,
      String? checkoutUrl,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class __$$PurchaseTransactionImplCopyWithImpl<$Res>
    extends _$PurchaseTransactionCopyWithImpl<$Res, _$PurchaseTransactionImpl>
    implements _$$PurchaseTransactionImplCopyWith<$Res> {
  __$$PurchaseTransactionImplCopyWithImpl(_$PurchaseTransactionImpl _value,
      $Res Function(_$PurchaseTransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? paymentMethod = freezed,
    Object? status = freezed,
    Object? checkoutUrl = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$PurchaseTransactionImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      paymentMethod: freezed == paymentMethod
          ? _value.paymentMethod
          : paymentMethod // ignore: cast_nullable_to_non_nullable
              as String?,
      status: freezed == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String?,
      checkoutUrl: freezed == checkoutUrl
          ? _value.checkoutUrl
          : checkoutUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$PurchaseTransactionImpl implements _PurchaseTransaction {
  const _$PurchaseTransactionImpl(
      {this.id,
      this.paymentMethod,
      this.status,
      this.checkoutUrl,
      this.createdAt,
      this.updatedAt});

  factory _$PurchaseTransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$PurchaseTransactionImplFromJson(json);

  @override
  final String? id;
  @override
  final String? paymentMethod;
  @override
  final String? status;
  @override
  final String? checkoutUrl;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'PurchaseTransaction(id: $id, paymentMethod: $paymentMethod, status: $status, checkoutUrl: $checkoutUrl, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PurchaseTransactionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.paymentMethod, paymentMethod) ||
                other.paymentMethod == paymentMethod) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.checkoutUrl, checkoutUrl) ||
                other.checkoutUrl == checkoutUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, paymentMethod, status,
      checkoutUrl, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PurchaseTransactionImplCopyWith<_$PurchaseTransactionImpl> get copyWith =>
      __$$PurchaseTransactionImplCopyWithImpl<_$PurchaseTransactionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PurchaseTransactionImplToJson(
      this,
    );
  }
}

abstract class _PurchaseTransaction implements PurchaseTransaction {
  const factory _PurchaseTransaction(
      {final String? id,
      final String? paymentMethod,
      final String? status,
      final String? checkoutUrl,
      final String? createdAt,
      final String? updatedAt}) = _$PurchaseTransactionImpl;

  factory _PurchaseTransaction.fromJson(Map<String, dynamic> json) =
      _$PurchaseTransactionImpl.fromJson;

  @override
  String? get id;
  @override
  String? get paymentMethod;
  @override
  String? get status;
  @override
  String? get checkoutUrl;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$PurchaseTransactionImplCopyWith<_$PurchaseTransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

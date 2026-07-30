import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';
import 'package:lumi_pass/data/api_model/order/user_order.dart';
import 'package:lumi_pass/data/api_model/subscription/subscription_record.dart';

@injectable
class OrdersApi {
  final Dio _dio;

  OrdersApi(this._dio);

  Future<ClassFullModel> getClassFull(String id) async {
    final response = await _dio.get('classes/$id');
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return ClassFullModel.fromJson(data);
  }

  /// Returns the bookable days inside [from, to] for an activity. Each entry
  /// holds the slots that apply on that date — empty when the class doesn't
  /// run that day. Powers the calendar carousel without dumping the full
  /// recurring schedule.
  Future<List<ScheduleDay>> getScheduleDays(
    String activityId, {
    required String from,
    required String to,
  }) async {
    final response = await _dio.get(
      'schedules/activity/$activityId/days',
      queryParameters: {'from': from, 'to': to},
    );
    final raw = response.data;
    final list = raw is Map && raw['data'] is List
        ? raw['data'] as List
        : (raw is List ? raw : const []);
    return list
        .whereType<Map>()
        .map((e) => ScheduleDay.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Returns the slots for a single concrete date. Empty when the class
  /// doesn't run that day or the date is outside every active window.
  Future<List<ScheduleSlotInfo>> getScheduleSlotsForDate(
    String activityId, {
    required String date,
  }) async {
    final response = await _dio.get(
      'schedules/activity/$activityId/slots',
      queryParameters: {'date': date},
    );
    final raw = response.data;
    final list = raw is Map && raw['slots'] is List
        ? raw['slots'] as List
        : const [];
    return list
        .whereType<Map>()
        .map((e) => ScheduleSlotInfo.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Paginated list of the authenticated user's orders (= transactions). The
  /// top-level payload is not wrapped in `data:`; pagination fields sit at
  /// the root.
  Future<List<UserOrder>> getOrders({int page = 1, int limit = 50}) async {
    final response = await _dio.get(
      'orders',
      queryParameters: {'page': page, 'limit': limit},
    );
    final raw = response.data;
    final List list;
    if (raw is Map && raw['data'] is List) {
      list = raw['data'] as List;
    } else if (raw is List) {
      list = raw;
    } else {
      list = const [];
    }
    return list
        .whereType<Map>()
        .map((e) => UserOrder.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<OrderDetail> getOrderDetail(String orderId) async {
    final response = await _dio.get('orders/$orderId');
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return OrderDetail.fromJson(data);
  }

  /// Fetches the OFD/Soliq fiscal receipt URL for a PAID order on demand.
  /// Used as a fallback when the order-detail payload didn't already carry it.
  /// Returns null when no fiscal receipt exists yet (e.g. not fiscalized).
  Future<String?> getOrderReceipt(String orderId) async {
    final response = await _dio.get('orders/$orderId/receipt');
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});
    for (final key in ['receipt_url', 'ofd_url', 'fiscal_url', 'qr_code_url', 'url']) {
      final v = data[key];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  Future<void> createChild({required String name, required int age}) async {
    await _dio.post('children', data: {'name': name, 'age': age, 'gender': 'any'});
  }

  /// Dev-only: flips a PENDING order to PAID without going through Paycom.
  /// Kept for QA flows on the booking detail screen.
  Future<void> mockPayOrder(String orderId) async {
    await _dio.patch('orders/$orderId/mock-pay');
  }

  /// Creates a PENDING order and returns how to pay for it.
  ///
  /// When [paymentProvider] is null the backend keeps the default direct Payme
  /// (Paycom) flow and returns a `checkout_url`. When set, the order is routed
  /// through the Paylov (WLCM) aggregator:
  ///  • redirect providers (payme/click/uzum/paylov) → `checkout_url` to open;
  ///  • `card` → also send [cardNumber] + [expireDate] (MMYY); the result
  ///    carries `transaction_id`/`cid` and the client confirms the OTP via
  ///    [paylovConfirmCard].
  Future<CheckoutResult> checkout({
    required String activityId,
    required List<CheckoutItem> items,
    required String ticketDate,
    String? lang,
    String? returnUrl,
    String? promoCode,
    String? paymentProvider,
    String? cardNumber,
    String? expireDate,
    String? savedCardId,
    bool test = false,
  }) async {
    final body = {
      'activity_id': activityId,
      'items': items.map((e) => e.toJson()).toList(),
      'ticket_date': ticketDate,
      if (lang != null) 'lang': lang,
      if (returnUrl != null) 'return_url': returnUrl,
      if (promoCode != null && promoCode.trim().isNotEmpty)
        'promocode': promoCode.trim(),
      if (paymentProvider != null) 'payment_provider': paymentProvider,
      if (cardNumber != null && cardNumber.trim().isNotEmpty)
        'card_number': cardNumber.replaceAll(RegExp(r'\s'), ''),
      if (expireDate != null && expireDate.trim().isNotEmpty)
        'expire_date': expireDate.replaceAll(RegExp(r'[^0-9]'), ''),
      if (savedCardId != null && savedCardId.trim().isNotEmpty)
        'saved_card_id': savedCardId.trim(),
    };
    final response = await _dio.post('orders/checkout', data: body);
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return CheckoutResult.fromJson(data);
  }

  /// Confirms the OTP for a Paylov card payment
  /// (`POST /api/paylov/card/confirm`). On success the order is marked paid
  /// immediately; the Paylov webhook also arrives and is idempotent.
  Future<PaylovCardConfirmResult> paylovConfirmCard({
    required String transactionId,
    required String cid,
    required String otp,
  }) async {
    final response = await _dio.post('paylov/card/confirm', data: {
      'transaction_id': transactionId,
      'cid': cid,
      'otp': otp.trim(),
    });
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return PaylovCardConfirmResult.fromJson(data);
  }

  // ── Saved cards (WLCM Subscribe/Merchant API, via our backend) ──────────────

  /// Lists the user's saved (bound) cards (`GET /api/paylov/cards`).
  Future<List<SavedCard>> getSavedCards() async {
    final response = await _dio.get('paylov/cards');
    final raw = response.data;
    final list = raw is Map && raw['data'] is List
        ? raw['data'] as List
        : (raw is List ? raw : const []);
    return list
        .whereType<Map>()
        .map((e) => SavedCard.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Begins binding a card (`POST /api/paylov/cards`). Sends the PAN + expiry to
  /// WLCM, which SMSes an OTP; confirm it with [confirmSavedCard]. The card is
  /// only persisted after the OTP is confirmed — the PAN is never stored.
  Future<CardAddSession> addSavedCard({
    required String cardNumber,
    required String expireDate,
    String? phoneNumber,
  }) async {
    final response = await _dio.post('paylov/cards', data: {
      'card_number': cardNumber.replaceAll(RegExp(r'\s'), ''),
      'expire_date': expireDate.replaceAll(RegExp(r'[^0-9]'), ''),
      if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
        'phone_number': phoneNumber.trim(),
    });
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return CardAddSession.fromJson(data);
  }

  /// Confirms the OTP and saves the bound card
  /// (`POST /api/paylov/cards/confirm`).
  Future<SavedCard> confirmSavedCard({
    required String cid,
    required String otp,
    String? cardName,
  }) async {
    final response = await _dio.post('paylov/cards/confirm', data: {
      'cid': cid,
      'otp': otp.trim(),
      if (cardName != null && cardName.trim().isNotEmpty)
        'card_name': cardName.trim(),
    });
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return SavedCard.fromJson(data);
  }

  /// Deletes a saved card (`DELETE /api/paylov/cards/:cardId`), unbinding it on
  /// WLCM too.
  Future<void> deleteSavedCard(String cardId) async {
    await _dio.delete('paylov/cards/$cardId');
  }

  /// Charges a PENDING order with a bound card token
  /// (`POST /api/paylov/cards/pay`). Synchronous — no OTP, since the card is
  /// already tokenized. Returns the paid order status.
  Future<PaylovCardConfirmResult> payOrderWithSavedCard({
    required String orderId,
    required String cardId,
  }) async {
    final response = await _dio.post('paylov/cards/pay', data: {
      'order_id': orderId,
      'card_id': cardId,
    });
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return PaylovCardConfirmResult.fromJson(data);
  }

  /// Previews a promocode against an order subtotal without committing it.
  /// Backend re-runs every check (active window, scope, per-user limit, and
  /// the "no coupon plan" rule) and returns the discount + new total. Throws a
  /// [DioException] carrying the server's message when the code is invalid or
  /// not allowed for this user.
  Future<PromocodePreview> validatePromocode({
    required String code,
    required num subtotal,
    String? activityId,
    int? count,
  }) async {
    final response = await _dio.post('promocodes/validate', data: {
      'code': code.trim().toUpperCase(),
      'subtotal': subtotal,
      if (activityId != null) 'activity_id': activityId,
      // Number of tickets selected. Usage limits are counted by tickets, so the
      // server can reject immediately when the code can't cover this many.
      if (count != null) 'count': count,
    });
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return PromocodePreview.fromJson(data);
  }

  /// Cancel a PAID order. Backend enforces the 12-hour cutoff; this call
  /// throws a [DioException] with the server's message if it's too late.
  Future<void> cancelOrder(String orderId, {String reason = ''}) async {
    await _dio.patch(
      'orders/$orderId/cancel',
      data: {'reason': reason},
    );
  }

  /// Returns the current user's active subscription (including
  /// [discount_percentage]) so the app can sync premium status across devices
  /// on startup. Returns null when no subscription is active (server answered
  /// with `data: null`). Throws on network / auth errors — callers should
  /// catch and keep the existing local state.
  Future<Map<String, dynamic>?> getActiveSubscription() async {
    final response = await _dio.get('transaction/subscriptions/active');
    final raw = response.data;
    if (raw is Map && raw['data'] is Map) {
      return Map<String, dynamic>.from(raw['data'] as Map);
    }
    return null;
  }

  /// Returns all of the authenticated user's subscription purchases, newest
  /// first. Each entry includes [usedCount] — the number of discounted activity
  /// bookings made during that subscription's validity window.
  Future<List<SubscriptionRecord>> getSubscriptionHistory() async {
    final response = await _dio.get(
      'transaction/subscriptions',
      queryParameters: {'lang': currentLang},
    );
    final raw = response.data;
    final List list;
    if (raw is Map && raw['data'] is List) {
      list = raw['data'] as List;
    } else if (raw is List) {
      list = raw;
    } else {
      list = const [];
    }
    return list
        .whereType<Map>()
        .map((e) => SubscriptionRecord.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Kicks off a subscription purchase. Creates a PENDING order on the
  /// backend and returns a Paycom checkout URL. Subscription becomes active
  /// (expiring at now + tariff.duration_days) only after the user pays
  /// and Paycom calls PerformTransaction on our webhook.
  /// [paymentProvider] is a [PaymentRail.providerKey] — `payme` / `click` /
  /// `uzum` return a [CheckoutResult.checkoutUrl] to redirect to, while `card`
  /// returns the Paylov OTP fields instead (see [paylovConfirmCard]). Omitting
  /// it keeps the legacy Payme-only body.
  Future<CheckoutResult> checkoutSubscription({
    required String tariffId,
    String? lang,
    String? paymentProvider,
    String? cardNumber,
    String? expireDate,
    bool test = false,
  }) async {
    final body = {
      'tariff_id': tariffId,
      if (paymentProvider != null)
        'payment_provider': paymentProvider
      else
        'payment_method': 'PAYME',
      if (cardNumber != null && cardNumber.trim().isNotEmpty)
        'card_number': cardNumber.replaceAll(RegExp(r'\s'), ''),
      if (expireDate != null && expireDate.trim().isNotEmpty)
        'expire_date': expireDate.replaceAll(RegExp(r'[^0-9]'), ''),
      if (lang != null) 'lang': lang,
    };
    final response =
        await _dio.post('transaction/subscriptions', data: body);
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return CheckoutResult.fromJson(data);
  }
}

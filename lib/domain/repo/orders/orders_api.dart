import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';
import 'package:lumi_pass/data/api_model/order/order_model.dart';
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

  Future<CheckoutResult> checkout({
    required String activityId,
    required List<CheckoutItem> items,
    required String ticketDate,
    String? lang,
    String? returnUrl,
    String? promoCode,
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
    };
    final response = await _dio.post('orders/checkout', data: body);
    final raw = response.data;
    final data = raw is Map && raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : Map<String, dynamic>.from(raw as Map);
    return CheckoutResult.fromJson(data);
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
  }) async {
    final response = await _dio.post('promocodes/validate', data: {
      'code': code.trim().toUpperCase(),
      'subtotal': subtotal,
      if (activityId != null) 'activity_id': activityId,
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
  Future<CheckoutResult> checkoutSubscription({
    required String tariffId,
    String? lang,
    bool test = false,
  }) async {
    final body = {
      'tariff_id': tariffId,
      'payment_method': 'PAYME',
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

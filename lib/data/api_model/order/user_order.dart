import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/common/utils/image_url.dart';

/// Plain Dart models for the user-facing orders API.
///
/// An [UserOrder] = one transaction (one Paycom checkout) that may contain
/// multiple seats. An [OrderTicket] = one seat inside that order (what the
/// backend calls a Booking). Tickets only carry a `ticketNo` once the order
/// flips to PAID.

class UserOrder {
  final String id;
  final String status; // pending | paid | canceled
  final num totalAmount;
  final num paidAmount;
  final String? activityId;
  final String? activityName;
  final String? activityImage;
  final num? activityPrice;
  final List<OrderLineItem> items;
  /// Lightweight ticket summary returned by the orders list endpoint —
  /// enough to render times / ticket numbers on the card without a
  /// follow-up detail fetch.
  final List<OrderTicketSummary> ticketSummaries;
  final String? createdAt;
  final String? updatedAt;

  const UserOrder({
    required this.id,
    required this.status,
    required this.totalAmount,
    required this.paidAmount,
    required this.activityId,
    required this.activityName,
    required this.activityImage,
    required this.activityPrice,
    required this.items,
    required this.ticketSummaries,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalSeats => items.fold<int>(0, (sum, it) => sum + it.count);
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isCanceled => status.toLowerCase() == 'canceled';
  /// True when this order is for an activity booking (not a subscription
  /// purchase). Subscription orders have a null activityId and must not
  /// appear in the bookings list.
  bool get isActivityOrder => activityId != null && activityId!.isNotEmpty;

  /// Semantic display status: 'active' | 'visited' | 'missed' | 'cancelled' | 'pending'
  String get effectiveDisplayStatus {
    if (isCanceled) return 'cancelled';
    if (isPending) return 'pending';
    if (ticketSummaries.isEmpty) return 'active';
    final anyAttended =
        ticketSummaries.any((t) => t.attendanceStatus == 'attended');
    if (anyAttended) return 'visited';
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final allPast = ticketSummaries.every((t) {
      final d = t.ticketDate;
      if (d == null || d.isEmpty) return false;
      return d.compareTo(todayKey) < 0;
    });
    return allPast ? 'missed' : 'active';
  }

  /// True when any ticket date is today or in the future.
  bool get hasFutureTicket {
    if (ticketSummaries.isEmpty) return isPaid;
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return ticketSummaries.any((t) {
      final d = t.ticketDate;
      if (d == null || d.isEmpty) return false;
      return d.compareTo(todayKey) >= 0;
    });
  }

  factory UserOrder.fromJson(Map<String, dynamic> json) {
    final activity = json['activity_id'];
    Map<String, dynamic>? activityMap;
    String? activityId;
    if (activity is Map) {
      activityMap = Map<String, dynamic>.from(activity);
      activityId = activityMap['_id']?.toString() ?? activityMap['id']?.toString();
    } else if (activity != null) {
      activityId = activity.toString();
    }

    final itemsRaw = (json['items'] as List?) ?? const [];
    final ticketsRaw = (json['tickets'] as List?) ?? const [];
    return UserOrder(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      totalAmount: (json['total_amount'] as num?) ?? 0,
      paidAmount: (json['paid_amount'] as num?) ?? 0,
      activityId: activityId,
      activityName: _readLocalized(activityMap?['name']),
      activityImage: sanitizeImageUrl(activityMap?['image']?.toString()),
      activityPrice: activityMap?['price'] as num?,
      items: itemsRaw
          .whereType<Map>()
          .map((e) => OrderLineItem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      ticketSummaries: ticketsRaw
          .whereType<Map>()
          .map((e) =>
              OrderTicketSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

/// Slim per-ticket payload included on the orders list endpoint so the card
/// can render booked times / ticket numbers inline.
class OrderTicketSummary {
  final String? ticketNo;
  final String? ticketDate;
  final String? startTime;
  final String? endTime;
  final String status;
  final String? attendanceStatus; // 'attended' | 'not_attended' | null

  const OrderTicketSummary({
    required this.ticketNo,
    required this.ticketDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.attendanceStatus,
  });

  factory OrderTicketSummary.fromJson(Map<String, dynamic> json) {
    return OrderTicketSummary(
      ticketNo: json['ticket_no']?.toString(),
      ticketDate: json['ticket_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      attendanceStatus: json['attendance_status']?.toString(),
    );
  }
}

class OrderLineItem {
  final int ageFrom;
  final int ageTo;
  final num unitPrice;
  final int count;

  const OrderLineItem({
    required this.ageFrom,
    required this.ageTo,
    required this.unitPrice,
    required this.count,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      ageFrom: (json['age_from'] as num?)?.toInt() ?? 0,
      ageTo: (json['age_to'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?) ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderTicket {
  final String id;
  final String? ticketNo;
  final String ticketDate;
  final String? startTime;
  final String? endTime;
  final int ageFrom;
  final int ageTo;
  final num price;
  final String status; // pending | confirmed | canceled
  final String? createdAt;

  const OrderTicket({
    required this.id,
    required this.ticketNo,
    required this.ticketDate,
    required this.startTime,
    required this.endTime,
    required this.ageFrom,
    required this.ageTo,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  bool get isConfirmed => status.toLowerCase() == 'confirmed';

  factory OrderTicket.fromJson(Map<String, dynamic> json) {
    return OrderTicket(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      ticketNo: json['ticket_no']?.toString(),
      ticketDate: json['ticket_date']?.toString() ?? '',
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      ageFrom: (json['age_from'] as num?)?.toInt() ?? 0,
      ageTo: (json['age_to'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class OrderDetail {
  final UserOrder order;
  final List<OrderTicket> tickets;
  final String? checkoutUrl;

  const OrderDetail({
    required this.order,
    required this.tickets,
    required this.checkoutUrl,
  });

  String? get earliestTicketDate {
    if (tickets.isEmpty) return null;
    final dates = tickets
        .map((t) => t.ticketDate)
        .where((d) => d.isNotEmpty)
        .toList()
      ..sort();
    return dates.firstOrNull;
  }

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final orderRaw = json['order'] is Map
        ? Map<String, dynamic>.from(json['order'] as Map)
        : <String, dynamic>{};
    final bookingsRaw = (json['bookings'] as List?) ?? const [];
    return OrderDetail(
      order: UserOrder.fromJson(orderRaw),
      tickets: bookingsRaw
          .whereType<Map>()
          .map((e) => OrderTicket.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      checkoutUrl: json['checkout_url']?.toString(),
    );
  }
}

String? _readLocalized(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map) {
    final lang = currentLang;
    // Current lang first, then fallback chain
    for (final key in [lang, 'ru', 'en', 'uz']) {
      final v = value[key];
      if (v is String && v.isNotEmpty) return v;
    }
    final first = value.values
        .whereType<String>()
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    return first.isEmpty ? null : first;
  }
  return value.toString();
}

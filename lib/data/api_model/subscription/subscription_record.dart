/// A single entry in the user's coupon/subscription purchase history.
/// Returned by [GET /api/transaction/subscriptions].
class SubscriptionRecord {
  final String id;
  final String? planName;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // active | expired | canceled
  final int discountPercentage;
  final int activitiesLimit; // total activities the plan allows
  final int usedCount;       // how many have been used within the period
  final num amount;          // amount paid in UZS

  const SubscriptionRecord({
    required this.id,
    this.planName,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.discountPercentage,
    required this.activitiesLimit,
    required this.usedCount,
    required this.amount,
  });

  bool get isActive   => status == 'active';
  bool get isExpired  => status == 'expired';
  bool get isCanceled => status == 'canceled' || status == 'cancelled';

  /// Remaining activities clamped so it never goes below zero.
  int get remaining =>
      (activitiesLimit - usedCount).clamp(0, activitiesLimit);

  factory SubscriptionRecord.fromJson(Map<String, dynamic> json) {
    return SubscriptionRecord(
      id: json['id']?.toString() ?? '',
      planName: (json['plan_name'] as String?)?.isEmpty == true
          ? null
          : json['plan_name'] as String?,
      startDate: DateTime.parse(json['start_date'] as String).toLocal(),
      endDate: DateTime.parse(json['end_date'] as String).toLocal(),
      status: json['status']?.toString() ?? 'expired',
      discountPercentage:
          (json['discount_percentage'] as num?)?.toInt() ?? 0,
      activitiesLimit:
          (json['activities_limit'] as num?)?.toInt() ?? 0,
      usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?) ?? 0,
    );
  }
}

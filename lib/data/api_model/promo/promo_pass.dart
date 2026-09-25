import 'package:lumi_pass/data/api_model/promo/promo_coverage.dart';
import 'package:lumi_pass/data/api_model/promo/promo_pass_status.dart';

/// One visit already paid for out of a pass.
class PromoRedemption {
  final String? activityId;
  final String? activityName;
  final String? orderId;

  /// `YYYY-MM-DD` of the booked visit.
  final String? ticketDate;
  final String? ticketNo;
  final num amountCovered;
  final DateTime? redeemedAt;

  /// Whether the child actually turned up. Resolved server-side from the
  /// booking, so it is the same fact the centre's attendance list shows.
  final bool attended;
  final DateTime? attendedAt;

  const PromoRedemption({
    this.activityId,
    this.activityName,
    this.orderId,
    this.ticketDate,
    this.ticketNo,
    this.amountCovered = 0,
    this.redeemedAt,
    this.attended = false,
    this.attendedAt,
  });

  factory PromoRedemption.fromJson(Map<String, dynamic> json) {
    DateTime? date(Object? v) => DateTime.tryParse('${v ?? ''}');
    String? text(Object? v) {
      final s = v?.toString();
      return (s != null && s.isNotEmpty) ? s : null;
    }

    return PromoRedemption(
      activityId: text(json['activity_id']),
      activityName: text(json['activity_name']),
      orderId: text(json['order_id']),
      ticketDate: text(json['ticket_date']),
      ticketNo: text(json['ticket_no']),
      amountCovered: (json['amount_covered'] as num?) ?? 0,
      redeemedAt: date(json['redeemed_at']),
      attended: json['attended'] == true,
      attendedAt: date(json['attended_at']),
    );
  }
}

/// A bought "аксия" bundle and what is left of it.
///
/// Every rule on it was frozen at purchase, server-side — so a pass bought last
/// week keeps last week's terms even if the offer has since changed. The app
/// reads them, it never re-derives them.
class PromoPass {
  final String id;
  final String code;
  final String? campaignId;
  final String? campaignSlug;
  final String title;
  final num price;
  final String currency;
  final PromoPassStatus status;

  /// The server's own verdict on whether a visit can still be spent. **Render
  /// this rather than inferring it from [status] and [activitiesLeft]** — it is
  /// the one answer that accounts for a deadline that passed a minute ago.
  final bool isUsable;

  final int activitiesTotal;
  final int activitiesUsed;
  final int activitiesLeft;
  final int validDays;
  final PromoCoverage coverage;
  final num discountPercentage;

  /// Whether the visits must be at different activities — true for the flagship.
  final bool distinctActivities;

  // ── Scope, for hiding prices in the catalogue ───────────────────────────────
  // Carried on the pass so the app can decide PER CARD whether an activity is
  // included, without an eligibility call for every row of a scrolling list.
  // Applied by [PromoPassCoverage]; checkout remains the authority.
  /// Named activities the packet may be spent on. Empty (with
  /// [scopeCategoryIds] empty too) means the whole catalogue.
  final List<String> scopeActivityIds;

  final List<String> scopeCategoryIds;

  /// Per-visit ceiling, when the campaign sets one.
  final num? maxActivityPrice;

  /// Whether a whole-course enrolment may be paid with a visit. False for the
  /// flagship — a visit buys a course's TRIAL lesson, never its term.
  final bool allowCourses;

  final DateTime? purchasedAt;
  final DateTime? expiresAt;

  /// Whole days left, as the server counted them. `1` means today is the last
  /// day; `0` means it has run out.
  final int daysLeft;

  final String? orderId;
  final List<PromoRedemption> redemptions;

  const PromoPass({
    required this.id,
    required this.code,
    this.campaignId,
    this.campaignSlug,
    this.title = '',
    this.price = 0,
    this.currency = 'UZS',
    this.status = PromoPassStatus.unknown,
    this.isUsable = false,
    this.activitiesTotal = 0,
    this.activitiesUsed = 0,
    this.activitiesLeft = 0,
    this.validDays = 0,
    this.coverage = PromoCoverage.full,
    this.discountPercentage = 0,
    this.distinctActivities = true,
    this.scopeActivityIds = const [],
    this.scopeCategoryIds = const [],
    this.maxActivityPrice,
    this.allowCourses = false,
    this.purchasedAt,
    this.expiresAt,
    this.daysLeft = 0,
    this.orderId,
    this.redemptions = const [],
  });

  /// How far through the bundle the buyer is, 0..1 — the ring on the pass card.
  double get progress =>
      activitiesTotal <= 0 ? 0 : (activitiesUsed / activitiesTotal).clamp(0, 1);

  /// Worth hurrying: the last two days, with visits still on it.
  bool get isRunningOut => isUsable && daysLeft <= 2;

  factory PromoPass.fromJson(Map<String, dynamic> json) {
    DateTime? date(Object? v) => DateTime.tryParse('${v ?? ''}');
    String? text(Object? v) {
      final s = v?.toString();
      return (s != null && s.isNotEmpty) ? s : null;
    }

    int count(Object? v) =>
        v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

    final total = count(json['activities_total']);
    final used = count(json['activities_used']);

    return PromoPass(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      campaignId: text(json['campaign_id']),
      campaignSlug: text(json['campaign_slug']),
      title: json['title']?.toString() ?? '',
      price: (json['price'] as num?) ?? 0,
      currency: json['currency']?.toString() ?? 'UZS',
      status: PromoPassStatus.fromKey(json['status']?.toString()),
      isUsable: json['is_usable'] == true,
      activitiesTotal: total,
      activitiesUsed: used,
      // Trusted from the server when sent, derived only as a fallback for an
      // older backend — the two can only disagree if one of them is wrong.
      activitiesLeft: json['activities_left'] != null
          ? count(json['activities_left'])
          : (total - used).clamp(0, total),
      validDays: count(json['valid_days']),
      coverage: PromoCoverage.fromKey(json['coverage']?.toString()),
      discountPercentage: (json['discount_percentage'] as num?) ?? 0,
      distinctActivities: json['distinct_activities'] != false,
      scopeActivityIds: ((json['activity_ids'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      scopeCategoryIds: ((json['category_ids'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
      maxActivityPrice: json['max_activity_price'] as num?,
      allowCourses: json['allow_courses'] == true,
      purchasedAt: date(json['purchased_at']),
      expiresAt: date(json['expires_at']),
      daysLeft: count(json['days_left']),
      orderId: text(json['order_id']),
      redemptions: ((json['redemptions'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => PromoRedemption.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

import 'package:lumi_pass/data/api_model/promo/promo_coverage.dart';
import 'package:lumi_pass/data/api_model/promo/promo_pass_status.dart';

/// The compact form of a pass carried inside a campaign — enough for the offer
/// screen to say "you already have this, two visits left, three days".
class PromoPassSummary {
  final String id;
  final String code;
  final int activitiesTotal;
  final int activitiesUsed;
  final int activitiesLeft;
  final DateTime? expiresAt;
  final int daysLeft;
  final PromoPassStatus status;

  const PromoPassSummary({
    required this.id,
    required this.code,
    this.activitiesTotal = 0,
    this.activitiesUsed = 0,
    this.activitiesLeft = 0,
    this.expiresAt,
    this.daysLeft = 0,
    this.status = PromoPassStatus.unknown,
  });

  factory PromoPassSummary.fromJson(Map<String, dynamic> json) {
    int count(Object? v) =>
        v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;
    return PromoPassSummary(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      activitiesTotal: count(json['activities_total']),
      activitiesUsed: count(json['activities_used']),
      activitiesLeft: count(json['activities_left']),
      expiresAt: DateTime.tryParse('${json['expires_at'] ?? ''}'),
      daysLeft: count(json['days_left']),
      status: PromoPassStatus.fromKey(json['status']?.toString()),
    );
  }
}

/// The "аксия" OFFER: one price, N activity visits, D days to use them.
///
/// Every number here is server-driven — the flagship happens to be 3 visits for
/// 99 000 so'm in 5 days, but the screen renders whatever the campaign says.
/// Nothing in the app hardcodes those figures, so marketing can run a second
/// bundle without an app release.
class PromoCampaign {
  final String id;
  final String slug;
  final String title;
  final String? subtitle;
  final String? description;

  /// Small ribbon over the hero — "АКЦИЯ", "ХИТ".
  final String? badge;

  /// Bullet list on the offer screen.
  final List<String> highlights;

  final num price;

  /// Struck-through comparison price. Null when there is nothing to compare to.
  final num? oldPrice;
  final String currency;

  final int activitiesCount;
  final int validDays;
  final PromoCoverage coverage;
  final num discountPercentage;

  /// Whether the visits must be at DIFFERENT activities.
  final bool distinctActivities;

  /// Per-visit ceiling, when the campaign sets one.
  final num? maxActivityPrice;

  /// Whether the bundle is limited to a curated list of activities/categories.
  final bool isScoped;

  final String? imageUrl;

  /// `#RRGGBB` accent, or null to use the brand purple.
  final String? accentColor;

  /// When the OFFER stops being sold — unrelated to a pass's own days.
  final DateTime? endsAt;

  /// What one visit works out at. Computed server-side so every client rounds
  /// it the same way.
  final num pricePerActivity;

  /// Live passes the signed-in buyer already holds from this campaign. Non-empty
  /// means the screen shows the pass rather than the Buy bar.
  final List<PromoPassSummary> activePasses;

  /// Whether buying is offered at all right now. False when the buyer already
  /// holds a pass and the campaign forbids a second one.
  final bool canPurchase;

  const PromoCampaign({
    required this.id,
    required this.slug,
    required this.title,
    this.subtitle,
    this.description,
    this.badge,
    this.highlights = const [],
    this.price = 0,
    this.oldPrice,
    this.currency = 'UZS',
    this.activitiesCount = 0,
    this.validDays = 0,
    this.coverage = PromoCoverage.full,
    this.discountPercentage = 0,
    this.distinctActivities = true,
    this.maxActivityPrice,
    this.isScoped = false,
    this.imageUrl,
    this.accentColor,
    this.endsAt,
    this.pricePerActivity = 0,
    this.activePasses = const [],
    this.canPurchase = true,
  });

  /// The pass to show instead of the Buy bar, if there is one.
  PromoPassSummary? get heldPass =>
      activePasses.isEmpty ? null : activePasses.first;

  /// How much the bundle saves against buying the visits one by one. Null when
  /// no comparison price is configured, or it isn't actually cheaper.
  num? get saving {
    final old = oldPrice;
    if (old == null || old <= price) return null;
    return old - price;
  }

  factory PromoCampaign.fromJson(Map<String, dynamic> json) {
    String? text(Object? v) {
      final s = v?.toString();
      return (s != null && s.isNotEmpty) ? s : null;
    }

    int count(Object? v) =>
        v is num ? v.toInt() : int.tryParse('${v ?? ''}') ?? 0;

    return PromoCampaign(
      id: json['id']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: text(json['subtitle']),
      description: text(json['description']),
      badge: text(json['badge']),
      highlights: ((json['highlights'] as List?) ?? const [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList(),
      price: (json['price'] as num?) ?? 0,
      oldPrice: json['old_price'] as num?,
      currency: json['currency']?.toString() ?? 'UZS',
      activitiesCount: count(json['activities_count']),
      validDays: count(json['valid_days']),
      coverage: PromoCoverage.fromKey(json['coverage']?.toString()),
      discountPercentage: (json['discount_percentage'] as num?) ?? 0,
      distinctActivities: json['distinct_activities'] != false,
      maxActivityPrice: json['max_activity_price'] as num?,
      isScoped: json['is_scoped'] == true,
      imageUrl: text(json['image_url']),
      accentColor: text(json['accent_color']),
      endsAt: DateTime.tryParse('${json['ends_at'] ?? ''}'),
      pricePerActivity: (json['price_per_activity'] as num?) ??
          (count(json['activities_count']) > 0
              ? ((json['price'] as num?) ?? 0) / count(json['activities_count'])
              : ((json['price'] as num?) ?? 0)),
      activePasses: ((json['active_passes'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => PromoPassSummary.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      // Absent on an older backend, where buying was always offered.
      canPurchase: json['can_purchase'] != false,
    );
  }
}

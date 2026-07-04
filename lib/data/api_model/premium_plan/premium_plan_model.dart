import 'package:lumi_pass/common/utils/app_locale.dart';

class PremiumPlan {
  final String? id;
  final Map<String, String>? name;
  final num? price;
  final int? durationDays;
  final int? activitiesLimit;
  final double? discountPercentage;
  final bool? isActive;

  const PremiumPlan({
    this.id,
    this.name,
    this.price,
    this.durationDays,
    this.activitiesLimit,
    this.discountPercentage,
    this.isActive,
  });

  factory PremiumPlan.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'];
    Map<String, String>? nameMap;
    if (rawName is Map) {
      nameMap = {
        for (final e in rawName.entries)
          if (e.key is String && e.value is String) e.key as String: e.value as String,
      };
    }
    return PremiumPlan(
      id: json['_id'] as String?,
      name: nameMap,
      price: json['price'] as num?,
      durationDays: json['duration_days'] as int?,
      activitiesLimit: json['activities_limit'] as int?,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool?,
    );
  }

  /// Returns the localized name using the current app locale.
  String get localizedTitle {
    if (name == null) return '';
    return name![currentLang] ?? name!['uz'] ?? name!.values.firstOrNull ?? '';
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:lumi_pass/common/utils/image_url.dart';

/// Plain (non-freezed) model for the full /api/classes/:id response.
/// Supports both the legacy flat prices_summary format and the new
/// age_tiers → durations nested format.
class ClassFullModel {
  final String? id;
  final String? imageUrl;
  final List<String> images;
  final Map<String, dynamic> name;
  final Map<String, dynamic> description;
  final Map<String, dynamic> importantNotes;
  final Map<String, dynamic> requiredItems;
  final int ageFrom;
  final int ageTo;
  final String? gender;
  final num price;
  final bool hasAgePricing;
  final num priceMin;
  final num priceMax;
  final bool hasMultiplePrices;
  final List<PriceRangeItem> pricesSummary;
  final List<AgeTier> ageTiers;
  final num discountPercentage;
  final List<ScheduleSlot> schedule;
  final List<ScheduleSlot> workHours;
  final String? videoUrl;
  final String? videoProvider;
  final String? vimeoLink;
  final String? youtubeLink;
  final List<String> activityLanguages;
  final BranchSummary? branch;
  final CategorySummary? category;
  final bool isParentControlRequired;

  ClassFullModel({
    required this.id,
    required this.imageUrl,
    required this.images,
    required this.name,
    required this.description,
    required this.importantNotes,
    required this.requiredItems,
    required this.ageFrom,
    required this.ageTo,
    required this.gender,
    required this.price,
    required this.hasAgePricing,
    required this.priceMin,
    required this.priceMax,
    required this.hasMultiplePrices,
    required this.pricesSummary,
    required this.ageTiers,
    required this.discountPercentage,
    required this.schedule,
    required this.workHours,
    required this.videoUrl,
    required this.videoProvider,
    required this.vimeoLink,
    required this.youtubeLink,
    required this.activityLanguages,
    required this.branch,
    required this.category,
    required this.isParentControlRequired,
  });

  /// Returns the first non-empty video link (vimeo → youtube → videoUrl).
  String? get effectiveVideoUrl {
    if (vimeoLink != null && vimeoLink!.isNotEmpty) return vimeoLink;
    if (youtubeLink != null && youtubeLink!.isNotEmpty) return youtubeLink;
    if (videoUrl != null && videoUrl!.isNotEmpty) return videoUrl;
    return null;
  }

  /// True when ageTiers contains the pricing data (new backend format).
  bool get hasAgeTierPricing => ageTiers.isNotEmpty;

  static Map<String, dynamic> _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  factory ClassFullModel.fromJson(Map<String, dynamic> json) {
    final summaryRaw = (json['prices_summary'] as List?) ?? const [];
    final ageTiersRaw = (json['age_tiers'] as List?) ?? const [];
    final scheduleRaw = (json['schedule'] as List?) ?? const [];
    final workHoursRaw = (json['work_hours'] as List?) ?? const [];
    final imagesRaw = (json['images'] as List?) ?? const [];
    final langsRaw = (json['activity_languages'] as List?) ?? const [];

    final ageTiers = ageTiersRaw
        .whereType<Map>()
        .map((e) => AgeTier.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final flatSummary = summaryRaw
        .whereType<Map>()
        .map((e) => PriceRangeItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    // Derive flat summary from ageTiers (min price per tier) when absent.
    final effectiveSummary = flatSummary.isNotEmpty
        ? flatSummary
        : ageTiers.map((t) {
            final minPrice = t.durations.isEmpty
                ? 0
                : t.durations
                    .map((d) => d.price)
                    .reduce((a, b) => a < b ? a : b);
            return PriceRangeItem(
              ageFrom: t.ageFrom,
              ageTo: t.ageTo ?? 99,
              price: minPrice,
            );
          }).toList();

    // Derive price range across all tiers/durations.
    num priceMin = (json['price_min'] as num?) ?? (json['price'] as num?) ?? 0;
    num priceMax = (json['price_max'] as num?) ?? (json['price'] as num?) ?? 0;
    if (ageTiers.isNotEmpty) {
      final allPrices = ageTiers
          .expand((t) => t.durations.map((d) => d.price))
          .toList();
      if (allPrices.isNotEmpty) {
        priceMin = allPrices.reduce((a, b) => a < b ? a : b);
        priceMax = allPrices.reduce((a, b) => a > b ? a : b);
      }
    }

    return ClassFullModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      imageUrl: sanitizeImageUrl(json['image']?.toString()),
      images: imagesRaw
          .map((e) => sanitizeImageUrl(e.toString()))
          .whereType<String>()
          .toList(),
      name: _asMap(json['name']),
      description: _asMap(json['description']),
      importantNotes: _asMap(json['important_notes']),
      requiredItems: _asMap(json['required_items']),
      ageFrom: (json['age_from'] as num?)?.toInt() ?? 0,
      ageTo: (json['age_to'] as num?)?.toInt() ?? 0,
      gender: json['gender']?.toString(),
      price: (json['price'] as num?) ?? 0,
      hasAgePricing: json['has_age_pricing'] == true || ageTiers.isNotEmpty,
      priceMin: priceMin,
      priceMax: priceMax,
      hasMultiplePrices:
          json['has_multiple_prices'] == true || ageTiers.isNotEmpty,
      pricesSummary: effectiveSummary,
      ageTiers: ageTiers,
      discountPercentage: (json['discount_percentage'] as num?) ?? 0,
      schedule: scheduleRaw
          .whereType<Map>()
          .map((e) => ScheduleSlot.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      workHours: workHoursRaw
          .whereType<Map>()
          .map((e) => ScheduleSlot.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      videoUrl: json['video_url']?.toString(),
      videoProvider: json['video_provider']?.toString(),
      vimeoLink: json['vimeo_link']?.toString(),
      youtubeLink: json['youtube_link']?.toString(),
      activityLanguages: langsRaw.map((e) => e.toString()).toList(),
      branch: json['branch_id'] is Map
          ? BranchSummary.fromJson(
              Map<String, dynamic>.from(json['branch_id'] as Map))
          : null,
      category: json['category_id'] is Map
          ? CategorySummary.fromJson(
              Map<String, dynamic>.from(json['category_id'] as Map))
          : null,
      isParentControlRequired:
          json['is_parent_control_required'] == true,
    );
  }
}

// ─── AgeTier ─────────────────────────────────────────────────────────────────

class AgeTier {
  final int ageFrom;
  final int? ageTo; // null = adult / no upper limit
  final List<AgeDuration> durations;

  AgeTier({
    required this.ageFrom,
    required this.ageTo,
    required this.durations,
  });

  /// Human-readable age label.
  String get rangeLabel {
    if (ageTo == null) return '$ageFrom+ ${'filter_years_label'.tr()}';
    if (ageFrom == ageTo) return '$ageFrom ${'filter_years_label'.tr()}';
    return '$ageFrom–$ageTo ${'filter_years_label'.tr()}';
  }

  factory AgeTier.fromJson(Map<String, dynamic> json) {
    final durationsRaw = (json['durations'] as List?) ?? const [];
    return AgeTier(
      ageFrom: (json['age_from'] as num?)?.toInt() ?? 0,
      ageTo: (json['age_to'] as num?)?.toInt(),
      durations: durationsRaw
          .whereType<Map>()
          .map((e) => AgeDuration.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

// ─── AgeDuration ─────────────────────────────────────────────────────────────

class AgeDuration {
  final int? duration; // minutes; null = unlimited / full-time
  final num price;

  AgeDuration({required this.duration, required this.price});

  /// Human-readable duration label.
  String get durationLabel {
    if (duration == null) return 'duration_unbounded'.tr();
    final h = duration! ~/ 60;
    final m = duration! % 60;
    if (h > 0 && m > 0) return '$h${'duration_h_unit'.tr()} $m${'duration_min_unit'.tr()}';
    if (h > 0) return '$h ${'duration_h_unit'.tr()}';
    return '$m ${'duration_min_unit'.tr()}';
  }

  factory AgeDuration.fromJson(Map<String, dynamic> json) {
    return AgeDuration(
      duration: (json['duration'] as num?)?.toInt(),
      price: (json['price'] as num?) ?? 0,
    );
  }
}

// ─── PriceRangeItem (legacy flat format) ─────────────────────────────────────

class PriceRangeItem {
  final int ageFrom;
  final int ageTo;
  final num price;

  PriceRangeItem({
    required this.ageFrom,
    required this.ageTo,
    required this.price,
  });

  factory PriceRangeItem.fromJson(Map<String, dynamic> json) {
    return PriceRangeItem(
      ageFrom: (json['age_from'] as num?)?.toInt() ?? 0,
      ageTo: (json['age_to'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?) ?? 0,
    );
  }

  String get rangeLabel => ageFrom == ageTo
      ? '$ageFrom ${'filter_years_label'.tr()}'
      : '$ageFrom–$ageTo ${'filter_years_label'.tr()}';
}

// ─── ScheduleSlot ────────────────────────────────────────────────────────────

class ScheduleSlot {
  final String day;
  final String startTime;
  final String endTime;

  ScheduleSlot({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      day: json['day']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

// ─── Per-date schedule (used by the booking calendar) ──────────────────────

class ScheduleSlotInfo {
  final String startTime;
  final String endTime;
  final int? capacity;
  final int? availableSlots;

  ScheduleSlotInfo({
    required this.startTime,
    required this.endTime,
    this.capacity,
    this.availableSlots,
  });

  bool get isFull => availableSlots != null && availableSlots! <= 0;

  factory ScheduleSlotInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleSlotInfo(
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt(),
      availableSlots: (json['available_slots'] as num?)?.toInt(),
    );
  }
}

class ScheduleDay {
  final String date; // YYYY-MM-DD
  final List<ScheduleSlotInfo> slots;

  ScheduleDay({required this.date, required this.slots});

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    final raw = (json['slots'] as List?) ?? const [];
    return ScheduleDay(
      date: json['date']?.toString() ?? '',
      slots: raw
          .whereType<Map>()
          .map((e) =>
              ScheduleSlotInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

// ─── BranchSummary ───────────────────────────────────────────────────────────

class BranchSummary {
  final String? id;
  final String? title;
  final String? landmark;
  final Map<String, dynamic> address;
  final double? lat;
  final double? lng;

  BranchSummary({
    required this.id,
    required this.title,
    required this.landmark,
    required this.address,
    required this.lat,
    required this.lng,
  });

  factory BranchSummary.fromJson(Map<String, dynamic> json) {
    final loc = json['location'];
    return BranchSummary(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      title: json['title']?.toString(),
      landmark: json['landmark']?.toString(),
      address: json['address'] is Map
          ? Map<String, dynamic>.from(json['address'] as Map)
          : <String, dynamic>{},
      lat: loc is Map && loc['lat'] is num
          ? (loc['lat'] as num).toDouble()
          : null,
      lng: loc is Map && loc['lng'] is num
          ? (loc['lng'] as num).toDouble()
          : null,
    );
  }
}

// ─── CategorySummary ─────────────────────────────────────────────────────────

class CategorySummary {
  final String? id;
  final Map<String, dynamic> name;
  final String? type;

  CategorySummary({
    required this.id,
    required this.name,
    required this.type,
  });

  /// True for the 'required_booking' category type — the user must pick a
  /// concrete from/to time slot for each ticket rather than the class's
  /// pre-defined recurring schedule.
  bool get requiresBookingTimeSlot => type == 'required_booking';

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    return CategorySummary(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name'] is Map
          ? Map<String, dynamic>.from(json['name'] as Map)
          : <String, dynamic>{},
      type: json['type']?.toString(),
    );
  }
}

// ─── ClassPricingSnapshot / ClassPricingCache (unchanged) ────────────────────

class ClassPricingSnapshot {
  final num priceMin;
  final num priceMax;
  /// Lowest price across paid (non-zero) age tiers. Zero means all tiers are free.
  final num priceMinPaid;
  final bool hasMultiplePrices;
  final int rangeCount;
  final int? scheduleCount;

  const ClassPricingSnapshot({
    required this.priceMin,
    required this.priceMax,
    required this.priceMinPaid,
    required this.hasMultiplePrices,
    required this.rangeCount,
    this.scheduleCount,
  });

  factory ClassPricingSnapshot.fromJson(Map<String, dynamic> json) {
    final summary = (json['prices_summary'] as List?) ?? const [];
    final validRanges = summary.where((e) => e is Map && (e as Map).isNotEmpty).length;

    // Find lowest non-zero price across age tiers.
    num paidMin = 0;
    for (final e in summary) {
      if (e is Map) {
        final p = e['price'] as num? ?? 0;
        if (p > 0 && (paidMin == 0 || p < paidMin)) paidMin = p;
      }
    }

    return ClassPricingSnapshot(
      priceMin: (json['price_min'] as num?) ?? (json['price'] as num?) ?? 0,
      priceMax: (json['price_max'] as num?) ?? (json['price'] as num?) ?? 0,
      priceMinPaid: paidMin,
      hasMultiplePrices: json['has_multiple_prices'] == true,
      rangeCount: validRanges,
      scheduleCount: (json['schedule_count'] as num?)?.toInt(),
    );
  }
}

class ClassPricingCache {
  ClassPricingCache._();

  static final Map<String, ClassPricingSnapshot> _data = {};

  static void put(String id, ClassPricingSnapshot snap) {
    _data[id] = snap;
  }

  static ClassPricingSnapshot? get(String? id) {
    if (id == null) return null;
    return _data[id];
  }

  static void mergeFromList(List rawItems) {
    for (final item in rawItems) {
      if (item is Map) {
        final m = Map<String, dynamic>.from(item);
        final id = m['_id']?.toString() ?? m['id']?.toString();
        if (id != null) put(id, ClassPricingSnapshot.fromJson(m));
      }
    }
  }
}

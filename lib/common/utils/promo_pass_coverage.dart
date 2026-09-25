/// Whether a held "Lumi Start" packet covers a given activity right now — the
/// one rule behind every hidden price in the app.
///
/// While a packet has visits left, the catalogue stops quoting prices for the
/// activities it covers and shows them as included instead. That is a decision
/// PER CARD on a scrolling list, so it cannot be a round trip each; the pass
/// therefore carries its own scope (`GET /api/promo-passes`) and this file
/// applies it.
///
/// **This is for DISPLAY only.** `OrdersService.checkout` re-tests every rule
/// here — plus the deadline, which a card has no date to test — inside the
/// atomic update that spends the visit, and its answer is the one that decides
/// what anybody is charged. So this may be momentarily generous with a label
/// (the packet ran out in another tab, the price moved) and never wrong about
/// money: a booking whose pass no longer qualifies is refused with a message,
/// not silently charged.
///
/// Mirrors `PromoService.assess` on the backend, minus the date. Keep the two in
/// step — if a rule is added there, it is added here.
library;

import 'package:lumi_pass/data/api_model/promo/promo_pass.dart';

/// The subset of a pass the display rule needs, kept in `AppCubit` so every
/// price on screen can watch it without a fetch of its own.
///
/// Built from the full [PromoPass] rather than parsed separately, so there is
/// one definition of what a pass is.
class PromoPassCoverage {
  const PromoPassCoverage({
    required this.id,
    required this.title,
    required this.activitiesLeft,
    required this.activitiesTotal,
    required this.daysLeft,
    this.expiresAt,
    this.usedActivityIds = const {},
    this.activityIds = const {},
    this.categoryIds = const {},
    this.maxActivityPrice,
    this.distinctActivities = true,
    this.allowCourses = false,
    this.isFullCoverage = true,
  });

  final String id;

  /// "Lumi Start" — what the badge that replaces the price says.
  final String title;

  final int activitiesLeft;
  final int activitiesTotal;
  final int daysLeft;
  final DateTime? expiresAt;

  /// Activities already visited on this packet. With [distinctActivities] their
  /// prices come BACK — the packet has been spent there.
  final Set<String> usedActivityIds;

  /// Campaign scope. Both empty means the whole catalogue.
  final Set<String> activityIds;
  final Set<String> categoryIds;

  /// Per-visit ceiling, when the campaign sets one.
  final num? maxActivityPrice;

  final bool distinctActivities;
  final bool allowCourses;

  /// Whether a covered visit costs the buyer nothing. A percent packet only
  /// takes a slice off, so its prices must keep showing — there is still
  /// something to pay.
  final bool isFullCoverage;

  /// Nothing left to spend.
  bool get isSpent => activitiesLeft <= 0;

  static PromoPassCoverage? fromPass(PromoPass? pass) {
    if (pass == null || !pass.isUsable) return null;
    return PromoPassCoverage(
      id: pass.id,
      title: pass.title,
      activitiesLeft: pass.activitiesLeft,
      activitiesTotal: pass.activitiesTotal,
      daysLeft: pass.daysLeft,
      expiresAt: pass.expiresAt,
      usedActivityIds: pass.redemptions
          .map((r) => r.activityId)
          .whereType<String>()
          .toSet(),
      activityIds: pass.scopeActivityIds.toSet(),
      categoryIds: pass.scopeCategoryIds.toSet(),
      maxActivityPrice: pass.maxActivityPrice,
      distinctActivities: pass.distinctActivities,
      allowCourses: pass.allowCourses,
      isFullCoverage: pass.coverage.isFull,
    );
  }

  /// Whether this packet pays for [activityId] in full, so its price should be
  /// replaced by the included badge rather than shown.
  ///
  /// [price] is the figure that WOULD be charged — the per-visit ceiling is
  /// tested against it, so an activity dearer than the packet covers keeps its
  /// price. Pass 0 when the price is unknown; the ceiling then cannot refuse,
  /// which errs toward the label and is corrected at checkout.
  ///
  /// [isWholeCourse] must be true whenever the figure being priced is a course
  /// ENROLMENT rather than a trial lesson — a visit buys the trial, never the
  /// term. Every caller passes it rather than assuming, exactly as
  /// [effectiveCouponPercent] requires.
  bool covers({
    required String? activityId,
    required num price,
    required bool isWholeCourse,
    Iterable<String> categoryIds = const [],
  }) {
    // A percent packet leaves something to pay, so the price stays on screen.
    if (!isFullCoverage || isSpent) return false;
    if (isWholeCourse && !allowCourses) return false;

    // Already been here. With three DIFFERENT activities promised, the second
    // visit to one of them is the buyer's — so its price comes back rather than
    // reading as free and refusing at checkout.
    if (activityId == null) return false;
    if (distinctActivities && usedActivityIds.contains(activityId)) return false;

    if (!_inScope(activityId, categoryIds)) return false;

    final ceiling = maxActivityPrice;
    if (ceiling != null && price > ceiling) return false;

    return true;
  }

  /// Both scope lists empty means the whole catalogue; otherwise they are
  /// additive — a named activity OR one of the listed categories.
  bool _inScope(String activityId, Iterable<String> activityCategoryIds) {
    if (activityIds.isEmpty && categoryIds.isEmpty) return true;
    if (activityIds.contains(activityId)) return true;
    return activityCategoryIds.any(categoryIds.contains);
  }
}

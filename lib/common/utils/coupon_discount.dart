/// A coupon plan's discount is funded out of Lumi's share of the booking, so a
/// class can never be discounted deeper than that share: a 30% coupon on a
/// class whose share is 20% takes 20% off, and a class at or below the minimum
/// share carries no coupon discount at all.
///
/// The backend enforces this at checkout; these helpers exist so every price
/// the app previews — cards, the detail page, the booking sheet — matches what
/// will actually be charged.
///
/// A class's share arrives on the models as `discount_percentage`
/// (`HomClass.discountPercentage`, `ClassFullModel.discountPercentage`).
library;

/// Classes at or below this share are effectively zero-margin — no coupon
/// discount applies to them. Mirrors `MIN_DISCOUNTABLE_SHARE_PERCENT` on the
/// backend; keep the two in step.
const num kMinDiscountableSharePercent = 5;

/// The coupon percentage that actually applies to a class — the plan's
/// percentage, capped at the class's partner share. Returns 0 when the class
/// can't carry a coupon discount.
num effectiveCouponPercent(num planPercent, num? classSharePercent) {
  final share = classSharePercent ?? 0;
  if (planPercent <= 0 || share <= kMinDiscountableSharePercent) return 0;
  return share < planPercent ? share : planPercent;
}

/// Percentages for display: drops the decimal when there isn't one, so a 20%
/// share reads "20%" rather than "20.0%".
String formatCouponPercent(num percent) =>
    percent == percent.roundToDouble() ? '${percent.round()}' : '$percent';

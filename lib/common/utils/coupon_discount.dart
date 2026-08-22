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

/// Paylov's cut of every charge, carved out of the share before a coupon (or a
/// promocode) discounts it — bookings routinely pay through Paylov now, not
/// just direct Payme. Mirrors `PAYLOV_FEE_PERCENT` on the backend; keep the
/// two in step.
const num kPaylovFeePercent = 2.5;

/// The coupon percentage that actually applies to a purchase — the plan's
/// percentage, capped at the class's partner share minus the aggregator's fee
/// (same ceiling a promocode gets). Returns 0 when the purchase can't carry a
/// coupon discount.
///
/// WHAT A COUPON DISCOUNTS: a one-time activity booking, and a course TRIAL
/// lesson — both are one session bought one at a time, which is the shape the
/// plan is sold against. It never discounts a WHOLE-COURSE enrolment, so
/// [isWholeCourse] must be true whenever the figure being priced is the course
/// price rather than a trial lesson's (on a card: `HomClass.showsWholeCoursePrice`).
/// Every caller must pass this rather than assume it.
///
/// This mirrors `OrdersService.applyCouponPlan` on the backend, which
/// `courseCheckout` reaches only for `kind === 'trial'`. Keep the two in step —
/// this function is only a preview of what that code will charge.
num effectiveCouponPercent(
  num planPercent,
  num? classSharePercent, {
  required bool isWholeCourse,
}) {
  if (isWholeCourse) return 0;
  final share = classSharePercent ?? 0;
  if (planPercent <= 0 || share <= kMinDiscountableSharePercent) return 0;
  final ceiling = share - kPaylovFeePercent;
  return ceiling < planPercent ? ceiling : planPercent;
}

/// Percentages for display: drops the decimal when there isn't one, so a 20%
/// share reads "20%" rather than "20.0%".
String formatCouponPercent(num percent) =>
    percent == percent.roundToDouble() ? '${percent.round()}' : '$percent';

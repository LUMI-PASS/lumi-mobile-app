/// Server-driven vocabularies of the referral programme (`/api/referrals/*`).
///
/// Every enum here that is READ from the backend carries an `unknown` fallback
/// resolved through a `fromKey` that never throws — the backend can add a new
/// status or reason at any time, and an unmodelled value must render as a
/// neutral row, never crash the profile or the checkout.
library;

/// Where a referral stands, from the referrer's side (`invitees[].status`) or
/// the invitee's own (`applied.status`).
enum ReferralStatus {
  /// The friend entered the code; nothing bought yet.
  applied('APPLIED'),

  /// The friend paid a first order; waiting for it to qualify (hold period).
  orderPaid('ORDER_PAID'),

  /// The order qualified; the reward is about to be issued.
  qualified('QUALIFIED'),

  /// Qualified, but held back by a limit (monthly cap, budget, review).
  queued('QUEUED'),

  /// The referrer's voucher was issued.
  rewarded('REWARDED'),

  /// The friend never qualified inside the window.
  expired('EXPIRED'),

  /// Refused — by fraud checks or by an admin.
  rejected('REJECTED'),

  unknown('');

  const ReferralStatus(this.key);

  /// The raw wire value.
  final String key;

  /// Never throws; [unknown] for null or unrecognised values.
  static ReferralStatus fromKey(String? key) {
    final k = key?.trim().toUpperCase();
    for (final s in values) {
      if (s != unknown && s.key == k) return s;
    }
    return unknown;
  }

  /// Still on its way to a reward — counted as "pending" in the stats.
  bool get isInProgress =>
      this == applied || this == orderPaid || this == qualified || this == queued;
}

/// Lifecycle of one personal discount voucher.
enum ReferralVoucherStatus {
  active('ACTIVE'),

  /// Held by an unpaid order; comes back if the order is not paid.
  reserved('RESERVED'),
  used('USED'),
  expired('EXPIRED'),
  revoked('REVOKED'),
  unknown('');

  const ReferralVoucherStatus(this.key);

  final String key;

  static ReferralVoucherStatus fromKey(String? key) {
    final k = key?.trim().toUpperCase();
    for (final s in values) {
      if (s != unknown && s.key == k) return s;
    }
    return unknown;
  }

  /// Can still be spent at checkout.
  bool get isSpendable => this == active;
}

/// Who a voucher was issued to.
enum ReferralVoucherKind {
  /// Earned by inviting a friend who bought.
  referrer('REFERRER'),

  /// The welcome discount of someone who was invited.
  invitee('INVITEE'),
  unknown('');

  const ReferralVoucherKind(this.key);

  final String key;

  static ReferralVoucherKind fromKey(String? key) {
    final k = key?.trim().toUpperCase();
    for (final s in values) {
      if (s != unknown && s.key == k) return s;
    }
    return unknown;
  }
}

/// Why a voucher cannot be spent on the order being checked out
/// (`GET /referrals/vouchers?subtotal=` → `reason`).
enum ReferralVoucherReason {
  /// The order is below the voucher's `min_order_amount`.
  minOrder('min_order'),

  /// This activity cannot carry a voucher discount.
  notApplicable('not_applicable'),

  /// The buyer has an active coupon plan — the two never stack.
  couponPlan('coupon_plan'),
  unknown('');

  const ReferralVoucherReason(this.key);

  final String key;

  /// Null stays null (the voucher IS applicable); anything unmodelled is
  /// [unknown].
  static ReferralVoucherReason? fromKey(String? key) {
    if (key == null || key.trim().isEmpty) return null;
    final k = key.trim().toLowerCase();
    for (final s in values) {
      if (s != unknown && s.key == k) return s;
    }
    return unknown;
  }
}

/// How a code reached `POST /referrals/apply`. Sent, never read.
enum ReferralApplySource {
  /// Arrived through an invite link (direct or deferred). Every refusal of a
  /// link-sourced code is SOFT — the user never typed it, so an error dialog
  /// about it would make no sense to them.
  link('LINK'),

  /// Typed by the user.
  manual('MANUAL');

  const ReferralApplySource(this.key);

  final String key;
}

/// Analytics events for `POST /referrals/events`. Sent, never read.
enum ReferralEventType {
  shared('shared'),
  linkOpened('link_opened');

  const ReferralEventType(this.key);

  final String key;
}

/// `error_code` on a 400/429 from `POST /referrals/apply`.
///
/// Localised through [messageKey] (`referral.error.<code>` in
/// translations.csv).
enum ReferralErrorCode {
  codeNotFound('code_not_found'),
  ownCode('own_code'),
  codeInactive('code_inactive'),
  alreadyApplied('already_applied'),
  windowClosed('window_closed'),
  notNewUser('not_new_user'),
  programOff('program_off'),

  /// 429 — throttled. Not a verdict on the code: try again later.
  tooManyAttempts('too_many_attempts'),
  unknown('');

  const ReferralErrorCode(this.key);

  final String key;

  static ReferralErrorCode fromKey(String? key) {
    final k = key?.trim().toLowerCase();
    for (final c in values) {
      if (c != unknown && c.key == k) return c;
    }
    return unknown;
  }

  /// The translations.csv key for the user-facing message.
  String get messageKey => switch (this) {
        ReferralErrorCode.codeNotFound => 'referral.error.code_not_found',
        ReferralErrorCode.ownCode => 'referral.error.own_code',
        ReferralErrorCode.codeInactive => 'referral.error.code_inactive',
        ReferralErrorCode.alreadyApplied => 'referral.error.already_applied',
        ReferralErrorCode.windowClosed => 'referral.error.window_closed',
        ReferralErrorCode.notNewUser => 'referral.error.not_new_user',
        ReferralErrorCode.programOff => 'referral.error.program_off',
        ReferralErrorCode.tooManyAttempts =>
          'referral.error.too_many_attempts',
        ReferralErrorCode.unknown => 'referral.error.unknown',
      };

  /// The server has given its final word: retrying the same code on this
  /// account can never succeed, so a stored pending code should be dropped.
  ///
  /// [tooManyAttempts] and [unknown] (a 5xx, a timeout, a body we could not
  /// read) are not verdicts — the code is kept for the next attempt.
  bool get isDefinitive => switch (this) {
        ReferralErrorCode.codeNotFound ||
        ReferralErrorCode.ownCode ||
        ReferralErrorCode.codeInactive ||
        ReferralErrorCode.alreadyApplied ||
        ReferralErrorCode.windowClosed ||
        ReferralErrorCode.notNewUser ||
        ReferralErrorCode.programOff =>
          true,
        ReferralErrorCode.tooManyAttempts || ReferralErrorCode.unknown => false,
      };

  /// The refusal is about the ACCOUNT, not the code: no code will ever apply
  /// to it. A typed code that fails for a code-specific reason (a typo) must
  /// not discard a valid invite-link code still waiting to be applied.
  bool get isAccountLevel => switch (this) {
        ReferralErrorCode.alreadyApplied ||
        ReferralErrorCode.windowClosed ||
        ReferralErrorCode.notNewUser ||
        ReferralErrorCode.programOff =>
          true,
        ReferralErrorCode.codeNotFound ||
        ReferralErrorCode.ownCode ||
        ReferralErrorCode.codeInactive ||
        ReferralErrorCode.tooManyAttempts ||
        ReferralErrorCode.unknown =>
          false,
      };
}

import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';

// Plain immutable models, parsed by hand like `NotificationModel` and
// `PromocodePreview`: every field degrades (a missing number is 0, a missing
// list is empty, an unknown status is `unknown`) so a partial or newer payload
// never throws out of a profile load or a checkout.

num _num(dynamic v, [num fallback = 0]) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v) ?? fallback;
  return fallback;
}

num? _numOrNull(dynamic v) {
  if (v is num) return v;
  if (v is String) return num.tryParse(v);
  return null;
}

int _int(dynamic v, [int fallback = 0]) => _num(v, fallback).toInt();

String? _str(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

DateTime? _date(dynamic v) {
  final s = _str(v);
  return s == null ? null : DateTime.tryParse(s)?.toLocal();
}

bool _bool(dynamic v, [bool fallback = false]) {
  if (v is bool) return v;
  if (v is String) return v.toLowerCase() == 'true';
  return fallback;
}

Map<String, dynamic> _map(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : const <String, dynamic>{};

List<Map<String, dynamic>> _maps(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

/// What the referrer earns per friend: `reward` on `GET /referrals/me`.
class ReferralReward {
  const ReferralReward({
    this.percent = 0,
    this.maxDiscount = 0,
    this.minOrder = 0,
    this.validityDays = 0,
  });

  final num percent;

  /// Ceiling on one voucher's discount, in soʻm.
  final num maxDiscount;

  /// Smallest order the voucher can be spent on, in soʻm.
  final num minOrder;
  final int validityDays;

  factory ReferralReward.fromJson(Map<String, dynamic> json) => ReferralReward(
        percent: _num(json['percent']),
        maxDiscount: _num(json['max_discount']),
        minOrder: _num(json['min_order']),
        validityDays: _int(json['validity_days']),
      );

  bool get hasReward => percent > 0;
}

class ReferralStats {
  const ReferralStats({this.invited = 0, this.pending = 0, this.rewarded = 0});

  final int invited;
  final int pending;
  final int rewarded;

  factory ReferralStats.fromJson(Map<String, dynamic> json) => ReferralStats(
        invited: _int(json['invited']),
        pending: _int(json['pending']),
        rewarded: _int(json['rewarded']),
      );
}

/// One friend who entered this user's code.
class ReferralInvitee {
  const ReferralInvitee({this.firstName, this.status, this.appliedAt});

  final String? firstName;

  /// Raw wire value; read [referralStatus].
  final String? status;
  final DateTime? appliedAt;

  ReferralStatus get referralStatus => ReferralStatus.fromKey(status);

  factory ReferralInvitee.fromJson(Map<String, dynamic> json) =>
      ReferralInvitee(
        firstName: _str(json['first_name']),
        status: _str(json['status']),
        appliedAt: _date(json['applied_at']),
      );
}

/// Who invited THIS user, when they entered a code.
class ReferralApplied {
  const ReferralApplied({required this.code, this.referrerName, this.status});

  final String code;
  final String? referrerName;
  final String? status;

  ReferralStatus get referralStatus => ReferralStatus.fromKey(status);

  factory ReferralApplied.fromJson(Map<String, dynamic> json) =>
      ReferralApplied(
        code: _str(json['code']) ?? '',
        referrerName: _str(json['referrer_name']),
        status: _str(json['status']),
      );
}

/// A personal discount voucher, spent through the promocode field.
class ReferralVoucher {
  const ReferralVoucher({
    this.id,
    required this.code,
    this.kind,
    this.percent = 0,
    this.maxDiscount = 0,
    this.minOrderAmount = 0,
    this.status,
    this.issuedAt,
    this.expiresAt,
    this.usedAt,
    this.discountAmount,
    this.applicable,
    this.reason,
    this.previewDiscount,
  });

  final String? id;

  /// `R-XXXXXX` — what goes into the promocode field.
  final String code;
  final String? kind;
  final num percent;
  final num maxDiscount;
  final num minOrderAmount;
  final String? status;
  final DateTime? issuedAt;
  final DateTime? expiresAt;
  final DateTime? usedAt;

  /// What it actually saved, once used.
  final num? discountAmount;

  /// Only on `GET /referrals/vouchers?subtotal=`: null when the server was not
  /// asked about a particular order.
  final bool? applicable;
  final String? reason;
  final num? previewDiscount;

  ReferralVoucherStatus get voucherStatus =>
      ReferralVoucherStatus.fromKey(status);

  ReferralVoucherKind get voucherKind => ReferralVoucherKind.fromKey(kind);

  /// Null when the voucher applies (or nobody asked).
  ReferralVoucherReason? get voucherReason =>
      ReferralVoucherReason.fromKey(reason);

  /// Spendable on the order the list was fetched for. A list fetched without
  /// a subtotal says nothing about any order, so it counts as not applicable
  /// rather than inviting a tap the server would refuse.
  bool get isApplicable => applicable == true;

  factory ReferralVoucher.fromJson(Map<String, dynamic> json) =>
      ReferralVoucher(
        id: _str(json['id'] ?? json['_id']),
        code: _str(json['code']) ?? '',
        kind: _str(json['kind']),
        percent: _num(json['percent']),
        maxDiscount: _num(json['max_discount']),
        minOrderAmount: _num(json['min_order_amount']),
        status: _str(json['status']),
        issuedAt: _date(json['issued_at']),
        expiresAt: _date(json['expires_at']),
        usedAt: _date(json['used_at']),
        discountAmount: _numOrNull(json['discount_amount']),
        applicable: json['applicable'] is bool ? json['applicable'] as bool : null,
        reason: _str(json['reason']),
        previewDiscount: _numOrNull(json['preview_discount']),
      );
}

/// `GET /referrals/me` — everything the profile card and the referral screen
/// show.
class ReferralMe {
  const ReferralMe({
    this.enabled = false,
    this.code,
    this.link,
    this.shareText,
    this.reward = const ReferralReward(),
    this.qualifyMinOrder = 0,
    this.stats = const ReferralStats(),
    this.invitees = const [],
    this.canApply = false,
    this.applyDeadline,
    this.applied,
    this.vouchers = const [],
  });

  /// The programme switch. Off hides the invite card and the "have a code?"
  /// entry; vouchers already issued are still listed.
  final bool enabled;
  final String? code;
  final String? link;

  /// Already localised (by `X-Language`) and filled — shared as-is.
  final String? shareText;
  final ReferralReward reward;

  /// A friend's first order must reach this for the referrer to be rewarded.
  final num qualifyMinOrder;
  final ReferralStats stats;
  final List<ReferralInvitee> invitees;

  /// Whether this account may still enter someone's code.
  final bool canApply;
  final DateTime? applyDeadline;
  final ReferralApplied? applied;
  final List<ReferralVoucher> vouchers;

  factory ReferralMe.fromJson(Map<String, dynamic> json) {
    final applied = json['applied'];
    return ReferralMe(
      enabled: _bool(json['enabled']),
      code: _str(json['code']),
      link: _str(json['link']),
      shareText: _str(json['share_text']),
      reward: ReferralReward.fromJson(_map(json['reward'])),
      qualifyMinOrder: _num(json['qualify_min_order']),
      stats: ReferralStats.fromJson(_map(json['stats'])),
      invitees: _maps(json['invitees']).map(ReferralInvitee.fromJson).toList(),
      canApply: _bool(json['can_apply']),
      applyDeadline: _date(json['apply_deadline']),
      applied: applied is Map
          ? ReferralApplied.fromJson(Map<String, dynamic>.from(applied))
          : null,
      vouchers: _maps(json['vouchers']).map(ReferralVoucher.fromJson).toList(),
    );
  }

  /// The invite card has something to offer.
  bool get canInvite => enabled && (code?.isNotEmpty ?? false);

  /// The share-sheet payload, falling back to the code and link when the
  /// server sent no text.
  String get shareMessage =>
      shareText ?? [code, link].whereType<String>().join('\n');
}

/// `GET /referrals/lookup/:code` (signed-in) — for "Invited by Aziza".
class ReferralLookup {
  const ReferralLookup({this.valid = false, this.code, this.referrerFirstName});

  final bool valid;

  /// The server's normalised form of the code that was looked up.
  final String? code;
  final String? referrerFirstName;

  factory ReferralLookup.fromJson(Map<String, dynamic> json) => ReferralLookup(
        valid: _bool(json['valid']),
        code: _str(json['code']),
        referrerFirstName: _str(json['referrer_first_name']),
      );
}

/// 201 from `POST /referrals/apply`.
class ReferralApplyResult {
  const ReferralApplyResult({
    required this.code,
    this.status,
    this.referrerName,
    this.appliedAt,
    this.expiresAt,
  });

  final String code;
  final String? status;
  final String? referrerName;
  final DateTime? appliedAt;
  final DateTime? expiresAt;

  factory ReferralApplyResult.fromJson(Map<String, dynamic> json) =>
      ReferralApplyResult(
        code: _str(json['code']) ?? '',
        status: _str(json['status']),
        referrerName: _str(json['referrer_name']),
        appliedAt: _date(json['applied_at']),
        expiresAt: _date(json['expires_at']),
      );
}

/// What one apply attempt came to. Never an exception: every caller decides
/// for itself whether a refusal is shown (typed code) or swallowed (link).
class ReferralApplyOutcome {
  const ReferralApplyOutcome._({this.result, this.error, this.message});

  const ReferralApplyOutcome.success(ReferralApplyResult result)
      : this._(result: result);

  const ReferralApplyOutcome.failure(ReferralErrorCode error, {String? message})
      : this._(error: error, message: message);

  final ReferralApplyResult? result;

  /// Null on success.
  final ReferralErrorCode? error;

  /// The server's own `message`, for logs only — the UI uses [error].
  final String? message;

  bool get isSuccess => result != null;

  /// The server settled it one way or the other.
  bool get isDefinitive => isSuccess || (error?.isDefinitive ?? false);
}

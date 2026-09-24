import 'package:lumi_pass/common/router/referral_link.dart';
import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';

/// How a pending code got onto the device. Stored locally, never sent.
enum PendingReferralOrigin {
  /// An invite link, direct or deferred.
  link('link'),

  /// Typed by the user, but not yet accepted by the server (offline, throttled).
  typed('typed');

  const PendingReferralOrigin(this.key);

  final String key;

  /// Anything unreadable counts as [link] — the softer of the two, whose
  /// refusals are never shown.
  static PendingReferralOrigin fromKey(String? key) =>
      key == typed.key ? typed : link;

  ReferralApplySource get source => switch (this) {
        PendingReferralOrigin.link => ReferralApplySource.link,
        PendingReferralOrigin.typed => ReferralApplySource.manual,
      };
}

/// A code waiting to be applied.
class PendingReferralCode {
  const PendingReferralCode({
    required this.code,
    required this.storedAt,
    required this.origin,
  });

  final String code;
  final DateTime storedAt;
  final PendingReferralOrigin origin;

  @override
  String toString() => 'PendingReferralCode($code, ${origin.key}, $storedAt)';
}

/// The rules for the code an invite link leaves on the device.
///
/// Device-scoped on purpose: an invite is clicked BEFORE there is an account
/// (often before the app is installed), so it cannot belong to one — and it
/// survives a logout, because the person who clicked it may well sign in as
/// someone else next.
abstract final class PendingReferralPolicy {
  const PendingReferralPolicy._();

  /// How long a stored invite stays usable. Matches the server's apply window
  /// for a new account, so a code is never kept longer than it could work.
  static const ttl = Duration(days: 7);

  /// Rebuilds the stored code, or null when there is none or it has expired.
  static PendingReferralCode? read({
    required String? code,
    required int? storedAtMs,
    required String? origin,
    required DateTime now,
  }) {
    final normalized = ReferralCodes.normalize(code);
    if (normalized == null || storedAtMs == null) return null;
    final storedAt = DateTime.fromMillisecondsSinceEpoch(storedAtMs);
    if (isExpired(storedAt, now)) return null;
    return PendingReferralCode(
      code: normalized,
      storedAt: storedAt,
      origin: PendingReferralOrigin.fromKey(origin),
    );
  }

  static bool isExpired(DateTime storedAt, DateTime now) =>
      now.difference(storedAt) > ttl;

  /// Whether an incoming code should replace what is stored (A14).
  ///
  /// A code the user TYPED wins over one a link carried: a link opened later —
  /// an old invite still sitting in a chat, a re-fired deferred link — must
  /// not overwrite what the person deliberately entered. Everything else
  /// replaces (a newer link is the fresher intent; a typed code always wins).
  static bool shouldStore({
    required PendingReferralCode? existing,
    required String incoming,
    required PendingReferralOrigin origin,
  }) {
    if (origin == PendingReferralOrigin.typed) return true;
    if (existing == null) return true;
    if (existing.origin == PendingReferralOrigin.typed &&
        existing.code != incoming) {
      return false;
    }
    return true;
  }

  /// The code and source to submit from a form that shows [typed] in a field
  /// prefilled with [pendingCode].
  ///
  /// Whatever is in the field wins (A14). It is still `LINK` when the user left
  /// the prefilled link code untouched — they did not type it, so a refusal is
  /// soft — and `MANUAL` the moment they typed or edited anything. Null when
  /// the field is empty or holds nothing code-shaped.
  static ({String code, ReferralApplySource source})? choose({
    required String typed,
    required PendingReferralCode? pending,
  }) {
    final code = ReferralCodes.normalize(typed);
    if (code == null) return null;
    final fromLink = pending != null &&
        pending.origin == PendingReferralOrigin.link &&
        pending.code == code;
    return (
      code: code,
      source: fromLink ? ReferralApplySource.link : ReferralApplySource.manual,
    );
  }
}

import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/router/deep_link_log.dart';
import 'package:lumi_pass/common/router/referral_link.dart';
import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';
import 'package:lumi_pass/data/service/referral/pending_referral.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/domain/repo/referrals/referral_repository.dart';

/// Owns the pending invite code: stores what links bring in, and applies it
/// once there is an account to apply it to.
///
/// The backend decides eligibility — this class only calls and records. Every
/// apply it makes on its own (a link, a sign-in) is SILENT: the user never
/// typed that code, so a refusal is logged and dropped, never shown (A15/A16).
@lazySingleton
class ReferralCoordinator {
  ReferralCoordinator(this._storage, this._repo);

  final Storage _storage;
  final ReferralRepository _repo;

  Future<ReferralApplyOutcome?>? _inFlight;

  /// The last `link_opened` reported, so one tap delivered by two channels
  /// (AppsFlyer's callback and the OS link) counts once.
  String? _lastOpenedCode;
  DateTime? _lastOpenedAt;

  /// A real session — the App Review guest token does not count.
  bool get isSignedIn => _storage.tokens.call()?.access != null;

  /// The stored code, or null when there is none or it has expired.
  PendingReferralCode? get pending => PendingReferralPolicy.read(
        code: _storage.pendingReferralCode.call(),
        storedAtMs: _storage.pendingReferralAt.call(),
        origin: _storage.pendingReferralOrigin.call(),
        now: DateTime.now(),
      );

  Future<void> _store(String code, PendingReferralOrigin origin) async {
    await _storage.pendingReferralCode.set(code);
    await _storage.pendingReferralAt.set(DateTime.now().millisecondsSinceEpoch);
    await _storage.pendingReferralOrigin.set(origin.key);
    dlog('referral: stored pending $code (${origin.key})');
  }

  Future<void> clearPending() async {
    await _storage.pendingReferralCode.set(null);
    await _storage.pendingReferralAt.set(null);
    await _storage.pendingReferralOrigin.set(null);
  }

  /// An invite link arrived — direct, deferred, or re-fired on resume.
  ///
  /// Stored first and unconditionally (subject to A14), so a deferred link on
  /// the very first launch survives onboarding and login. Nothing navigates.
  Future<void> onLinkCode(String rawCode) async {
    final code = ReferralCodes.normalize(rawCode);
    if (code == null) return;

    if (PendingReferralPolicy.shouldStore(
      existing: pending,
      incoming: code,
      origin: PendingReferralOrigin.link,
    )) {
      await _store(code, PendingReferralOrigin.link);
    } else {
      dlog('referral: kept the typed code over link code $code');
    }

    if (!isSignedIn) return;
    final now = DateTime.now();
    final last = _lastOpenedAt;
    if (_lastOpenedCode != code ||
        last == null ||
        now.difference(last) > const Duration(seconds: 10)) {
      _lastOpenedCode = code;
      _lastOpenedAt = now;
      unawaited(_repo.logEvent(ReferralEventType.linkOpened, code: code));
    }
    await applyPendingSilently();
  }

  /// Applies the stored code, if any, without ever surfacing a refusal.
  ///
  /// Called when a link arrives for a signed-in user, right after sign-in, and
  /// on each profile load (which retries a code a network blip left behind).
  /// Concurrent calls share one request.
  Future<ReferralApplyOutcome?> applyPendingSilently() {
    if (!isSignedIn) return Future.value();
    final p = pending;
    if (p == null) return Future.value();
    return _inFlight ??= _applyPending(p).whenComplete(() => _inFlight = null);
  }

  Future<ReferralApplyOutcome?> _applyPending(PendingReferralCode p) async {
    final outcome = await _repo.apply(p.code, source: p.origin.source);
    // Success, or a refusal the server will repeat forever: either way the code
    // has done all it can. A throttle or a network failure keeps it.
    if (outcome.isDefinitive && pending?.code == p.code) await clearPending();
    dlog('referral: silent apply ${p.code} -> '
        '${outcome.isSuccess ? "applied" : outcome.error?.key}');
    return outcome;
  }

  /// A code submitted from a form (the onboarding sheet, the profile's
  /// "Have a referral code?" sheet). The caller shows the result — for
  /// [ReferralApplySource.manual] only.
  Future<ReferralApplyOutcome> applyFromForm(
    String code, {
    required ReferralApplySource source,
  }) async {
    final outcome = await _repo.apply(code, source: source);
    final error = outcome.error;
    if (outcome.isSuccess) {
      await clearPending();
    } else if (error != null && error.isAccountLevel) {
      // No code will ever apply to this account — a stored one included.
      await clearPending();
    } else if (source == ReferralApplySource.link && outcome.isDefinitive) {
      // It WAS the stored link code, and the server refused it.
      await clearPending();
    } else if (source == ReferralApplySource.manual && !outcome.isDefinitive) {
      // Typed, but never judged (offline, throttled): keep it — ahead of any
      // link code (A14) — for the next silent attempt.
      await _store(code, PendingReferralOrigin.typed);
    }
    return outcome;
  }
}

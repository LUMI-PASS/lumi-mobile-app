import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';
import 'package:lumi_pass/data/service/referral/pending_referral.dart';

void main() {
  final t0 = DateTime(2026, 9, 1, 12);

  PendingReferralCode? read(
    DateTime now, {
    String? code = 'LUMI7K3Q',
    String? origin = 'link',
  }) =>
      PendingReferralPolicy.read(
        code: code,
        storedAtMs: t0.millisecondsSinceEpoch,
        origin: origin,
        now: now,
      );

  group('expiry', () {
    test('a fresh code is readable', () {
      final p = read(t0.add(const Duration(minutes: 5)));
      expect(p?.code, 'LUMI7K3Q');
      expect(p?.origin, PendingReferralOrigin.link);
    });

    test('still valid on the last moment of day 7', () {
      expect(read(t0.add(const Duration(days: 7))), isNotNull);
    });

    test('gone after 7 days', () {
      expect(read(t0.add(const Duration(days: 7, minutes: 1))), isNull);
      expect(read(t0.add(const Duration(days: 30))), isNull);
    });

    test('nothing stored reads as nothing', () {
      expect(read(t0, code: null), isNull);
      expect(
        PendingReferralPolicy.read(
          code: 'LUMI7K3Q',
          storedAtMs: null,
          origin: 'link',
          now: t0,
        ),
        isNull,
      );
    });

    test('a stored code is re-normalised on the way out', () {
      expect(read(t0, code: ' lumi7k3q ')?.code, 'LUMI7K3Q');
    });

    test('an unreadable origin counts as a (silent) link', () {
      expect(read(t0, origin: 'garbage')?.origin, PendingReferralOrigin.link);
      expect(read(t0, origin: null)?.origin, PendingReferralOrigin.link);
      expect(read(t0, origin: 'typed')?.origin, PendingReferralOrigin.typed);
    });

    test('origin maps onto the apply source', () {
      expect(PendingReferralOrigin.link.source, ReferralApplySource.link);
      expect(PendingReferralOrigin.typed.source, ReferralApplySource.manual);
    });
  });

  group('a typed code wins over a link code (A14)', () {
    final typed = PendingReferralCode(
      code: 'TYPED1',
      storedAt: t0,
      origin: PendingReferralOrigin.typed,
    );
    final linked = PendingReferralCode(
      code: 'LINK1',
      storedAt: t0,
      origin: PendingReferralOrigin.link,
    );

    test('a link never overwrites a different typed code', () {
      expect(
        PendingReferralPolicy.shouldStore(
          existing: typed,
          incoming: 'LINK2',
          origin: PendingReferralOrigin.link,
        ),
        isFalse,
      );
    });

    test('a typed code replaces a link code', () {
      expect(
        PendingReferralPolicy.shouldStore(
          existing: linked,
          incoming: 'TYPED2',
          origin: PendingReferralOrigin.typed,
        ),
        isTrue,
      );
    });

    test('a newer link replaces an older link', () {
      expect(
        PendingReferralPolicy.shouldStore(
          existing: linked,
          incoming: 'LINK2',
          origin: PendingReferralOrigin.link,
        ),
        isTrue,
      );
    });

    test('with nothing stored, a link is stored', () {
      expect(
        PendingReferralPolicy.shouldStore(
          existing: null,
          incoming: 'LINK2',
          origin: PendingReferralOrigin.link,
        ),
        isTrue,
      );
    });

    test('the field content decides what is submitted, and how', () {
      // Left untouched: still the link's code, still a silent LINK apply.
      var c = PendingReferralPolicy.choose(typed: 'LINK1', pending: linked);
      expect(c?.code, 'LINK1');
      expect(c?.source, ReferralApplySource.link);

      // Only re-cased: the same code, still LINK.
      c = PendingReferralPolicy.choose(typed: 'link1 ', pending: linked);
      expect(c?.source, ReferralApplySource.link);

      // Edited: what was typed wins, and it is MANUAL.
      c = PendingReferralPolicy.choose(typed: 'friend9', pending: linked);
      expect(c?.code, 'FRIEND9');
      expect(c?.source, ReferralApplySource.manual);

      // Nothing pending: MANUAL.
      c = PendingReferralPolicy.choose(typed: 'FRIEND9', pending: null);
      expect(c?.source, ReferralApplySource.manual);

      // A pending TYPED code re-submitted is still MANUAL.
      c = PendingReferralPolicy.choose(typed: 'TYPED1', pending: typed);
      expect(c?.source, ReferralApplySource.manual);

      // Empty field: nothing to submit.
      expect(PendingReferralPolicy.choose(typed: '  ', pending: linked), isNull);
    });
  });
}

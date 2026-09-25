import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/promo/promo_campaign.dart';
import 'package:lumi_pass/data/api_model/promo/promo_coverage.dart';
import 'package:lumi_pass/data/api_model/promo/promo_eligibility.dart';
import 'package:lumi_pass/data/api_model/promo/promo_ineligible_reason.dart';
import 'package:lumi_pass/data/api_model/promo/promo_pass.dart';
import 'package:lumi_pass/data/api_model/promo/promo_pass_status.dart';

/// The app's half of the "аксия" contract.
///
/// The RULES live on the server — which visits qualify, and when the five days
/// run out — and this suite does not re-test them. What it pins down is the
/// part the app owns and can get wrong on its own: reading the server's answer
/// without crashing on a field it has never seen, and refusing to promise
/// anything the answer did not actually say.
void main() {
  group('PromoCampaign.fromJson', () {
    test('reads the flagship bundle', () {
      final c = PromoCampaign.fromJson({
        'id': '68f0',
        'slug': 'lumi-3-for-99',
        'title': '3 занятия за 99 000 сум',
        'subtitle': 'Попробуйте три разных места',
        'badge': 'АКЦИЯ',
        'highlights': ['3 разных занятия', '5 дней'],
        'price': 99000,
        'old_price': 150000,
        'currency': 'UZS',
        'activities_count': 3,
        'valid_days': 5,
        'coverage': 'full',
        'distinct_activities': true,
        'active_passes': [],
        'can_purchase': true,
      });

      expect(c.slug, 'lumi-3-for-99');
      expect(c.activitiesCount, 3);
      expect(c.validDays, 5);
      expect(c.coverage, PromoCoverage.full);
      expect(c.coverage.isFull, isTrue);
      expect(c.saving, 51000);
      expect(c.highlights, hasLength(2));
      expect(c.heldPass, isNull);
      expect(c.canPurchase, isTrue);
    });

    test('drops a comparison price that is not actually a saving', () {
      // A struck-through price at or below the real one is a broken promise,
      // not a discount — so it is simply not shown.
      final c = PromoCampaign.fromJson({
        'id': 'x',
        'slug': 's',
        'title': 't',
        'price': 99000,
        'old_price': 99000,
      });
      expect(c.saving, isNull);
    });

    test('falls back to an older backend that sends no can_purchase', () {
      final c = PromoCampaign.fromJson({'id': 'x', 'slug': 's', 'title': 't'});
      // Absent meant "buying is offered" before the field existed; reading it
      // as false would hide the Buy bar on every older server.
      expect(c.canPurchase, isTrue);
    });

    test('surfaces a held pass so the screen stops selling', () {
      final c = PromoCampaign.fromJson({
        'id': 'x',
        'slug': 's',
        'title': 't',
        'can_purchase': false,
        'active_passes': [
          {
            'id': 'p1',
            'code': 'AKSIYA-AAAA-BBBB',
            'activities_total': 3,
            'activities_used': 1,
            'activities_left': 2,
            'days_left': 4,
            'status': 'active',
          },
        ],
      });
      expect(c.heldPass?.code, 'AKSIYA-AAAA-BBBB');
      expect(c.heldPass?.activitiesLeft, 2);
      expect(c.canPurchase, isFalse);
    });

    test('never throws on an unmodelled coverage kind', () {
      final c = PromoCampaign.fromJson({
        'id': 'x',
        'slug': 's',
        'title': 't',
        'coverage': 'something_new',
      });
      expect(c.coverage, PromoCoverage.unknown);
      // An unknown kind must not make the app promise a free booking.
      expect(c.coverage.isFull, isFalse);
    });
  });

  group('PromoPass.fromJson', () {
    Map<String, dynamic> json({
      int used = 1,
      int? left,
      String status = 'active',
      bool usable = true,
      int daysLeft = 3,
    }) =>
        {
          'id': 'p1',
          'code': 'AKSIYA-AAAA-BBBB',
          'title': '3 занятия',
          'price': 99000,
          'status': status,
          'is_usable': usable,
          'activities_total': 3,
          'activities_used': used,
          if (left != null) 'activities_left': left,
          'valid_days': 5,
          'coverage': 'full',
          'distinct_activities': true,
          'purchased_at': '2026-09-24T10:00:00.000Z',
          'expires_at': '2026-09-29T10:00:00.000Z',
          'days_left': daysLeft,
          'redemptions': [
            {
              'activity_id': 'a1',
              'activity_name': 'Батутный центр',
              'order_id': 'o1',
              'ticket_date': '2026-09-25',
              'ticket_no': 'A-0042',
              'amount_covered': 30000,
              'redeemed_at': '2026-09-24T11:00:00.000Z',
              'attended': true,
              'attended_at': '2026-09-25T12:00:00.000Z',
            },
          ],
        };

    test('reads the pass and its spent visits', () {
      final p = PromoPass.fromJson(json());
      expect(p.status, PromoPassStatus.active);
      expect(p.isUsable, isTrue);
      expect(p.activitiesLeft, 2);
      expect(p.progress, closeTo(1 / 3, 0.001));
      expect(p.redemptions, hasLength(1));
      expect(p.redemptions.first.activityName, 'Батутный центр');
      expect(p.redemptions.first.attended, isTrue);
      expect(p.redemptions.first.ticketNo, 'A-0042');
    });

    test('derives what is left only when the server did not say', () {
      // Trusted when sent: the two can only disagree if one is wrong, and the
      // server is the one that counted.
      expect(PromoPass.fromJson(json(used: 1, left: 0)).activitiesLeft, 0);
      expect(PromoPass.fromJson(json(used: 2)).activitiesLeft, 1);
    });

    test('flags the last two days as running out — but only while usable', () {
      expect(PromoPass.fromJson(json(daysLeft: 2)).isRunningOut, isTrue);
      expect(PromoPass.fromJson(json(daysLeft: 3)).isRunningOut, isFalse);
      // Nothing to hurry about on a pass that can no longer be spent.
      expect(
        PromoPass.fromJson(json(daysLeft: 1, usable: false)).isRunningOut,
        isFalse,
      );
    });

    test('treats an unmodelled status as live rather than finished', () {
      final p = PromoPass.fromJson(json(status: 'on_hold'));
      expect(p.status, PromoPassStatus.unknown);
      // Showing a live pass as finished would hide visits somebody paid for.
      expect(p.status.isFinished, isFalse);
      expect(PromoPassStatus.expired.isFinished, isTrue);
      expect(PromoPassStatus.used.isFinished, isTrue);
      expect(PromoPassStatus.canceled.isFinished, isTrue);
    });

    test('survives a response with almost nothing in it', () {
      final p = PromoPass.fromJson({'id': 'p1', 'code': 'C'});
      expect(p.activitiesTotal, 0);
      expect(p.activitiesLeft, 0);
      expect(p.progress, 0);
      expect(p.redemptions, isEmpty);
      expect(p.expiresAt, isNull);
    });
  });

  group('PromoEligibility', () {
    test('reads a positive answer and what it covers', () {
      final e = PromoEligibility.fromJson({
        'eligible': true,
        'covered': 30000,
        'pass': {
          'id': 'p1',
          'code': 'AKSIYA-AAAA-BBBB',
          'activities_left': 2,
          'days_left': 3,
        },
      });
      expect(e.eligible, isTrue);
      expect(e.covered, 30000);
      expect(e.pass?.activitiesLeft, 2);
      expect(e.shouldShowRow, isTrue);
    });

    test('shows the row for a refusal the buyer can fix here', () {
      for (final key in ['date_after_expiry', 'already_used_here']) {
        final e = PromoEligibility.fromJson({'eligible': false, 'reason': key});
        expect(e.shouldShowRow, isTrue, reason: key);
        expect(e.reason!.isFixableHere, isTrue, reason: key);
      }
    });

    test('hides the row when there is simply no pass', () {
      final e = PromoEligibility.fromJson({
        'eligible': false,
        'reason': 'no_pass',
      });
      // Selling the bundle is the offer screen's job, not the booking sheet's.
      expect(e.shouldShowRow, isFalse);
      expect(PromoEligibility.none.shouldShowRow, isFalse);
    });

    test('hides the row for a refusal nothing on this screen can change', () {
      for (final key in ['expired', 'exhausted', 'out_of_scope', 'course']) {
        final e = PromoEligibility.fromJson({'eligible': false, 'reason': key});
        expect(e.shouldShowRow, isFalse, reason: key);
      }
    });

    test('every refusal has a localization key, unknown ones included', () {
      for (final reason in PromoIneligibleReason.values) {
        expect(reason.messageKey, startsWith('aksiya_why_'));
      }
      expect(
        PromoIneligibleReason.fromKey('brand_new_reason'),
        PromoIneligibleReason.unknown,
      );
      expect(
        PromoIneligibleReason.unknown.messageKey,
        'aksiya_why_generic',
      );
    });

    test('a refusal the buyer can fix on the sheet keeps the row', () {
      // Take a ticket off, or clear the code — both are one tap away on the
      // screen that is showing the message, so it says so rather than hiding.
      for (final key in ['too_many_tickets', 'with_promocode']) {
        final e = PromoEligibility.fromJson({'eligible': false, 'reason': key});
        expect(e.shouldShowRow, isTrue, reason: key);
        expect(e.reason!.isFixableHere, isTrue, reason: key);
      }
    });

    test('resolves the namespaced error_code a refused checkout returns', () {
      // Keyed on the code, never the sentence: the message is an English
      // fallback for older builds and logs, and rewording it must not break
      // the localized path.
      expect(
        PromoIneligibleReason.fromErrorCode('promo_pass_too_many_tickets'),
        PromoIneligibleReason.tooManyTickets,
      );
      expect(
        PromoIneligibleReason.fromErrorCode('promo_pass_date_after_expiry'),
        PromoIneligibleReason.dateAfterExpiry,
      );
      // A code from a newer server still lands on a real message.
      expect(
        PromoIneligibleReason.fromErrorCode('promo_pass_brand_new'),
        PromoIneligibleReason.unknown,
      );
      // Not ours: a promocode error must fall through to its own handler.
      expect(PromoIneligibleReason.fromErrorCode('max_order'), isNull);
      expect(PromoIneligibleReason.fromErrorCode(null), isNull);
    });

    test('an empty reason string is no reason at all', () {
      final e = PromoEligibility.fromJson({'eligible': true, 'reason': ''});
      expect(e.reason, isNull);
    });
  });
}

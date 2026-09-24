import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/utils/fixed_csv_parser.dart';
import 'package:lumi_pass/data/api_model/notification_model/notification_type.dart';
import 'package:lumi_pass/data/api_model/order/promo_error_code.dart';
import 'package:lumi_pass/data/api_model/referral/referral_enums.dart';
import 'package:lumi_pass/data/api_model/referral/referral_models.dart';

void main() {
  group('enums fall back to unknown, never throw', () {
    test('ReferralStatus', () {
      expect(ReferralStatus.fromKey('APPLIED'), ReferralStatus.applied);
      expect(ReferralStatus.fromKey('ORDER_PAID'), ReferralStatus.orderPaid);
      expect(ReferralStatus.fromKey('rewarded'), ReferralStatus.rewarded);
      expect(ReferralStatus.fromKey('REVIEW_ME'), ReferralStatus.unknown);
      expect(ReferralStatus.fromKey(null), ReferralStatus.unknown);
      expect(ReferralStatus.fromKey(''), ReferralStatus.unknown);
      for (final s in ReferralStatus.values) {
        if (s == ReferralStatus.unknown) continue;
        expect(ReferralStatus.fromKey(s.key), s);
      }
    });

    test('ReferralVoucherStatus', () {
      expect(ReferralVoucherStatus.fromKey('ACTIVE'),
          ReferralVoucherStatus.active);
      expect(ReferralVoucherStatus.fromKey('REVOKED'),
          ReferralVoucherStatus.revoked);
      expect(ReferralVoucherStatus.fromKey('FROZEN'),
          ReferralVoucherStatus.unknown);
      expect(ReferralVoucherStatus.fromKey(null), ReferralVoucherStatus.unknown);
      expect(ReferralVoucherStatus.active.isSpendable, isTrue);
      expect(ReferralVoucherStatus.reserved.isSpendable, isFalse);
    });

    test('ReferralVoucherKind', () {
      expect(ReferralVoucherKind.fromKey('INVITEE'), ReferralVoucherKind.invitee);
      expect(ReferralVoucherKind.fromKey('PARTNER'), ReferralVoucherKind.unknown);
    });

    test('ReferralVoucherReason: null means applicable', () {
      expect(ReferralVoucherReason.fromKey(null), isNull);
      expect(ReferralVoucherReason.fromKey(''), isNull);
      expect(ReferralVoucherReason.fromKey('min_order'),
          ReferralVoucherReason.minOrder);
      expect(ReferralVoucherReason.fromKey('coupon_plan'),
          ReferralVoucherReason.couponPlan);
      expect(ReferralVoucherReason.fromKey('weekend_only'),
          ReferralVoucherReason.unknown);
    });

    test('ReferralErrorCode', () {
      expect(ReferralErrorCode.fromKey('own_code'), ReferralErrorCode.ownCode);
      expect(ReferralErrorCode.fromKey('too_many_attempts'),
          ReferralErrorCode.tooManyAttempts);
      expect(ReferralErrorCode.fromKey('brand_new_reason'),
          ReferralErrorCode.unknown);
      expect(ReferralErrorCode.fromKey(null), ReferralErrorCode.unknown);
    });

    test('NotificationType knows the referral push', () {
      expect(NotificationType.fromKey('referral'), NotificationType.referral);
      expect(NotificationType.fromKey('something_new'),
          NotificationType.unknown);
    });
  });

  group('error code → message key', () {
    test('every referral error maps to referral.error.<code>', () {
      for (final c in ReferralErrorCode.values) {
        final expected = c == ReferralErrorCode.unknown
            ? 'referral.error.unknown'
            : 'referral.error.${c.key}';
        expect(c.messageKey, expected, reason: c.name);
      }
    });

    test('verdicts vs retryable failures', () {
      expect(ReferralErrorCode.codeNotFound.isDefinitive, isTrue);
      expect(ReferralErrorCode.alreadyApplied.isDefinitive, isTrue);
      expect(ReferralErrorCode.programOff.isDefinitive, isTrue);
      expect(ReferralErrorCode.tooManyAttempts.isDefinitive, isFalse);
      expect(ReferralErrorCode.unknown.isDefinitive, isFalse);
      // A typo must not discard a valid invite still waiting to be applied…
      expect(ReferralErrorCode.codeNotFound.isAccountLevel, isFalse);
      expect(ReferralErrorCode.ownCode.isAccountLevel, isFalse);
      // …but an account that can never take a code drops it.
      expect(ReferralErrorCode.notNewUser.isAccountLevel, isTrue);
      expect(ReferralErrorCode.windowClosed.isAccountLevel, isTrue);
    });

    test('an apply outcome is definitive on success or a verdict', () {
      const ok = ReferralApplyOutcome.success(ReferralApplyResult(code: 'X'));
      expect(ok.isSuccess, isTrue);
      expect(ok.isDefinitive, isTrue);
      expect(
        const ReferralApplyOutcome.failure(ReferralErrorCode.ownCode)
            .isDefinitive,
        isTrue,
      );
      expect(
        const ReferralApplyOutcome.failure(ReferralErrorCode.tooManyAttempts)
            .isDefinitive,
        isFalse,
      );
    });

    test('voucher refusals on the promo field', () {
      expect(PromoErrorCode.fromKey('voucher_not_found'),
          PromoErrorCode.voucherNotFound);
      expect(PromoErrorCode.fromKey('voucher_used'), PromoErrorCode.voucherUsed);
      expect(PromoErrorCode.fromKey('voucher_unavailable'),
          PromoErrorCode.voucherUnavailable);
      expect(PromoErrorCode.fromKey('voucher_expired'),
          PromoErrorCode.voucherExpired);
      expect(PromoErrorCode.fromKey('voucher_min_order'),
          PromoErrorCode.voucherMinOrder);
      expect(PromoErrorCode.fromKey('voucher_gone'), PromoErrorCode.unknown);

      expect(PromoErrorCode.voucherNotFound.messageKey,
          'promo_voucher_not_found');
      expect(PromoErrorCode.voucherMinOrder.messageKey,
          'promo_voucher_min_order');
      expect(PromoErrorCode.notApplicable.messageKey, 'promo_not_applicable');
      expect(PromoErrorCode.unknown.messageKey, 'promo_invalid');
    });

    test('every message key exists in ru, uz and en', () {
      final parser = FixedCsvParser(
        File('assets/localization/translations.csv').readAsStringSync(),
      );
      final keys = {
        for (final c in ReferralErrorCode.values) c.messageKey,
        for (final c in PromoErrorCode.values) c.messageKey,
        'referral_reward_line',
        'referral_invited_by',
        'referral_title',
        'voucher_chip_title',
        'voucher_reason_min_order',
      };
      for (final locale in ['ru_RU', 'uz_UZ', 'en_EN']) {
        final map = parser.getLanguageMap(locale);
        for (final k in keys) {
          expect('${map[k] ?? ''}'.trim(), isNotEmpty,
              reason: '$k missing in $locale');
        }
      }
    });
  });

  group('parsing', () {
    test('GET /referrals/me, as in the contract', () {
      final me = ReferralMe.fromJson({
        'enabled': true,
        'code': 'LUMI7K3Q',
        'link': 'https://link.lumipass.uz/JBWe?deep_link_value=referral',
        'share_text': 'Join me: LUMI7K3Q',
        'reward': {
          'percent': 50,
          'max_discount': 200000,
          'min_order': 100000,
          'validity_days': 90,
        },
        'qualify_min_order': 100000,
        'stats': {'invited': 3, 'pending': 1, 'rewarded': 2},
        'invitees': [
          {
            'first_name': 'Ali',
            'status': 'ORDER_PAID',
            'applied_at': '2026-09-01T10:00:00Z',
          },
          {'first_name': null, 'status': 'SOMETHING_NEW', 'applied_at': null},
        ],
        'can_apply': false,
        'apply_deadline': null,
        'applied': {'code': 'LUMIAZIZ', 'referrer_name': 'Aziza', 'status': 'APPLIED'},
        'vouchers': [
          {
            'id': 'v1',
            'code': 'R-8F3K2P',
            'kind': 'REFERRER',
            'percent': 50,
            'max_discount': 200000,
            'min_order_amount': 100000,
            'status': 'ACTIVE',
            'issued_at': '2026-09-01T10:00:00Z',
            'expires_at': '2026-11-30T10:00:00Z',
            'used_at': null,
            'discount_amount': null,
          },
        ],
      });
      expect(me.canInvite, isTrue);
      expect(me.shareMessage, 'Join me: LUMI7K3Q');
      expect(me.reward.maxDiscount, 200000);
      expect(me.reward.validityDays, 90);
      expect(me.stats.rewarded, 2);
      expect(me.invitees.first.referralStatus, ReferralStatus.orderPaid);
      expect(me.invitees.first.appliedAt, isNotNull);
      expect(me.invitees.last.firstName, isNull);
      expect(me.invitees.last.referralStatus, ReferralStatus.unknown);
      expect(me.applied?.referrerName, 'Aziza');
      expect(me.vouchers.single.voucherKind, ReferralVoucherKind.referrer);
      expect(me.vouchers.single.voucherStatus, ReferralVoucherStatus.active);
      // Listed on /me, not priced against an order: not applicable anywhere.
      expect(me.vouchers.single.isApplicable, isFalse);
    });

    test('disabled programme hides the invite, keeps the vouchers', () {
      final me = ReferralMe.fromJson({
        'enabled': false,
        'code': null,
        'vouchers': [
          {'code': 'R-1', 'status': 'USED', 'discount_amount': 150000},
        ],
      });
      expect(me.canInvite, isFalse);
      expect(me.vouchers.single.discountAmount, 150000);
    });

    test('an empty or garbled payload degrades, never throws', () {
      final me = ReferralMe.fromJson({
        'stats': 'nope',
        'invitees': 'nope',
        'reward': null,
        'vouchers': [1, 'x', null],
      });
      expect(me.enabled, isFalse);
      expect(me.invitees, isEmpty);
      expect(me.vouchers, isEmpty);
      expect(me.reward.hasReward, isFalse);
    });

    test('a checkout voucher carries applicability', () {
      final ok = ReferralVoucher.fromJson({
        'code': 'R-8F3K2P',
        'applicable': true,
        'reason': null,
        'preview_discount': 150000,
      });
      expect(ok.isApplicable, isTrue);
      expect(ok.voucherReason, isNull);
      expect(ok.previewDiscount, 150000);

      final no = ReferralVoucher.fromJson({
        'code': 'R-XXXXXX',
        'applicable': false,
        'reason': 'min_order',
        'min_order_amount': '100000',
      });
      expect(no.isApplicable, isFalse);
      expect(no.voucherReason, ReferralVoucherReason.minOrder);
      expect(no.minOrderAmount, 100000);
    });

    test('lookup', () {
      final l = ReferralLookup.fromJson({
        'valid': true,
        'code': 'LUMI7K3Q',
        'referrer_first_name': 'Aziza',
      });
      expect(l.valid, isTrue);
      expect(l.referrerFirstName, 'Aziza');
      expect(ReferralLookup.fromJson({}).valid, isFalse);
    });
  });
}

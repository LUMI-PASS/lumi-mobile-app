import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/subscription/subscription_record.dart';
import 'package:lumi_pass/data/api_model/subscription/subscription_status.dart';

/// The coupon-history pill colours off this enum, so an `active` coupon that
/// failed to resolve would show up grey among the dead ones.
void main() {
  group('SubscriptionStatus.fromKey', () {
    test('resolves the modelled states', () {
      expect(SubscriptionStatus.fromKey('active'), SubscriptionStatus.active);
      expect(SubscriptionStatus.fromKey('expired'), SubscriptionStatus.expired);
      expect(
        SubscriptionStatus.fromKey('canceled'),
        SubscriptionStatus.canceled,
      );
    });

    test('both spellings of cancelled land on the same state', () {
      expect(
        SubscriptionStatus.fromKey('cancelled'),
        SubscriptionStatus.canceled,
      );
    });

    test('is case- and whitespace-insensitive', () {
      expect(SubscriptionStatus.fromKey(' Active '), SubscriptionStatus.active);
    });

    test('an unmodelled or missing state degrades rather than throwing', () {
      expect(SubscriptionStatus.fromKey('refunded'), SubscriptionStatus.unknown);
      expect(SubscriptionStatus.fromKey(null), SubscriptionStatus.unknown);
      expect(SubscriptionStatus.fromKey(''), SubscriptionStatus.unknown);
    });

    test('only an active coupon is spendable', () {
      expect(SubscriptionStatus.active.isUsable, isTrue);
      for (final s in SubscriptionStatus.values.where(
        (s) => s != SubscriptionStatus.active,
      )) {
        expect(s.isUsable, isFalse, reason: '${s.name} must not read as live');
      }
    });
  });

  test('the record exposes the payload status typed', () {
    final record = SubscriptionRecord.fromJson(const {
      'id': '6a6f81f4939ada52f2c0937c',
      'plan_name': 'Ommabop',
      'start_date': '2026-08-02T17:44:20.631Z',
      'end_date': '2026-09-01T17:44:20.631Z',
      'status': 'active',
      'discount_percentage': 0,
      'activities_limit': 6,
      'used_count': 0,
      'amount': 1000,
    });

    expect(record.subscriptionStatus, SubscriptionStatus.active);
    expect(record.isActive, isTrue);
    expect(record.isExpired, isFalse);
    expect(record.isCanceled, isFalse);
    // The raw string survives for (de)serialization.
    expect(record.status, 'active');
  });
}

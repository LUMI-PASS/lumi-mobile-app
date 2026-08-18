import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/utils/card_input_formatters.dart';
import 'package:lumi_pass/data/api_model/order/saved_card.dart';

/// The expiry is sent YEAR FIRST, and getting it backwards does not fail
/// loudly — it comes back as `card_is_expired` for a perfectly good card, which
/// reads as the buyer's problem rather than ours. That happened on the first
/// real test of the card rail.
void main() {
  group('expiryToYyMm', () {
    test('puts the year first', () {
      // The exact case that failed in production: a card good until Sept 2030
      // went out as 0930, was read as year 09, and was refused as expired.
      expect(expiryToYyMm('09/30'), '3009');
    });

    test('accepts bare digits as typed', () {
      expect(expiryToYyMm('0930'), '3009');
    });

    test('is not a no-op — MMYY and YYMM must differ where they can', () {
      expect(expiryToYyMm('03/30'), '3003');
      expect(expiryToYyMm('12/25'), '2512');
    });

    test('refuses an incomplete expiry rather than sending half of one', () {
      expect(expiryToYyMm('09/'), '');
      expect(expiryToYyMm('9'), '');
      expect(expiryToYyMm(''), '');
      expect(expiryToYyMm('09/300'), '');
    });
  });

  group('SavedCard.expiryDisplay', () {
    test('un-swaps the stored YYMM back to MM/YY for the user', () {
      // Round trip: what the user typed must be what the user sees.
      const typed = '09/30';
      final card = SavedCard(id: 'x', expireDate: expiryToYyMm(typed));
      expect(card.expiryDisplay, typed);
    });

    test('is empty rather than wrong when the value is unusable', () {
      expect(const SavedCard(id: 'x', expireDate: null).expiryDisplay, '');
      expect(const SavedCard(id: 'x', expireDate: '30').expiryDisplay, '');
    });
  });

  group('SavedCard.label', () {
    test('falls back to brand and last four — this rail sends no owner', () {
      const card = SavedCard(
        id: 'x',
        maskedNumber: '561468******2451',
        vendor: 'Uzcard',
      );
      expect(card.label, 'Uzcard •••• 2451');
    });

    test('prefers the name the user gave the card', () {
      const card = SavedCard(
        id: 'x',
        maskedNumber: '561468******2451',
        vendor: 'Uzcard',
        cardName: 'Ish kartasi',
      );
      expect(card.label, 'Ish kartasi');
    });
  });
}

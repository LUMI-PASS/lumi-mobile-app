import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/extensions/number_extensions.dart';

/// `int.grouped` — the thousands separator every count in the app goes
/// through. Three widgets used to carry a private copy of this between them
/// (the search results count row, the search tab's shortcut cards and its
/// category cards); they all read this one now, so it is worth its own test.
void main() {
  test('separates thousands and leaves small numbers alone', () {
    expect(0.grouped, '0');
    expect(7.grouped, '7');
    expect(70.grouped, '70');
    expect(999.grouped, '999');
    expect(1000.grouped, '1 000');
    expect(15751.grouped, '15 751');
    expect(1234567.grouped, '1 234 567');
  });

  test('matches the price formatter it shares its maths with', () {
    for (final value in [0, 70, 999, 1000, 15751, 1234567]) {
      expect(value.grouped, value.price, reason: '$value');
    }
  });
}

import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/promo/promo_ineligible_reason.dart';

/// Every refusal the packet can give must have a real sentence in all three
/// languages.
///
/// These keys are the one set the app never writes literally: they are built
/// from the enum (`reason.messageKey`), so a grep for `'key'.tr()` misses them
/// and a missing row goes unnoticed until a parent is shown the raw string
/// `aksiya_why_too_many_tickets` at the moment their booking was refused. That
/// is the worst possible place to find out, which is why it is a test.
///
/// Reads the CSV that actually ships (`assets/localization/translations.csv`),
/// not a fixture — the point is to check the shipped file.
void main() {
  late Map<String, List<String>> translations;

  setUpAll(() {
    final raw = File('assets/localization/translations.csv').readAsStringSync();
    final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false)
        .convert(raw);
    translations = {
      for (final row in rows)
        if (row.isNotEmpty)
          row.first.toString(): row.skip(1).map((c) => c.toString()).toList(),
    };
  });

  test('the CSV parses and has the four expected columns', () {
    // str,ru_RU,uz_UZ,en_EN — if the header ever changes, the index maths below
    // is wrong and every other assertion here is meaningless.
    expect(translations['str'], ['ru_RU', 'uz_UZ', 'en_EN']);
  });

  test('every refusal reason has a message in ru, uz and en', () {
    final problems = <String>[];
    for (final reason in PromoIneligibleReason.values) {
      final key = reason.messageKey;
      final row = translations[key];
      if (row == null) {
        problems.add('$key — missing from translations.csv');
        continue;
      }
      if (row.length < 3) {
        problems.add('$key — only ${row.length} language column(s)');
        continue;
      }
      for (var i = 0; i < 3; i++) {
        if (row[i].trim().isEmpty) {
          problems.add('$key — blank ${const ['ru', 'uz', 'en'][i]}');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('no two reasons share a message key', () {
    // Two rules collapsing onto one sentence means one of them can never be
    // explained — and the duplicate is invisible at the call site.
    final keys = PromoIneligibleReason.values.map((r) => r.messageKey).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('the unknown fallback resolves to a real sentence too', () {
    // The case a newer server triggers. It must never be the one that prints a
    // raw key, because it is the one nobody tested against a live backend.
    final row = translations[PromoIneligibleReason.unknown.messageKey];
    expect(row, isNotNull);
    expect(row!.take(3).every((c) => c.trim().isNotEmpty), isTrue);
  });
}

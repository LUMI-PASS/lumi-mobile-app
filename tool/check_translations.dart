// Checks assets/localization/translations.csv — the app's only source of UI
// text — against itself and against the code that reads it.
//
//   dart run tool/check_translations.dart            # errors + warnings
//   dart run tool/check_translations.dart --unused   # also list unused keys
//
// Exits 1 when there is an error, so it can gate a commit or CI.
//
// ERRORS are things a user sees broken: a raw key on screen, a missing
// language, a placeholder that never gets filled. WARNINGS are likely
// inconsistencies worth a human look; some are deliberate (a brand name is
// the same in every language).
//
// Mirrors how the app loads the file (lib/.../fixed_csv_parser.dart): the
// `csv` package with default settings, '\n' line ends, and a plain map where a
// repeated key silently takes the LAST row's text.

import 'dart:io';

import 'package:csv/csv.dart';

const csvPath = 'assets/localization/translations.csv';
const stringsPath = 'lib/common/gen/strings.g.dart';

/// Cells left empty on purpose. A "prefix <link> suffix" sentence needs words
/// after the link only in Uzbek, where the verb comes last.
const allowEmpty = {
  'oferta_agree_suffix',
  'confirm_code_sent_suffix',
};

final cyrillic = RegExp(r'[Ѐ-ӿ]');
final latin = RegExp(r'[A-Za-z]');
final positional = RegExp(r'\{\}');
final named = RegExp(r'\{(\w+)\}');

/// `'key'.tr(` / `"key".tr(` / `.plural(` on a literal.
final literalTr = RegExp(r'''['"]([a-zA-Z0-9_]+)['"]\s*\.\s*(?:tr|plural)\(''');

/// `'prefix_$x'.tr(` / `'prefix_${x}'.tr(` — a key built at runtime.
final dynamicTr =
    RegExp(r'''['"]([a-zA-Z0-9_]*)\$\{?[^'"]*['"]\s*\.\s*(?:tr|plural)\(''');

/// `static String get name => 'key'.tr(` in strings.g.dart.
final getter =
    RegExp(r'''get\s+(\w+)\s*=>\s*['"]([a-zA-Z0-9_]+)['"]\s*\.tr\(''');

/// Any quoted snake_case literal — a key may sit in an enum or a map and be
/// translated through a variable.
final anyLiteral = RegExp(r'''['"]([a-z][a-z0-9]*(?:_[a-z0-9]+)+)['"]''');

final errors = <String>[];
final warnings = <String, List<String>>{};

void error(String msg) => errors.add(msg);
void warn(String group, String msg) =>
    (warnings[group] ??= <String>[]).add(msg);

void main(List<String> args) {
  final showUnused = args.contains('--unused');
  final text = File(csvPath).readAsStringSync();
  final rows = const CsvToListConverter().convert(text, eol: '\n');
  final raw = const CsvToListConverter(shouldParseNumbers: false)
      .convert(text, eol: '\n');

  final header = raw.first.map((e) => '$e').toList();
  final langs = header.sublist(1);
  final width = header.length;

  // ---- the file itself --------------------------------------------------
  final byKey = <String, List<int>>{}; // key -> csv line numbers (1-based)
  final values = <String, List<String>>{}; // key -> last row's cells

  for (var i = 1; i < raw.length; i++) {
    final line = i + 1;
    final row = raw[i].map((e) => '$e').toList();
    if (row.length == 1 && row.first.trim().isEmpty) continue; // blank line
    if (row.length != width) {
      error('line $line: ${row.length} columns, header has $width '
          '(${row.first})');
      continue;
    }
    final key = row.first;
    if (key.trim().isEmpty) {
      error('line $line: empty key');
      continue;
    }
    if (key != key.trim()) error('line $line: key "$key" has spaces around it');
    if (key.contains('.')) {
      warn('key contains "." (easy_localization may read it as nested)',
          '$key (line $line)');
    }
    (byKey[key] ??= []).add(line);
    values[key] = row.sublist(1);

    // The app's parser turns an unquoted number into an int, not a String.
    final parsed = rows[i];
    for (var c = 1; c < parsed.length && c < width; c++) {
      if (parsed[c] is! String) {
        error('line $line: $key [${langs[c - 1]}] is parsed as a number '
            '(${parsed[c]}) — quote it');
      }
    }

    for (var c = 0; c < langs.length; c++) {
      final v = row[c + 1];
      final lang = langs[c];
      if (v.trim().isEmpty) {
        if (allowEmpty.contains(key)) continue;
        error('line $line: $key has no $lang text');
        continue;
      }
      if (v != v.trim() &&
          !allowEmpty.contains(key) &&
          !key.endsWith('_prefix')) {
        warn('leading/trailing whitespace', '$key [$lang] (line $line)');
      }
      if (v.contains('  ')) warn('double space', '$key [$lang] (line $line)');
      if (lang.startsWith('ru') && latin.hasMatch(v) && !cyrillic.hasMatch(v)) {
        warn('ru text has no Cyrillic (untranslated?)', '$key: "$v"');
      }
      if (!lang.startsWith('ru') && cyrillic.hasMatch(v)) {
        warn('$lang text contains Cyrillic', '$key: "$v"');
      }
    }

    // Placeholders must match across languages, or an argument is dropped
    // (or a literal "{}" shows) in one of them.
    final counts = [
      for (final v in row.sublist(1)) positional.allMatches(v).length
    ];
    final names = [
      for (final v in row.sublist(1))
        (named.allMatches(v).map((m) => m.group(1)!).toList()..sort()).join(',')
    ];
    if (counts.toSet().length > 1) {
      error('line $line: $key has a different number of {} per language '
          '(${[
        for (var c = 0; c < langs.length; c++) '${langs[c]}=${counts[c]}'
      ].join(' ')})');
    }
    if (names.toSet().length > 1) {
      error('line $line: $key has different named placeholders per language '
          '(${[
        for (var c = 0; c < langs.length; c++) '${langs[c]}={${names[c]}}'
      ].join(' ')})');
    }

    // Sentence-ending punctuation that differs between languages.
    String end(String v) {
      final t = v.trimRight();
      if (t.isEmpty) return '';
      final ch = t[t.length - 1];
      // "5 шт.", "3 дн." — a Russian abbreviation, not a sentence's end.
      if (ch == '.' && RegExp(r'(^|[\s\d])(шт|дн|мин|сек|ч|мес|г|тыс|млн)\.$').hasMatch(t)) return '';
      return '.?!:'.contains(ch) ? ch : '';
    }

    final ends = row.sublist(1).map(end).toSet();
    if (ends.length > 1) {
      warn(
          'ending punctuation differs between languages',
          '$key: ${[
            for (var c = 0; c < langs.length; c++)
              '${langs[c]}="${end(row[c + 1])}"'
          ].join(' ')}');
    }

    // Uzbek: o‘/g‘ written with more than one apostrophe in the same text.
    final uzIndex = langs.indexWhere((l) => l.startsWith('uz'));
    if (uzIndex >= 0) {
      final uz = row[uzIndex + 1];
      final marks = RegExp(r"[oOgG]([''‘’ʻ`])")
          .allMatches(uz)
          .map((m) => m.group(1))
          .toSet();
      if (marks.length > 1) {
        warn('uz mixes apostrophe styles in one text', '$key: "$uz"');
      }
    }
  }

  for (final e in byKey.entries.where((e) => e.value.length > 1)) {
    error('duplicate key ${e.key} on lines ${e.value.join(', ')} — '
        'the app uses the LAST one');
  }

  // ---- the code that reads it -------------------------------------------
  final strings = File(stringsPath).readAsStringSync();
  final getters = {
    for (final m in getter.allMatches(strings)) m.group(1)!: m.group(2)!
  };

  final used = <String, String>{}; // key -> first file that uses it
  final literals = <String>{};
  final prefixes = <String>{};
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));
  for (final f in sources) {
    final src = f.readAsStringSync();
    for (final m in literalTr.allMatches(src)) {
      used.putIfAbsent(m.group(1)!, () => f.path);
    }
    for (final m in dynamicTr.allMatches(src)) {
      if (m.group(1)!.isNotEmpty) prefixes.add(m.group(1)!);
    }
    for (final m in anyLiteral.allMatches(src)) {
      literals.add(m.group(1)!);
    }
    for (final g in getters.entries) {
      if (src.contains(RegExp('Strings\\.${g.key}\\b'))) {
        used.putIfAbsent(g.value, () => '${f.path} (Strings.${g.key})');
      }
    }
  }

  for (final e in used.entries) {
    if (!values.containsKey(e.key)) {
      error('key "${e.key}" is used in ${e.value} but missing from the CSV');
    }
  }
  for (final p in prefixes) {
    if (!values.keys.any((k) => k.startsWith(p))) {
      warn('runtime-built key prefix matches no key', '"$p…"');
    }
  }
  final deadGetters = [
    for (final g in getters.entries)
      if (!values.containsKey(g.value) && !used.containsKey(g.value))
        'Strings.${g.key} -> ${g.value}'
  ];

  final unused = values.keys
      .where((k) =>
          !used.containsKey(k) &&
          !literals.contains(k) &&
          !prefixes.any(k.startsWith))
      .toList()
    ..sort();

  // ---- report -----------------------------------------------------------
  stdout.writeln(
      '$csvPath: ${values.length} keys, languages ${langs.join(', ')}');
  stdout.writeln('${used.length} keys referenced directly, '
      '${prefixes.length} runtime-built prefixes\n');

  if (errors.isEmpty) {
    stdout.writeln('ERRORS: none');
  } else {
    stdout.writeln('ERRORS (${errors.length}):');
    for (final e in errors) {
      stdout.writeln('  ✗ $e');
    }
  }
  for (final g in warnings.entries) {
    stdout.writeln('\nWARNING — ${g.key} (${g.value.length}):');
    for (final w in g.value) {
      stdout.writeln('  • $w');
    }
  }
  stdout.writeln('\nStrings getters that nothing uses and whose key is gone '
      '(dead code in $stringsPath): ${deadGetters.length}'
      '${showUnused ? '' : ' — pass --unused to list'}');
  if (showUnused) {
    for (final g in deadGetters) {
      stdout.writeln('  - $g');
    }
  }
  stdout.writeln('\nNot referenced anywhere in lib/ (may be dead, or built at '
      'runtime in a way this script cannot see): ${unused.length}'
      '${showUnused ? '' : ' — pass --unused to list'}');
  if (showUnused) {
    for (final k in unused) {
      stdout.writeln('  - $k');
    }
  }
  exitCode = errors.isEmpty ? 0 : 1;
}

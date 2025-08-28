import 'package:csv/csv.dart';

class FixedCsvParser {
  final String csvString;
  final List<List<dynamic>> lines;
  final String? fieldDelimiter;

  FixedCsvParser(
      this.csvString, {
        this.fieldDelimiter = ',',
      }) : lines = const CsvToListConverter().convert(
    csvString,
    fieldDelimiter: fieldDelimiter,
    eol: '\n'
  );

  List getLanguages() {
    return lines.first.sublist(1, lines.first.length);
  }

  Map<String, dynamic> getLanguageMap(String localeName) {
    final indexLocale = lines.first.indexOf(localeName);

    var translations = <String, dynamic>{};
    for (var i = 1; i < lines.length; i++) {
      translations.addAll({lines[i][0]: lines[i][indexLocale]});
    }
    return translations;
  }
}
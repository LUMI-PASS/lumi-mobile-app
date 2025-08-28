import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fixed_csv_parser.dart';

class FixedCsvAssetLoader extends AssetLoader {
  FixedCsvParser? fixedCsvParser;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    fixedCsvParser ??= FixedCsvParser(await rootBundle.loadString(path));
    return fixedCsvParser!.getLanguageMap(locale.toString());
  }
}
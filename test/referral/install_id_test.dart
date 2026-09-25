import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/storage/install_id.dart';

void main() {
  test('an install id is 32 lowercase hex characters', () {
    final id = generateInstallId(Random(1));
    expect(id, matches(RegExp(r'^[0-9a-f]{32}$')));
  });

  test('two installs get different ids', () {
    expect(generateInstallId(), isNot(generateInstallId()));
  });
}

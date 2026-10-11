import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/common/utils/sale_label.dart';

void main() {
  const names = ['', 'Du', 'Se', 'Cho', 'Pa', 'Ju', 'Sha', 'Ya'];
  String short(int d) => names[d];

  group('foldWeekdays', () {
    test('a working week folds into a range', () {
      expect(foldWeekdays([1, 2, 3, 4, 5], short), 'Du–Ju');
    });

    test('Sunday is last, so a full week runs Monday to Sunday', () {
      expect(foldWeekdays([0, 1, 2, 3, 4, 5, 6], short), 'Du–Ya');
      expect(foldWeekdays([5, 6, 0], short), 'Ju–Ya');
    });

    test('days that do not touch are listed, in week order', () {
      expect(foldWeekdays([5, 1, 3], short), 'Du, Cho, Ju');
    });

    test('two days are listed, not made into a range', () {
      expect(foldWeekdays([6, 0], short), 'Sha, Ya');
    });

    test('nothing in, nothing out', () {
      expect(foldWeekdays([], short), '');
    });
  });
}

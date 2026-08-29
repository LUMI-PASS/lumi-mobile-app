import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';

void main() {
  group('CourseLevel group age tiers', () {
    test('parses multiple tiers on a named group', () {
      final level = CourseLevel.fromJson({
        'id': 'group-1',
        'name': 'Group 1',
        'order': 1,
        'trial': <String, dynamic>{},
        'course': {
          'price': 500000,
          'price_max': 800000,
          'has_multiple_price_tiers': true,
          'age_tiers': [
            {'age_from': 5, 'age_to': 9, 'price': 500000},
            {'age_from': 10, 'age_to': null, 'price': 800000},
          ],
        },
        'can_buy_trial': false,
        'can_buy_full': true,
      });

      expect(level.id, 'group-1');
      expect(level.hasMultiplePriceTiers, isTrue);
      expect(level.coursePrice, 500000);
      expect(level.priceMax, 800000);
      expect(level.ageTiers, hasLength(2));
      expect(level.ageTiers.first.rangeLabel, '5-9');
      expect(level.ageTiers.last.rangeLabel, '10+');
    });
  });
}

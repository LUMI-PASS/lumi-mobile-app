import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/domain/repo/courses/courses_api.dart';
import 'package:lumi_pass/presentation/app/home/course_detail/course_purchase.dart';

void main() {
  const tiers = [
    CourseAgeTier(ageFrom: 5, ageTo: 9, price: 500000),
    CourseAgeTier(ageFrom: 10, ageTo: null, price: 800000),
  ];

  group('courseNeedsAgeTierChoice', () {
    test('shows for multiple tiers on a named group', () {
      expect(
        courseNeedsAgeTierChoice(isTrial: false, ageTiers: tiers),
        isTrue,
      );
    });

    test('stays hidden for trials and single-price groups', () {
      expect(
        courseNeedsAgeTierChoice(isTrial: true, ageTiers: tiers),
        isFalse,
      );
      expect(
        courseNeedsAgeTierChoice(
          isTrial: false,
          ageTiers: [tiers.first],
        ),
        isFalse,
      );
    });
  });
}

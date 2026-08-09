import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';

/// Activities and courses share one search list, and narrowing to one of them
/// is a filter over that list. These pin the two things that would break
/// quietly: what each choice sends on the wire, and whether the screen admits a
/// filter is on.
void main() {
  group('what the type filter sends', () {
    test('both kinds asks for "all", not for the endpoint default', () {
      // The endpoint's own default is activities only — that is what an older
      // client gets by sending nothing. The search screen wants both, so it has
      // to say so explicitly rather than rely on the default.
      expect(ActivityKind.any.queryValue, 'all');
    });

    test('narrowing to courses names itself', () {
      expect(ActivityKind.courses.queryValue, 'courses');
    });

    test('offers exactly two choices — everything, or courses', () {
      // No "activities only": excluding courses is not something a parent asks
      // for, and a chip for it would only hide things from people who didn't.
      expect(ActivityKind.values, [ActivityKind.any, ActivityKind.courses]);
    });
  });

  group('the filter itself', () {
    test('defaults to both, so search opens on everything', () {
      expect(const FilterResult().kind, ActivityKind.any);
    });

    test('survives copyWith untouched when something else changes', () {
      const filter = FilterResult(kind: ActivityKind.courses);
      expect(filter.copyWith(ageYears: 5).kind, ActivityKind.courses);
    });

    test('can be narrowed and widened again', () {
      const filter = FilterResult(kind: ActivityKind.courses);
      expect(filter.copyWith(kind: ActivityKind.any).kind, ActivityKind.any);
    });
  });
}

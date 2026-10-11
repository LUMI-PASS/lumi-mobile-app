import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/unclaimed_centre/unclaimed_centre.dart';

void main() {
  group('UnclaimedCentre.fromJson', () {
    test('a card parses with the details left empty', () {
      final centre = UnclaimedCentre.fromJson({
        'id': 'c1',
        'name': 'Bilim',
        'kind': 'sports',
        'image': 'https://mobile-api.lumipass.uz/uploads/a.jpg',
        'latitude': 41.31,
        'longitude': 69.28,
        'price_from': 450000,
        'price_period': 'month',
        'activity_names': ['Futbol', '', 'Suzish'],
        'activities_count': 5,
        'is_claimed': false,
      });
      expect(centre.centreKind, UnclaimedKind.sports);
      expect(centre.period, UnclaimedPricePeriod.month);
      expect(centre.activityNames, ['Futbol', 'Suzish']);
      expect(centre.gallery, ['https://mobile-api.lumipass.uz/uploads/a.jpg']);
      expect(centre.activities, isEmpty);
      expect(centre.phones, isEmpty);
    });

    test('nulls and vocabulary this build has not heard of do not throw', () {
      final centre = UnclaimedCentre.fromJson({
        'id': 'c2',
        'name': null,
        'kind': 'aquapark',
        'price_period': 'decade',
        'socials': {'instagram': null, 'website': ' lumi.uz '},
        'work_hours': [
          {'day': 'mon', 'start_time': '09:00', 'end_time': '18:00'},
          {'day': 'someday', 'start_time': '1', 'end_time': '2'},
          'nonsense',
        ],
        'activities': [
          {'id': 'a', 'name': 'Rasm', 'is_verified': true},
          {'id': 'b', 'name': ''},
        ],
        'images': null,
      });
      expect(centre.centreKind, UnclaimedKind.unknown);
      expect(centre.period, UnclaimedPricePeriod.unknown);
      expect(centre.socials, {'website': 'lumi.uz'});
      expect(centre.workHours.map((h) => h.weekday), [1, 0]);
      expect(centre.activities.single.isVerified, isTrue);
      expect(centre.gallery, isEmpty);
    });
  });
}

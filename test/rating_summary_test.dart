import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_pass/data/api_model/class_full/class_full_model.dart';

void main() {
  group('RatingSummary.fromJson', () {
    test('reads the average, the count and the viewer\'s own stars', () {
      final rating = RatingSummary.fromJson(
        {'rating_avg': 4.7, 'rating_count': 12, 'viewer_rating': 5},
      );
      expect(rating.average, 4.7);
      expect(rating.count, 12);
      expect(rating.viewerRating, 5);
      expect(rating.hasRatings, isTrue);
    });

    test('an older payload with no rating fields is simply unrated', () {
      final rating = RatingSummary.fromJson(const {'_id': 'abc'});
      expect(rating.average, 0);
      expect(rating.count, 0);
      expect(rating.viewerRating, isNull);
      expect(rating.hasRatings, isFalse);
    });

    test('carries the viewer\'s own comment', () {
      final rating = RatingSummary.fromJson(
        {'rating_avg': 4, 'rating_count': 1, 'viewer_comment': 'Great coach'},
      );
      expect(rating.viewerComment, 'Great coach');
    });

    test('a whole-number average arrives as an int and still parses', () {
      final rating = RatingSummary.fromJson(
        {'rating_avg': 5, 'rating_count': 1, 'viewer_rating': null},
      );
      expect(rating.average, 5.0);
      expect(rating.viewerRating, isNull);
    });
  });

  group('ActivityReviewPage.fromJson', () {
    test('reads the reviews and the total', () {
      final page = ActivityReviewPage.fromJson({
        'data': [
          {
            'id': 'r1',
            'rating': 5,
            'comment': 'Great coach',
            'date': '2026-10-01T10:00:00.000Z',
            'author_name': 'Aziza',
            'author_avatar': null,
          },
        ],
        'total': 7,
      });
      expect(page.total, 7);
      expect(page.reviews.single.rating, 5);
      expect(page.reviews.single.comment, 'Great coach');
      expect(page.reviews.single.authorName, 'Aziza');
      expect(page.reviews.single.date, isNotNull);
    });

    test('a malformed row or a missing list never throws', () {
      expect(ActivityReviewPage.fromJson(const {}).reviews, isEmpty);
      final page = ActivityReviewPage.fromJson({
        'data': [
          'junk',
          {'rating': null, 'date': 'not-a-date'},
        ],
      });
      expect(page.reviews.single.rating, 0);
      expect(page.reviews.single.date, isNull);
    });
  });
}

import 'package:lumi_pass/feature/home/data/model/afisha/afisha_data.dart';
import 'package:lumi_pass/feature/home/data/model/book/book_data.dart';
import 'package:lumi_pass/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:lumi_pass/feature/home/data/model/live_stream/live_stream_data.dart';
import 'package:lumi_pass/feature/home/data/model/news/news_data.dart';
import 'package:lumi_pass/feature/home/data/model/notification/notification_data.dart';
import 'package:lumi_pass/feature/home/data/model/review_matches/review_matches_data.dart';

abstract interface class BaseHomeRepository {
  Future<dynamic> getAfishas({int page, int count});

  Future<AfishaData?> getAfishaById({required String id});

  Future<dynamic> getNews({int page, int count});

  Future<dynamic> getGrandmasters({int page, int count});

  Future<GrandmasterData?> getGrandmasterById({required String id});

  Future<dynamic> getReviewMatches({int page, int count});

  Future<dynamic> getBooks({int page, int count});

  Future<ReviewMatchData?> getReviewMatchById({required String id});

  Future<BookData?> getBookById({required String id});

  Future<NewsData?> getNewsById({required String id});

  Future<LiveStreamData?> getActiveLiveStream();

  Future<LiveStreamData?> getLiveStreamById({required String id});

  Future<dynamic> getNotifications({int page});

  Future<NotificationData?> readNotification({required String id});

  Future<void> registerForTournament({
    required String id,
    required Map<String, dynamic> body,
  });
}

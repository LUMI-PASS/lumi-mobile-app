import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/feature/home/data/data_source/remote_data_source/home_api_client.dart';
import 'package:founders_academy/feature/home/data/model/afisha/afisha_data.dart';
import 'package:founders_academy/feature/home/data/model/book/book_data.dart';
import 'package:founders_academy/feature/home/data/model/grandmaster/grandmaster_data.dart';
import 'package:founders_academy/feature/home/data/model/live_stream/live_stream_data.dart';
import 'package:founders_academy/feature/home/data/model/news/news_data.dart';
import 'package:founders_academy/feature/home/data/model/notification/notification_data.dart';
import 'package:founders_academy/feature/home/data/model/review_matches/review_matches_data.dart';
import 'package:founders_academy/feature/home/domain/repository/base_home_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: BaseHomeRepository)
class HomeRepository implements BaseHomeRepository {
  final HomeApiClient _homeApiClient;

  HomeRepository(this._homeApiClient);

  @override
  Future<dynamic> getAfishas({int? page, int? count}) async {
    try {
      final response = await _homeApiClient.getAfisha(page: page ?? 1);
      final afishasResponse = response.result;
      if (page != null) {
        return afishasResponse;
      } else {
        final afishas = afishasResponse.afishas;
        return count != null ? afishas?.take(count).toList() : afishas;
      }
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<AfishaData?> getAfishaById({required String id}) async {
    try {
      final response = await _homeApiClient.getAfishaById(id);

      return response.result.afishas;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<dynamic> getNews({int? page, int? count}) async {
    try {
      final response = await _homeApiClient.getNews(page: page ?? 1);
      final newsResponse = response.result;
      if (page != null) {
        return newsResponse;
      } else {
        final news = newsResponse.news;
        return count != null ? news?.take(count).toList() : news;
      }
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<dynamic> getGrandmasters({int? page, int? count}) async {
    try {
      final response = await _homeApiClient.getGrandmasters(page: page ?? 1);
      final grandmastersResponse = response.result;
      if (page != null) {
        return grandmastersResponse;
      } else {
        final grandmasters = grandmastersResponse.grandmasters;
        return count != null
            ? grandmasters?.take(count).toList()
            : grandmasters;
      }
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<GrandmasterData?> getGrandmasterById({required String id}) async {
    try {
      final response = await _homeApiClient.getGrandmasterById(id);

      return response.result.grandmaster;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<dynamic> getReviewMatches({int? page, int? count}) async {
    try {
      final response = await _homeApiClient.getReviewMatches(page: page ?? 1);
      final reviewMatchesResponse = response.result;

      if (page != null) {
        return reviewMatchesResponse;
      } else {
        final reviewMatches = reviewMatchesResponse.reviewMatches;
        return count != null
            ? reviewMatches?.take(count).toList()
            : reviewMatches;
      }
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<dynamic> getBooks({int? page, int? count}) async {
    try {
      final response = await _homeApiClient.getBooks(page: page ?? 1);
      final booksResponse = response.result;
      if (page != null) {
        return booksResponse;
      } else {
        final books = booksResponse.books;
        return count != null ? books?.take(count).toList() : books;
      }
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<ReviewMatchData?> getReviewMatchById({required String id}) async {
    try {
      final response = await _homeApiClient.getReviewMatchById(id);

      return response.result.reviewMatches;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<BookData?> getBookById({required String id}) async {
    try {
      final response = await _homeApiClient.getBookById(id);

      return response.result.book;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<NewsData?> getNewsById({required String id}) async {
    try {
      final response = await _homeApiClient.getNewsById(id);

      return response.result.news;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<LiveStreamData?> getActiveLiveStream() async {
    try {
      final response = await _homeApiClient.getActiveLiveStream();

      return response.result.liveStream;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<LiveStreamData?> getLiveStreamById({required String id}) async {
    try {
      final response = await _homeApiClient.getLiveStreamById(id);

      return response.result.liveStream;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<dynamic> getNotifications({int? page}) async {
    try {
      final response = await _homeApiClient.getNotifications(page: page ?? 1);
      final notificationResponse = response.result;
      if (page != null) {
        return notificationResponse;
      } else {
        final notificationList = notificationResponse.notificationList;
        return notificationList;
      }
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<NotificationData?> readNotification({required String id}) async {
    try {
      final response = await _homeApiClient.readNotification(id: id);

      return response.result.notificationData;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<void> registerForTournament({
    required String id,
    required Map<String, dynamic> body,
  }) async {
    try {
      await _homeApiClient.registerForTournament(id: id, body: body);
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }
}

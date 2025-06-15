import 'package:founders_academy/core/api/api_response.dart';
import 'package:founders_academy/di/module/api_client_module.dart';
import 'package:founders_academy/feature/home/data/model/afisha/afisha_response.dart';
import 'package:founders_academy/feature/home/data/model/book/books_response.dart';
import 'package:founders_academy/feature/home/data/model/grandmaster/grandmasters_response.dart';
import 'package:founders_academy/feature/home/data/model/live_stream/live_stream_response.dart';
import 'package:founders_academy/feature/home/data/model/news/news_response.dart';
import 'package:founders_academy/feature/home/data/model/notification/notification_response.dart';
import 'package:founders_academy/feature/home/data/model/review_matches/review_matches_response.dart';
import 'package:founders_academy/feature/shared/data/model/push_notification_subscribe_request_model.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'home_api_client.g.dart';

@injectable
@RestApi()
abstract class HomeApiClient {
  @factoryMethod
  factory HomeApiClient(@authorizedApiClient Dio dio) = _HomeApiClient;

  @GET('/api/tournaments')
  Future<ApiResponse<AfishaResponse>> getAfisha({
    @Query('page') required int page,
  });

  @GET('/api/tournaments/{id}')
  Future<ApiResponse<AfishaItemResponse>> getAfishaById(
    @Path('id') String id,
  );

  @GET('/api/news')
  Future<ApiResponse<NewsResponse>> getNews({
    @Query('page') required int page,
  });

  @GET('/api/news/{id}')
  Future<ApiResponse<NewsItemResponse>> getNewsById(
    @Path('id') String id,
  );

  @GET('/api/grandmasters')
  Future<ApiResponse<GrandmastersResponse>> getGrandmasters({
    @Query('page') required int page,
  });

  @GET('/api/grandmasters/{id}')
  Future<ApiResponse<GrandmasterResponse>> getGrandmasterById(
    @Path('id') String id,
  );

  @GET('/api/reviews')
  Future<ApiResponse<ReviewMatchesResponse>> getReviewMatches({
    @Query('page') required int page,
  });

  @GET('/api/reviews/{id}')
  Future<ApiResponse<ReviewMatchResponse>> getReviewMatchById(
    @Path('id') String id,
  );

  @GET('/api/books')
  Future<ApiResponse<BooksResponse>> getBooks({
    @Query('page') required int page,
  });

  @GET('/api/books/{id}')
  Future<ApiResponse<BookResponse>> getBookById(
    @Path('id') String id,
  );

  @GET('/api/live-streams/active')
  Future<ApiResponse<LiveStreamResponse>> getActiveLiveStream();

  @GET('/api/live-streams/{id}')
  Future<ApiResponse<LiveStreamResponse>> getLiveStreamById(
    @Path('id') String id,
  );

  @GET('/api/notification')
  Future<ApiResponse<NotificationResponse>> getNotifications({
    @Query('page') required int page,
  });

  @POST('/api/notification/{id}/read')
  Future<ApiResponse<NotificationItemResponse>> readNotification({
    @Path('id') required String id,
  });

  @POST('/api/notification/subscribe')
  Future<void> subscribe(
    @Body() PushNotificationSubscribeRequestModel token,
  );

  @POST('/api/tournaments/{id}/tournament-register')
  Future<ApiResponse> registerForTournament({
    @Path('id') required String id,
    @Body() required Map<String, dynamic> body,
  });
}

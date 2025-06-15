import 'package:lumi_pass/di/module/api_client_module.dart';
import 'package:lumi_pass/feature/profile/data/model/leaderboard/leaderboards_response.dart';
import 'package:lumi_pass/feature/profile/data/model/my_certificate/my_certificate_response.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_data.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_delete/profile_delete_data.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_delete/profile_delete_reason_data.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_image/profile_image_data.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';

part 'profile_api_client.g.dart';

@injectable
@RestApi()
abstract class ProfileApiClient {
  @factoryMethod
  factory ProfileApiClient(@authorizedApiClient Dio dio) = _ProfileApiClient;

  @GET('/api/profile')
  Future<ProfileData?> getUser();

  @GET('/api/courses/certificates/my')
  Future<MyCertificateResponse?> getMyCertificate();

  @PUT('/api/profile')
  Future<ProfileData?> updateProfile(
    @Body() ProfileData profileData,
  );

  @POST('/api/profile')
  Future<ProfileData?> createUser(
    @Body() ProfileData userData,
  );

  @POST('/api/upload')
  @MultiPart()
  Future<ProfileImageData?> uploadImage(
    @Body() FormData data,
  );

  @GET('/api/profile/leaderboard/new')
  Future<LeaderboardResponse> getLeaderboardData(
    @Query('period') String period,
  );

  @DELETE('/api/profile/delete')
  Future<ProfileDeleteResponse> profileDelete(
    @Body() ProfileDeleteReasonData profileDeleteReasonData,
  );
}

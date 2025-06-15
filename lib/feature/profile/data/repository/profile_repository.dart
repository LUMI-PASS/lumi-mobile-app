import 'dart:io';

import 'package:founders_academy/core/error/chess_exception.dart';
import 'package:founders_academy/core/logging/logger.dart';
import 'package:founders_academy/feature/courses/data/data_source/local_data_source/lesson_completion_database.dart';
import 'package:founders_academy/feature/profile/data/data_source/profile_api_client.dart';
import 'package:founders_academy/feature/profile/data/model/leaderboard/leaderboards_response.dart';
import 'package:founders_academy/feature/profile/data/model/my_certificate/my_certificate_response.dart';
import 'package:founders_academy/feature/profile/data/model/profile_data.dart';
import 'package:founders_academy/feature/profile/data/model/profile_delete/profile_delete_data.dart';
import 'package:founders_academy/feature/profile/data/model/profile_delete/profile_delete_reason_data.dart';
import 'package:founders_academy/feature/profile/data/model/profile_image/profile_image_data.dart';
import 'package:founders_academy/feature/profile/domain/repository/base_profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:injectable/injectable.dart';
import 'package:isar/isar.dart';

@Injectable(as: BaseProfileRepository)
class ProfileRepository implements BaseProfileRepository {
  final ProfileApiClient _profileApiClient;
  final LessonCompletionDatabase _lessonCompletionDatabase;

  ProfileRepository(
    this._profileApiClient,
    this._lessonCompletionDatabase,
  );

  @override
  Future<ProfileData?> getProfile() async {
    try {
      final response = await _profileApiClient.getUser();

      return response;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<ProfileData?> updateProfile(ProfileData profileData) async {
    try {
      final response = await _profileApiClient.updateProfile(profileData);

      return response;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<ProfileData?> createProfile(ProfileData data) async {
    try {
      final response = await _profileApiClient.createUser(data);

      return response;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<ProfileImageData?> updateProfileImage(File file) async {
    try {
      String fileName = file.path.split('/').last;
      var fileExt = fileName.split('.').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: MediaType("image", fileExt),
        ),
      });

      final response = await _profileApiClient.uploadImage(formData);
      return response;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<LeaderboardResponse> getLeaderboardData(
      {required String period}) async {
    try {
      final response = await _profileApiClient.getLeaderboardData(period);
      return response;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<ProfileDeleteResponse> profileDelete(
      ProfileDeleteReasonData profileDeleteReasonData) async {
    try {
      final response =
          await _profileApiClient.profileDelete(profileDeleteReasonData);
      return response;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }

  @override
  Future<void> clearDatabase() async {
    try {
      await _lessonCompletionDatabase.clear();
    } on IsarError catch (exception) {
      throw ChessException.fromIsarException(exception);
    } catch (e) {
      logger.e(e);
      throw NotFoundChessException();
    }
  }

  @override
  Future<MyCertificateResponse?> getMyCertificate() async {
    try {
      final response = await _profileApiClient.getMyCertificate();

      return response;
    } on DioException catch (e) {
      throw ChessException.fromDioException(e);
    }
  }
}

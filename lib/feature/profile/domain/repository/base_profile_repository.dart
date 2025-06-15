import 'dart:io';

import 'package:lumi_pass/feature/profile/data/model/leaderboard/leaderboards_response.dart';
import 'package:lumi_pass/feature/profile/data/model/my_certificate/my_certificate_response.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_data.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_delete/profile_delete_data.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_delete/profile_delete_reason_data.dart';
import 'package:lumi_pass/feature/profile/data/model/profile_image/profile_image_data.dart';

abstract interface class BaseProfileRepository {
  Future<ProfileData?> getProfile();

  Future<MyCertificateResponse?> getMyCertificate();

  Future<ProfileData?> createProfile(ProfileData data);

  Future<ProfileData?> updateProfile(ProfileData data);

  Future<ProfileImageData?> updateProfileImage(File data);

  Future<LeaderboardResponse> getLeaderboardData({required String period});

  Future<ProfileDeleteResponse> profileDelete(
      ProfileDeleteReasonData profileDeleteReasonData);

  Future<void> clearDatabase();
}

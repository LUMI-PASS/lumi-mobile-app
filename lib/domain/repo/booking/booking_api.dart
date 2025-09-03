import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

@injectable
class HomeApi {
  final Dio _dio;

  HomeApi(this._dio);

  Future<Response> getHome() {
    return _dio.get('discovery/feed/',
        queryParameters: {'lat': 68.12, 'lng': 68.12322});
  }

  Future<Response> getSchedule() {
    return _dio.get('schedules/parent/');
  }

  Future<Response> getProfileData() {
    return _dio.get('users/parents/profile/');
  }

  Future<Response> getChildren() {
    return _dio.get('users/children/');
  }

  Future<Response> updateProfileData(HomForUser user) {
    return _dio.patch("users/parents/profile",
        queryParameters: {'profile_id': user.id},
        data: user.toJson()..remove("id"));
  }
}

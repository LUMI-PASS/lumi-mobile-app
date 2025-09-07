import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

@injectable
class HomeApi {
  final Dio _dio;

  HomeApi(this._dio);

  Future<Response> getHome() {
    return _dio.get('discovery/feed/',
        queryParameters: {'lat': 68.12, 'lng': 68.12322, 'lang': 'ru'});
  }

  Future<Response> getSchedule() {
    return _dio.get('schedules/parent/', queryParameters: {'lang': 'ru'});
  }

  Future<Response> getProfileData() {
    return _dio.get('users/parents/profile/',  queryParameters: {'lang': 'ru'});
  }

  Future<Response> addChild(ChildModel childModel, String parentId) {
    return _dio.post('users/parents/profile/children',
        queryParameters: {
          'parent_id': parentId,
          'lang': 'ru'
        },
        data: childModel.toJson()..remove("id"));
  }

  Future<Response> updateChild(ChildModel childModel, String parentId) {
    return _dio.post('users/parents/profile/children/${childModel.id}',
        queryParameters: {
          'parent_id': parentId,
          'lang': 'ru'
        },
        data: childModel.toJson()..remove("id"));
  }

  Future<Response> updateChildData() {
    return _dio.get('users/parents/profile/',  queryParameters: {'lang': 'ru'});
  }

  Future<Response> getChildren() {
    return _dio.get('users/children/',  queryParameters: {'lang': 'ru'});
  }
  Future<Response> getTariffs() {
    return _dio.get('tariffs/',  queryParameters: {'lang': 'ru'});
  }

  Future<Response> updateProfileData(HomForUser user) {
    return _dio.patch("users/parents/profile",
        queryParameters: {'profile_id': user.id, 'lang': 'ru'},
        data: user.toJson()..remove("id"));
  }
}

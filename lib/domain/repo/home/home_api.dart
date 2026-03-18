import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';

@injectable
class HomeApi {
  final Dio _dio;

  HomeApi(this._dio);

  Future<Response> getHome({
    int newClassesPage = 1,
    int newClassesLimit = 10,
    int categoryPage = 1,
    int categoryLimit = 10,
    int nearClassPage = 1,
    int nearClassLimit = 10,
    double? lat,
    double? lng,
    String lang = 'ru',
  }) {
    return _dio.get('discovery/feed/', queryParameters: {
      'new_classes_page': newClassesPage,
      'new_classes_limit': newClassesLimit,
      'category_page': categoryPage,
      'category_limit': categoryLimit,
      'near_class_page': nearClassPage,
      'near_class_limit': nearClassLimit,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'lang': lang,
    });
  }

  Future<Response> getSchedule() {
    return _dio.get('schedules/parent/', queryParameters: {'lang': 'ru'});
  }

  Future<Response> getProfileData() {
    return _dio.get('users/parents/profile/', queryParameters: {'lang': 'ru'});
  }

  Future<Response> addChild(ChildModel childModel, String parentId) {
    return _dio.post('users/parents/profile/children',
        queryParameters: {'parent_id': parentId, 'lang': 'ru'},
        data: childModel.toJson()..remove("id"));
  }

  Future<Response> updateChild(ChildModel childModel, String parentId) {
    return _dio.patch('users/parents/profile/children/${childModel.id}',
        queryParameters: {'parent_id': parentId, 'lang': 'ru'},
        data: childModel.toJson());
  }

  Future<Response> updateChildData() {
    return _dio.get('users/parents/profile/', queryParameters: {'lang': 'ru'});
  }

  Future<Response> getChildren() {
    return _dio.get('users/children/', queryParameters: {'lang': 'ru'});
  }

  Future<Response> getTariffs() {
    return _dio.get('tariffs/', queryParameters: {'lang': 'ru'});
  }

  Future<Response> getCategories() {
    return _dio.get('categories/', queryParameters: {'lang': 'ru'});
  }

  Future<Response> getClassCategories(
      String childId, String fromDate, String toDate, String classId) {
    return _dio.get(
        'schedules/class/$classId/check-availability',
        queryParameters: {
          'lang': 'ru',
          'child_id': childId,
          'from_date': fromDate,
          'to_date': toDate,
        });
  }

  Future<Response> purchaseSubscription(String tariffId) {
    return _dio.post('transaction/subscriptions/', queryParameters: {
      'lang': 'ru'
    }, data: {
      'tariff_id': tariffId,
    });
  }

  Future<Response> updateProfileData(HomForUser user) {
    return _dio.patch("users/parents/profile",
        queryParameters: {'profile_id': user.id, 'lang': 'ru'},
        data: user.toJson()..remove("id"));
  }
}

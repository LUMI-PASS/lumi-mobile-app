import 'dart:io' if (dart.library.html) 'package:lumi_pass/common/stubs/io_stub.dart';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
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
      'lang': currentLang,
    });
  }

  Future<Response> getSchedule() {
    return _dio.get('schedules/parent/', queryParameters: {'lang': currentLang});
  }

  Future<Response> getProfileData() {
    return _dio.get('users/parents/profile/', queryParameters: {'lang': currentLang});
  }

  Future<Response> addChild(ChildModel childModel, String parentId) {
    return _dio.post('users/parents/profile/children',
        queryParameters: {'lang': currentLang},
        data: _childWritePayload(childModel));
  }

  Future<Response> updateChild(ChildModel childModel, String parentId) {
    return _dio.patch('users/parents/profile/children/${childModel.id}',
        queryParameters: {'lang': currentLang},
        data: _childWritePayload(childModel));
  }

  Future<Response> deleteChild(String childId) {
    return _dio.delete('users/parents/profile/children/$childId',
        queryParameters: {'lang': currentLang});
  }

  /// Backend only needs first_name + dob; everything else is stripped.
  Map<String, dynamic> _childWritePayload(ChildModel c) {
    return <String, dynamic>{
      if ((c.firstName ?? '').isNotEmpty) 'first_name': c.firstName,
      if ((c.dob ?? '').isNotEmpty) 'dob': c.dob,
    };
  }

  Future<Response> updateChildData() {
    return _dio.get('users/parents/profile/', queryParameters: {'lang': currentLang});
  }

  Future<Response> getChildren() {
    return _dio.get('users/children/', queryParameters: {'lang': currentLang});
  }

  Future<Response> getTariffs() {
    return _dio.get('tariffs/', queryParameters: {'lang': currentLang});
  }

  Future<Response> getPremiumPlans({int page = 1, int limit = 12}) {
    return _dio.get(
      'tariffs/',
      queryParameters: {'page': page, 'limit': limit},
    );
  }

  Future<Response> getCategories() {
    return _dio.get('categories/', queryParameters: {'lang': currentLang});
  }

  Future<Response> getClassCategories(
      String childId, String fromDate, String toDate, String classId) {
    return _dio.get(
        'schedules/class/$classId/check-availability',
        queryParameters: {
          'lang': currentLang,
          'child_id': childId,
          'from_date': fromDate,
          'to_date': toDate,
        });
  }

  Future<Response> purchaseSubscription(String tariffId) {
    return _dio.post('transaction/subscriptions/', queryParameters: {
      'lang': currentLang
    }, data: {
      'tariff_id': tariffId,
      'payment_method': 'PAYME',
    });
  }

  Future<Response> updateProfileData(HomForUser user) {
    return _dio.patch("users/parents/profile",
        queryParameters: {'profile_id': user.id, 'lang': currentLang},
        data: user.toJson()..remove("id"));
  }

  Future<Response> checkClassEligibility(String classId) {
    return _dio.get('classes/$classId/check-eligibility',
        queryParameters: {'lang': currentLang});
  }

  Future<Response> createBooking(Map<String, dynamic> bookingData) {
    return _dio.post('bookings/',
        queryParameters: {'lang': currentLang}, data: bookingData);
  }

  Future<Response> getUserBalance() {
    return _dio.get('transaction/wallets/me', queryParameters: {'lang': currentLang});
  }

  Future<Response> getCoinHistory() {
    return _dio.get('transaction/coin-flows/me', queryParameters: {'lang': currentLang});
  }

  Future<Response> uploadChildPhoto(String childId, File photo) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(photo.path,
          filename: photo.path.split('/').last),
    });
    return _dio.post('assets/files/child-photo/$childId',
        queryParameters: {'lang': currentLang}, data: formData);
  }

  Future<Response> getChildDetails(String childId) {
    return _dio.get('users/parents/profile/children/$childId',
        queryParameters: {'lang': currentLang});
  }

  Future<Response> getChildAttendanceHistory(String childId) {
    return _dio.get('attendance/history/child/$childId',
        queryParameters: {'lang': currentLang});
  }

  Future<Response> cancelBooking(String bookingId, String reason) {
    return _dio.patch('bookings/$bookingId/cancel',
        queryParameters: {'lang': currentLang},
        data: {'reason': reason});
  }

  /// Dedicated endpoint for the branch-detail screen — pulls only the classes
  /// for one branch instead of routing through the full /discovery/explore
  /// (which also fetches categories, banners, and unrelated branch data).
  Future<Response> getBranchClasses(
    String branchId, {
    int page = 1,
    int limit = 10,
  }) {
    return _dio.get(
      'branches/$branchId/classes',
      queryParameters: {
        'page': page,
        'limit': limit,
        'lang': currentLang,
      },
    );
  }

  Future<Response> explore({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? fromDate,
    String? toDate,
    int? age,
    String? classGender,
    num? minPrice,
    num? maxPrice,
    String? branchId,
    String? sortBy,
    double? lat,
    double? lng,
  }) {
    return _dio.get('discovery/explore', queryParameters: {
      'page': page,
      'limit': limit,
      'lang': currentLang,
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': categoryId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (age != null) 'age': age,
      if (classGender != null) 'class_gender': classGender,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (branchId != null) 'branch_id': branchId,
      if (sortBy != null) 'sort_by': sortBy,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
  }

  Future<Response> discoveryClasses({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? fromDate,
    String? toDate,
    int? age,
    String? classGender,
    num? minPrice,
    num? maxPrice,
    String? branchId,
    String? sortBy,
    double? lat,
    double? lng,
  }) {
    return _dio.get('discovery/classes', queryParameters: {
      'page': page,
      'limit': limit,
      'lang': currentLang,
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': categoryId,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (age != null) 'age': age,
      if (classGender != null) 'class_gender': classGender,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (branchId != null) 'branch_id': branchId,
      if (sortBy != null) 'sort_by': sortBy,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
  }

  /// Dedicated Shorts feed — the backend returns only activities that carry a
  /// video link, so the client never has to page the whole catalogue.
  Future<Response> discoveryShorts({
    int page = 1,
    int limit = 20,
  }) {
    return _dio.get('discovery/shorts', queryParameters: {
      'page': page,
      'limit': limit,
      'lang': currentLang,
    });
  }

  Future<Response> discoveryBranches({
    int page = 1,
    int limit = 10,
    String? search,
    String? categoryId,
    String? sortBy,
    double? lat,
    double? lng,
  }) {
    return _dio.get('discovery/branches', queryParameters: {
      'page': page,
      'limit': limit,
      'lang': currentLang,
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'category_id': categoryId,
      if (sortBy != null) 'sort_by': sortBy,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
  }

  /// Returns the count of activities that have a discount_percentage >= [minDiscount].
  /// Used on the coupon success screen to tell the user how many activities
  /// their plan applies to.
  Future<Response> getEligibleCount(int minDiscount) {
    return _dio.get('discovery/eligible-count', queryParameters: {
      'min_discount': minDiscount,
    });
  }
}

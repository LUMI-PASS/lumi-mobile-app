import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:lumi_pass/data/api_model/attendance/attendance_model.dart';
import 'package:lumi_pass/data/api_model/booking/booking_model.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/eligibility/eligibility_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_class/schedule_class_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';

import '../../data/storage/storage.dart';
import '../repo/home/home_api.dart';

@Injectable(as: HomeRepository)
class HomeRepositoryImpl extends HomeRepository {
  final HomeApi _api;
  final Storage _storage;
  String? parentId;

  HomeRepositoryImpl(this._api, this._storage);

  @override
  Future<HomeModel> getHome({
    int newClassesPage = 1,
    int newClassesLimit = 10,
    int categoryPage = 1,
    int categoryLimit = 10,
    int nearClassPage = 1,
    int nearClassLimit = 10,
    double? lat,
    double? lng,
  }) {
    return _api
        .getHome(
          newClassesPage: newClassesPage,
          newClassesLimit: newClassesLimit,
          categoryPage: categoryPage,
          categoryLimit: categoryLimit,
          nearClassPage: nearClassPage,
          nearClassLimit: nearClassLimit,
          lat: lat,
          lng: lng,
        )
        .then((value) => HomeModel.fromJson(value.data));
  }

  @override
  Future<List<ScheduleItem>> getScheduleList() {
    return _api
        .getSchedule()
        .then((value) => ScheduleModel.fromJson(value.data).data ?? []);
  }

  @override
  Future<HomForUser> getProfileData() {
    return _api
        .getProfileData()
        .then((value) => HomForUser.fromJson(value.data['data']['profile']));
  }

  @override
  Future<bool> updateUser(HomForUser user) async {
    try {
      await _api.updateProfileData(user);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<ChildModel>> getChildren() {
    return _api.getProfileData().then((value) {
      _storage.parentId.set(value.data['data']['profile']['id']);
      return (value.data['data']['children'] as List)
          .map((e) => ChildModel.fromJson(e))
          .toList();
    });
  }

  @override
  Future<ParentProfileResult> getParentProfile() {
    return _api.getProfileData().then((value) {
      final data = value.data['data'];
      _storage.parentId.set(data['profile']['id']);

      final children = (data['children'] as List)
          .map((e) => ChildModel.fromJson(e))
          .toList();

      ParentTrialSummary? trialSummary;
      if (data['trial_summary'] != null) {
        trialSummary = ParentTrialSummary.fromJson(data['trial_summary']);
      }

      final profile = data['profile'];
      return ParentProfileResult(
        children: children,
        trialSummary: trialSummary,
        parentCity: profile['city'] as String?,
        parentDistrict: profile['district'] as String?,
      );
    });
  }

  @override
  Future<void> addChild(ChildModel childModel) {
    return _api.addChild(childModel, _storage.parentId.call()!);
  }

  @override
  Future<String> addChildAndGetId(ChildModel childModel) {
    return _api
        .addChild(childModel, _storage.parentId.call()!)
        .then((value) => value.data['data']['id'] as String);
  }

  @override
  Future<void> uploadChildPhoto(String childId, File photo) {
    return _api.uploadChildPhoto(childId, photo);
  }

  @override
  Future<void> updateChild(ChildModel childModel, String parentId) {
    return _api.updateChild(childModel, parentId);
  }

  @override
  Future<List<Tariff>> getTariffs() {
    return _api.getTariffs().then((value) {
      return (value.data['data'] as List)
          .map((e) => Tariff.fromJson(e))
          .toList();
    });
  }

  @override
  Future<List<HomCategory>> getAllCategories() {
    return _api.getCategories().then((value) {
      return (value.data['data'] as List)
          .map((e) => HomCategory.fromJson(e))
          .toList();
    });
  }

  @override
  Future<void> purchaseSubscription(String tariffId) {
    return _api.purchaseSubscription(tariffId);
  }

  @override
  Future<List<TimeSlot>> getCLassSchedules(
      String childId, String fromDate, String toDate, String classId) {
    return _api
        .getClassCategories(childId, fromDate, toDate, classId)
        .then((value) {
      return (value.data['data']?['time_slots'] as List? ?? [])
          .map((e) => TimeSlot.fromJson(e))
          .toList();
    });
  }

  @override
  Future<ClassEligibilityData> checkClassEligibility(String classId) {
    return _api.checkClassEligibility(classId).then((value) {
      return ClassEligibilityData.fromJson(value.data['data']);
    });
  }

  @override
  Future<BookingResponse> createBooking(
      String scheduleId, String childId, String subscriptionId) {
    return _api.createBooking({
      'schedule_id': scheduleId,
      'child_id': childId,
      'subscription_id': subscriptionId,
    }).then((value) {
      return BookingResponse.fromJson(value.data['data']);
    });
  }

  @override
  Future<num> getUserBalance() {
    return _api.getUserBalance().then((value) {
      final data = value.data;
      // Handle both { balance: n } and { data: { balance: n } }
      if (data is Map && data.containsKey('balance')) {
        return data['balance'] as num;
      }
      return data['data']?['balance'] as num? ?? 0;
    });
  }

  @override
  Future<List<CoinFlow>> getCoinHistory() {
    return _api.getCoinHistory().then((value) {
      final data = value.data;
      final list = (data is List)
          ? data
          : (data is Map ? (data['data'] ?? []) : []);
      return (list as List)
          .map((e) => CoinFlow.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) {
          final aDate = a.createdAt ?? '';
          final bDate = b.createdAt ?? '';
          return bDate.compareTo(aDate);
        });
    });
  }

  @override
  Future<PurchaseResponse> purchaseSubscriptionWithResponse(String tariffId) {
    return _api.purchaseSubscription(tariffId).then((value) {
      final data = value.data;
      final map = (data is Map && data['data'] is Map)
          ? data['data'] as Map<String, dynamic>
          : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
      return PurchaseResponse.fromJson(map);
    });
  }

  @override
  Future<List<AttendanceRecord>> getChildAttendanceHistory(String childId) {
    return _api.getChildAttendanceHistory(childId).then((value) {
      final data = value.data;
      final list = (data is List)
          ? data
          : (data is Map ? (data['data'] ?? []) : []);
      return (list as List)
          .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<void> cancelBooking(String bookingId, String reason) {
    return _api.cancelBooking(bookingId, reason);
  }

  @override
  Future<ExploreResult> explore({
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
    return _api
        .explore(
          page: page,
          limit: limit,
          search: search,
          categoryId: categoryId,
          fromDate: fromDate,
          toDate: toDate,
          age: age,
          classGender: classGender,
          minPrice: minPrice,
          maxPrice: maxPrice,
          branchId: branchId,
          sortBy: sortBy,
          lat: lat,
          lng: lng,
        )
        .then((value) {
      final data = value.data['data'] ?? value.data;
      final classesData = data['classes'] ?? {};
      final branchesData = data['branches'] ?? {};
      return ExploreResult(
        classes: ((classesData['data'] ?? []) as List)
            .map((e) => HomClass.fromJson(e))
            .toList(),
        classesPages: classesData['pages'] ?? 1,
        branches: ((branchesData['data'] ?? []) as List)
            .map((e) => HomBranch.fromJson(e))
            .toList(),
        branchesPages: branchesData['pages'] ?? 1,
      );
    });
  }
}

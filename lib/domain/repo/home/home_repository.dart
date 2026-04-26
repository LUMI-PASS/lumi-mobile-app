import 'dart:io';

import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/attendance/attendance_model.dart';
import 'package:lumi_pass/data/api_model/booking/booking_model.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/eligibility/eligibility_model.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/schedule_class/schedule_class_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:lumi_pass/data/api_model/tarifff/tariff_model.dart';

class ParentProfileResult {
  final List<ChildModel> children;
  final ParentTrialSummary? trialSummary;
  final String? parentCity;
  final String? parentDistrict;

  ParentProfileResult({
    required this.children,
    this.trialSummary,
    this.parentCity,
    this.parentDistrict,
  });
}

abstract class HomeRepository {
  Future<HomeModel> getHome({
    int newClassesPage = 1,
    int newClassesLimit = 10,
    int categoryPage = 1,
    int categoryLimit = 10,
    int nearClassPage = 1,
    int nearClassLimit = 10,
    double? lat,
    double? lng,
  });

  Future<void> purchaseSubscription(String tariffId);

  Future<List<HomCategory>> getAllCategories();

  Future<List<ChildModel>> getChildren();

  Future<ParentProfileResult> getParentProfile();

  Future<String> addChildAndGetId(ChildModel childModel);

  Future<void> uploadChildPhoto(String childId, File photo);

  Future<List<TimeSlot>> getCLassSchedules(
      String childId, String fromDate, String toDate, String classId);

  Future<void> addChild(ChildModel childModel);

  Future<void> updateChild(ChildModel childModel, String parentId);

  Future<HomForUser> getProfileData();

  Future<List<ScheduleItem>> getScheduleList();

  Future<List<Tariff>> getTariffs();

  Future<bool> updateUser(HomForUser user);

  Future<ClassEligibilityData> checkClassEligibility(String classId);

  Future<BookingResponse> createBooking(
      String scheduleId, String childId, String subscriptionId);

  Future<num> getUserBalance();

  Future<PurchaseResponse> purchaseSubscriptionWithResponse(String tariffId);

  Future<List<CoinFlow>> getCoinHistory();

  Future<List<AttendanceRecord>> getChildAttendanceHistory(String childId);

  Future<void> cancelBooking(String bookingId, String reason);

  Future<ClassesPage> getDiscoveryClasses({
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
  });

  Future<BranchesPage> getDiscoveryBranches({
    int page = 1,
    int limit = 10,
    String? search,
    String? sortBy,
    double? lat,
    double? lng,
  });

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
  });
}

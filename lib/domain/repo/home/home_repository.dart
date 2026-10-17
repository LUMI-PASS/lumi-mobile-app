import 'dart:io' if (dart.library.html) 'package:lumi_pass/common/stubs/io_stub.dart';

import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/api_model/attendance/attendance_model.dart';
import 'package:lumi_pass/data/api_model/child_model/child_model.dart';
import 'package:lumi_pass/data/api_model/interest_topic/interest_topic.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/api_model/unclaimed_centre/unclaimed_centre.dart';
import 'package:lumi_pass/data/api_model/schedule_class/schedule_class_model.dart';
import 'package:lumi_pass/data/api_model/schedule_model/schedule_model.dart';
import 'package:lumi_pass/data/api_model/premium_plan/premium_plan_model.dart';

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

  Future<List<HomCategory>> getAllCategories();

  Future<List<ChildModel>> getChildren();

  /// The words the child form offers, in the adminka's order.
  Future<List<InterestTopic>> getInterestTopics();

  Future<ParentProfileResult> getParentProfile();

  Future<String> addChildAndGetId(ChildModel childModel);

  Future<void> uploadChildPhoto(String childId, File photo);

  Future<List<TimeSlot>> getCLassSchedules(
      String childId, String fromDate, String toDate, String classId);

  Future<void> addChild(ChildModel childModel);

  Future<void> updateChild(ChildModel childModel, String parentId);

  Future<void> deleteChild(String childId);

  Future<HomForUser> getProfileData();

  Future<List<ScheduleItem>> getScheduleList();

  Future<List<PremiumPlan>> getPremiumPlans();

  Future<bool> updateUser(HomForUser user);

  Future<List<AttendanceRecord>> getChildAttendanceHistory(String childId);

  Future<void> cancelBooking(String bookingId, String reason);

  Future<ClassesPage> getDiscoveryClasses({
    int page = 1,
    int limit = 10,
    String? search,
    /// Multi-select: an activity matches if its category is any of these.
    List<String>? categoryIds,
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
      List<String>? districts,
    /// `activities` | `courses` | `all`. Omitted, the endpoint lists
    /// activities only — what it has always done for a caller that says
    /// nothing.
    String? kind,
    /// Also return the centres matching [search] and [categoryIds], as
    /// [ClassesPage.branches] — one request for a search that shows both.
    bool centres = false,
  });

  Future<ClassesPage> getDiscoveryShorts({
    int page = 1,
    int limit = 20,
  });

  /// Courses-only, paged — for the home "Курсы" row's "see all".
  Future<ClassesPage> getDiscoveryCourses({
    int page = 1,
    int limit = 10,
    String? search,
  });

  /// See [ForChildrenPage].
  Future<ForChildrenPage> getForChildren({
    int page = 1,
    int limit = 10,
    String? topicId,
    String? search,
    double? lat,
    double? lng,
  });

  Future<BranchesPage> getDiscoveryBranches({
    int page = 1,
    int limit = 10,
    String? search,
    /// Multi-select: a centre matches if it runs an activity in any of these.
    List<String>? categoryIds,
    String? sortBy,
    double? lat,
    double? lng,
  });

  /// The home feed's rows of centres Lumi listed itself, before they signed —
  /// see [UnclaimedShelf].
  Future<List<UnclaimedShelf>> getUnclaimedShelves({double? lat, double? lng});

  /// One of them, in full.
  Future<UnclaimedCentre> getUnclaimedCentre(String id);

  Future<BranchClassesPage> getBranchClasses(
    String branchId, {
    int page = 1,
    int limit = 10,
  });

  /// One centre, mapped the way the feed maps it.
  ///
  /// The branch page is handed its centre and normally fetches nothing — but
  /// a CATALOGUE centre's social accounts are not on the feed's cards (they
  /// take a join through to the owning brand, which a card has no use for), so
  /// the page asks for them here. Null when the centre could not be loaded,
  /// which leaves the page exactly as complete as it already was.
  Future<HomBranch?> getBranch(String branchId);

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

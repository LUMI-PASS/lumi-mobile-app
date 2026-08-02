import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_model.freezed.dart';

part 'home_model.g.dart';

@freezed
class HomeModel with _$HomeModel {
  const factory HomeModel({
    bool? success,
    HomData? data,
  }) = _HomeModel;

  factory HomeModel.fromJson(Map<String, dynamic> json) =>
      _$HomeModelFromJson(json);
}

@freezed
class HomData with _$HomData {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomData({
    HomForUser? forUser,
    HomUpcomingClass? upcomingClass,
    List<HomBanner>? banners,
    HomCategoryPage? categories,
    HomClassPage? newClasses,
    HomNearClasses? nearClasses,
    // Courses — their own home row. The backend keeps them OUT of
    // newClasses/nearClasses, because a course is bought as a trial or as the
    // whole course, not per session.
    HomClassPage? courses,
  }) = _HomData;

  factory HomData.fromJson(Map<String, dynamic> json) =>
      _$HomDataFromJson(json);
}

@freezed
class HomForUser with _$HomForUser {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomForUser({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? dob,
    String? gender,
    String? type,
    String? city,
    String? district,
    bool? isVerified,
    String? createdAt,
    String? updatedAt,
  }) = _HomForUser;

  factory HomForUser.fromJson(Map<String, dynamic> json) =>
      _$HomForUserFromJson(json);
}

@freezed
class HomBanner with _$HomBanner {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomBanner({
    String? id,
    String? title,
    String? url,
    String? image,
    String? createdAt,
    String? updatedAt,
  }) = _HomBanner;

  factory HomBanner.fromJson(Map<String, dynamic> json) =>
      _$HomBannerFromJson(json);
}

@freezed
class HomCategoryPage with _$HomCategoryPage {
  const factory HomCategoryPage({
    int? page,
    int? limit,
    List<HomCategory>? data,
  }) = _HomCategoryPage;

  factory HomCategoryPage.fromJson(Map<String, dynamic> json) =>
      _$HomCategoryPageFromJson(json);
}

@freezed
class HomCategory with _$HomCategory {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomCategory({
    String? id,
    String? title,
    String? description,
    String? image,
    bool? hasPhoto,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) = _HomCategory;

  factory HomCategory.fromJson(Map<String, dynamic> json) =>
      _$HomCategoryFromJson(json);
}

@freezed
class HomClassPage with _$HomClassPage {
  const factory HomClassPage({
    int? page,
    int? limit,
    List<HomClass>? data,
  }) = _HomClassPage;

  factory HomClassPage.fromJson(Map<String, dynamic> json) =>
      _$HomClassPageFromJson(json);
}

@freezed
class HomNearClasses with _$HomNearClasses {
  const factory HomNearClasses({
    int? page,
    int? limit,
    List<HomClass>? data,
  }) = _HomNearClasses;

  factory HomNearClasses.fromJson(Map<String, dynamic> json) =>
      _$HomNearClassesFromJson(json);
}

@freezed
class HomClass with _$HomClass {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomClass({
    String? id,
    HomBranch? branch,
    String? category,
    String? title,
    String? description,
    int? duration,
    num? price,
    num? trialPrice,
    bool? trialEnabled,
    int? minAge,
    int? maxAge,
    String? gender,
    bool? isActive,
    bool? hasPhoto,
    String? image,
    double? distance,
    String? videoUrl,
    String? videoProvider,
    int? discountPercentage,
    // ── course fields (present only on cards from the `courses` section) ────
    bool? isCourse,
    /// How many trial lessons the course sells (normally 3).
    int? trialLessons,
    /// Price of the WHOLE course. `trialPrice` above is the trial total.
    ///
    /// For a course sold as LEVELS this is the CHEAPEST level's price — there is
    /// no single course price — and [priceFrom] is true so the card renders it
    /// as "from X".
    num? coursePrice,
    /// True when this course is sold as levels, so [coursePrice] is a floor.
    bool? priceFrom,
    /// How many levels are on sale. 0 for a course without levels.
    int? subcoursesCount,
    /// Cohort size for full enrolment. null = unlimited.
    int? seats,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) = _HomClass;

  factory HomClass.fromJson(Map<String, dynamic> json) =>
      _$HomClassFromJson(json);
}

@freezed
class HomUpcomingClass with _$HomUpcomingClass {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomUpcomingClass({
    String? classId,
    String? scheduleId,
    String? bookingId,
    String? className,
    String? branchName,
    String? branchAddress,
    String? categoryName,
    DateTime? startTime,
    DateTime? endTime,
    int? count,
    String? distance,
    HomChildData? forChild,
    List<HomRelatedBooking>? relatedBookings,
  }) = _HomUpcomingClass;

  factory HomUpcomingClass.fromJson(Map<String, dynamic> json) =>
      _$HomUpcomingClassFromJson(json);
}

@freezed
class HomChildData with _$HomChildData {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomChildData({
    String? id,
    String? parentId,
    String? firstName,
    String? lastName,
    String? type,
    int? age,
    String? childAgeType,
    bool? isEligible,
    bool? hasPhoto,
    bool? isVerified,
    String? createdAt,
    String? updatedAt,
  }) = _HomChildData;

  factory HomChildData.fromJson(Map<String, dynamic> json) =>
      _$HomChildDataFromJson(json);
}

@freezed
class HomRelatedBooking with _$HomRelatedBooking {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomRelatedBooking({
    String? id,
    String? scheduleId,
    String? childId,
    String? bookingStatus,
    num? chargedCoinAmount,
    bool? isTrialBooking,
    String? attendanceStatus,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) = _HomRelatedBooking;

  factory HomRelatedBooking.fromJson(Map<String, dynamic> json) =>
      _$HomRelatedBookingFromJson(json);
}

@freezed
class CoinFlow with _$CoinFlow {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory CoinFlow({
    String? id,
    num? amount,
    String? type,
    String? createdAt,
  }) = _CoinFlow;

  factory CoinFlow.fromJson(Map<String, dynamic> json) =>
      _$CoinFlowFromJson(json);
}

class ClassesPage {
  final List<HomClass> classes;
  final int totalPages;

  /// Total number of matching items across all pages (for the "Все • N"
  /// result count). Falls back to 0 when the API omits it.
  final int total;

  const ClassesPage({
    required this.classes,
    required this.totalPages,
    this.total = 0,
  });
}

class BranchesPage {
  final List<HomBranch> branches;
  final int totalPages;

  /// Total number of matching branches across all pages.
  final int total;

  const BranchesPage({
    required this.branches,
    required this.totalPages,
    this.total = 0,
  });
}

class ExploreResult {
  final List<HomClass> classes;
  final int classesPages;
  final List<HomBranch> branches;
  final int branchesPages;

  const ExploreResult({
    required this.classes,
    required this.classesPages,
    required this.branches,
    required this.branchesPages,
  });
}

/// Slim payload for the branch-detail "Classes" list — no categories or
/// banners, just paginated classes for one branch.
class BranchClassesPage {
  final List<HomClass> classes;
  final int classesPages;

  const BranchClassesPage({
    required this.classes,
    required this.classesPages,
  });
}

@freezed
class HomBranch with _$HomBranch {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomBranch({
    String? id,
    String? title,
    String? address,
    String? landmark,
    double? longitude,
    double? latitude,
    String? partnerId,
    String? managerId,
    String? description,
    double? distance,
    bool? isActive,
    bool? hasPhoto,
    String? image,
    List<String>? images,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) = _HomBranch;

  factory HomBranch.fromJson(Map<String, dynamic> json) =>
      _$HomBranchFromJson(json);
}

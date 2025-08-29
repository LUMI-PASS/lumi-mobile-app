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
    String? createdAt,
    String? updatedAt,
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
    int? minAge,
    int? maxAge,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
  }) = _HomClass;

  factory HomClass.fromJson(Map<String, dynamic> json) =>
      _$HomClassFromJson(json);
}

@freezed
class HomUpcomingClass with _$HomUpcomingClass {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomUpcomingClass({
    String? classId,
    String? className,
    String? branchName,
    String? branchAddress,
    DateTime? startTime,
    DateTime? endTime,
  }) = _HomUpcomingClass;

  factory HomUpcomingClass.fromJson(Map<String, dynamic> json) =>
      _$HomUpcomingClassFromJson(json);
}

@freezed
class HomBranch with _$HomBranch {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory HomBranch({
    String? id,
    String? title,
    String? address,
    double? longitude,
    double? latitude,
    String? partnerId,
    String? managerId,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    String? deletedAt,
  }) = _HomBranch;

  factory HomBranch.fromJson(Map<String, dynamic> json) =>
      _$HomBranchFromJson(json);
}

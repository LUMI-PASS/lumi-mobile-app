// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeModelImpl _$$HomeModelImplFromJson(Map<String, dynamic> json) =>
    _$HomeModelImpl(
      success: json['success'] as bool?,
      data: json['data'] == null
          ? null
          : HomData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$HomeModelImplToJson(_$HomeModelImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'data': instance.data,
    };

_$HomDataImpl _$$HomDataImplFromJson(Map<String, dynamic> json) =>
    _$HomDataImpl(
      forUser: json['for_user'] == null
          ? null
          : HomForUser.fromJson(json['for_user'] as Map<String, dynamic>),
      upcomingClass: json['upcoming_class'] == null
          ? null
          : HomUpcomingClass.fromJson(
              json['upcoming_class'] as Map<String, dynamic>),
      banners: (json['banners'] as List<dynamic>?)
          ?.map((e) => HomBanner.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: json['categories'] == null
          ? null
          : HomCategoryPage.fromJson(
              json['categories'] as Map<String, dynamic>),
      newClasses: json['new_classes'] == null
          ? null
          : HomClassPage.fromJson(json['new_classes'] as Map<String, dynamic>),
      nearClasses: json['near_classes'] == null
          ? null
          : HomNearClasses.fromJson(
              json['near_classes'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$HomDataImplToJson(_$HomDataImpl instance) =>
    <String, dynamic>{
      'for_user': instance.forUser,
      'upcoming_class': instance.upcomingClass,
      'banners': instance.banners,
      'categories': instance.categories,
      'new_classes': instance.newClasses,
      'near_classes': instance.nearClasses,
    };

_$HomForUserImpl _$$HomForUserImplFromJson(Map<String, dynamic> json) =>
    _$HomForUserImpl(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      dob: json['dob'] as String?,
      gender: json['gender'] as String?,
      type: json['type'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      isVerified: json['is_verified'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$HomForUserImplToJson(_$HomForUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'dob': instance.dob,
      'gender': instance.gender,
      'type': instance.type,
      'city': instance.city,
      'district': instance.district,
      'is_verified': instance.isVerified,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$HomBannerImpl _$$HomBannerImplFromJson(Map<String, dynamic> json) =>
    _$HomBannerImpl(
      id: json['id'] as String?,
      title: json['title'] as String?,
      url: json['url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$HomBannerImplToJson(_$HomBannerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$HomCategoryPageImpl _$$HomCategoryPageImplFromJson(
        Map<String, dynamic> json) =>
    _$HomCategoryPageImpl(
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => HomCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$HomCategoryPageImplToJson(
        _$HomCategoryPageImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'data': instance.data,
    };

_$HomCategoryImpl _$$HomCategoryImplFromJson(Map<String, dynamic> json) =>
    _$HomCategoryImpl(
      id: json['id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$HomCategoryImplToJson(_$HomCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$HomClassPageImpl _$$HomClassPageImplFromJson(Map<String, dynamic> json) =>
    _$HomClassPageImpl(
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => HomClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$HomClassPageImplToJson(_$HomClassPageImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'data': instance.data,
    };

_$HomNearClassesImpl _$$HomNearClassesImplFromJson(Map<String, dynamic> json) =>
    _$HomNearClassesImpl(
      page: (json['page'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => HomClass.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$HomNearClassesImplToJson(
        _$HomNearClassesImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'data': instance.data,
    };

_$HomClassImpl _$$HomClassImplFromJson(Map<String, dynamic> json) =>
    _$HomClassImpl(
      id: json['id'] as String?,
      branch: json['branch'] == null
          ? null
          : HomBranch.fromJson(json['branch'] as Map<String, dynamic>),
      category: json['category'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      duration: (json['duration'] as num?)?.toInt(),
      price: json['price'] as num?,
      minAge: (json['min_age'] as num?)?.toInt(),
      maxAge: (json['max_age'] as num?)?.toInt(),
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$HomClassImplToJson(_$HomClassImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'branch': instance.branch,
      'category': instance.category,
      'title': instance.title,
      'description': instance.description,
      'duration': instance.duration,
      'price': instance.price,
      'min_age': instance.minAge,
      'max_age': instance.maxAge,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$HomUpcomingClassImpl _$$HomUpcomingClassImplFromJson(
        Map<String, dynamic> json) =>
    _$HomUpcomingClassImpl(
      classId: json['class_id'] as String?,
      className: json['class_name'] as String?,
      branchName: json['branch_name'] as String?,
      branchAddress: json['branch_address'] as String?,
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
    );

Map<String, dynamic> _$$HomUpcomingClassImplToJson(
        _$HomUpcomingClassImpl instance) =>
    <String, dynamic>{
      'class_id': instance.classId,
      'class_name': instance.className,
      'branch_name': instance.branchName,
      'branch_address': instance.branchAddress,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
    };

_$HomBranchImpl _$$HomBranchImplFromJson(Map<String, dynamic> json) =>
    _$HomBranchImpl(
      id: json['id'] as String?,
      title: json['title'] as String?,
      address: json['address'] as String?,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      partnerId: json['partner_id'] as String?,
      managerId: json['manager_id'] as String?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );

Map<String, dynamic> _$$HomBranchImplToJson(_$HomBranchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'address': instance.address,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'partner_id': instance.partnerId,
      'manager_id': instance.managerId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };

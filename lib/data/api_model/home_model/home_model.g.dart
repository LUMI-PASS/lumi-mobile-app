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
      courses: json['courses'] == null
          ? null
          : HomClassPage.fromJson(json['courses'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$HomDataImplToJson(_$HomDataImpl instance) =>
    <String, dynamic>{
      'for_user': instance.forUser,
      'upcoming_class': instance.upcomingClass,
      'banners': instance.banners,
      'categories': instance.categories,
      'new_classes': instance.newClasses,
      'near_classes': instance.nearClasses,
      'courses': instance.courses,
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
      image: json['image'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$HomBannerImplToJson(_$HomBannerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'image': instance.image,
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
      image: json['image'] as String?,
      hasPhoto: json['has_photo'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );

Map<String, dynamic> _$$HomCategoryImplToJson(_$HomCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'image': instance.image,
      'has_photo': instance.hasPhoto,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
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
      trialPrice: json['trial_price'] as num?,
      trialEnabled: json['trial_enabled'] as bool?,
      minAge: (json['min_age'] as num?)?.toInt(),
      maxAge: (json['max_age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      isActive: json['is_active'] as bool?,
      isVisible: json['is_visible'] as bool?,
      hasPhoto: json['has_photo'] as bool?,
      image: json['image'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      videoUrl: json['video_url'] as String?,
      videoProvider: json['video_provider'] as String?,
      discountPercentage: (json['discount_percentage'] as num?)?.toInt(),
      isCourse: json['is_course'] as bool?,
      trialLessons: (json['trial_lessons'] as num?)?.toInt(),
      coursePrice: json['course_price'] as num?,
      priceFrom: json['price_from'] as bool?,
      subcoursesCount: (json['subcourses_count'] as num?)?.toInt(),
      seats: (json['seats'] as num?)?.toInt(),
      priceKind: json['price_kind'] as String?,
      cardPrice: json['card_price'] as num?,
      trialLessonNo: (json['trial_lesson_no'] as num?)?.toInt(),
      trialLessonsLeft: (json['trial_lessons_left'] as num?)?.toInt(),
      lessonsCount: (json['lessons_count'] as num?)?.toInt(),
      perLessonPrice: json['per_lesson_price'] as num?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
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
      'trial_price': instance.trialPrice,
      'trial_enabled': instance.trialEnabled,
      'min_age': instance.minAge,
      'max_age': instance.maxAge,
      'gender': instance.gender,
      'is_active': instance.isActive,
      'is_visible': instance.isVisible,
      'has_photo': instance.hasPhoto,
      'image': instance.image,
      'distance': instance.distance,
      'video_url': instance.videoUrl,
      'video_provider': instance.videoProvider,
      'discount_percentage': instance.discountPercentage,
      'is_course': instance.isCourse,
      'trial_lessons': instance.trialLessons,
      'course_price': instance.coursePrice,
      'price_from': instance.priceFrom,
      'subcourses_count': instance.subcoursesCount,
      'seats': instance.seats,
      'price_kind': instance.priceKind,
      'card_price': instance.cardPrice,
      'trial_lesson_no': instance.trialLessonNo,
      'trial_lessons_left': instance.trialLessonsLeft,
      'lessons_count': instance.lessonsCount,
      'per_lesson_price': instance.perLessonPrice,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };

_$HomUpcomingClassImpl _$$HomUpcomingClassImplFromJson(
        Map<String, dynamic> json) =>
    _$HomUpcomingClassImpl(
      classId: json['class_id'] as String?,
      scheduleId: json['schedule_id'] as String?,
      bookingId: json['booking_id'] as String?,
      className: json['class_name'] as String?,
      branchName: json['branch_name'] as String?,
      branchAddress: json['branch_address'] as String?,
      categoryName: json['category_name'] as String?,
      startTime: json['start_time'] == null
          ? null
          : DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] == null
          ? null
          : DateTime.parse(json['end_time'] as String),
      count: (json['count'] as num?)?.toInt(),
      distance: json['distance'] as String?,
      forChild: json['for_child'] == null
          ? null
          : HomChildData.fromJson(json['for_child'] as Map<String, dynamic>),
      relatedBookings: (json['related_bookings'] as List<dynamic>?)
          ?.map((e) => HomRelatedBooking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$HomUpcomingClassImplToJson(
        _$HomUpcomingClassImpl instance) =>
    <String, dynamic>{
      'class_id': instance.classId,
      'schedule_id': instance.scheduleId,
      'booking_id': instance.bookingId,
      'class_name': instance.className,
      'branch_name': instance.branchName,
      'branch_address': instance.branchAddress,
      'category_name': instance.categoryName,
      'start_time': instance.startTime?.toIso8601String(),
      'end_time': instance.endTime?.toIso8601String(),
      'count': instance.count,
      'distance': instance.distance,
      'for_child': instance.forChild,
      'related_bookings': instance.relatedBookings,
    };

_$HomChildDataImpl _$$HomChildDataImplFromJson(Map<String, dynamic> json) =>
    _$HomChildDataImpl(
      id: json['id'] as String?,
      parentId: json['parent_id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      type: json['type'] as String?,
      age: (json['age'] as num?)?.toInt(),
      childAgeType: json['child_age_type'] as String?,
      isEligible: json['is_eligible'] as bool?,
      hasPhoto: json['has_photo'] as bool?,
      isVerified: json['is_verified'] as bool?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$HomChildDataImplToJson(_$HomChildDataImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parent_id': instance.parentId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'type': instance.type,
      'age': instance.age,
      'child_age_type': instance.childAgeType,
      'is_eligible': instance.isEligible,
      'has_photo': instance.hasPhoto,
      'is_verified': instance.isVerified,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$HomRelatedBookingImpl _$$HomRelatedBookingImplFromJson(
        Map<String, dynamic> json) =>
    _$HomRelatedBookingImpl(
      id: json['id'] as String?,
      scheduleId: json['schedule_id'] as String?,
      childId: json['child_id'] as String?,
      bookingStatus: json['booking_status'] as String?,
      chargedCoinAmount: json['charged_coin_amount'] as num?,
      isTrialBooking: json['is_trial_booking'] as bool?,
      attendanceStatus: json['attendance_status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );

Map<String, dynamic> _$$HomRelatedBookingImplToJson(
        _$HomRelatedBookingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'schedule_id': instance.scheduleId,
      'child_id': instance.childId,
      'booking_status': instance.bookingStatus,
      'charged_coin_amount': instance.chargedCoinAmount,
      'is_trial_booking': instance.isTrialBooking,
      'attendance_status': instance.attendanceStatus,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };

_$HomBranchImpl _$$HomBranchImplFromJson(Map<String, dynamic> json) =>
    _$HomBranchImpl(
      id: json['id'] as String?,
      title: json['title'] as String?,
      address: json['address'] as String?,
      landmark: json['landmark'] as String?,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      partnerId: json['partner_id'] as String?,
      managerId: json['manager_id'] as String?,
      description: json['description'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool?,
      hasPhoto: json['has_photo'] as bool?,
      image: json['image'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );

Map<String, dynamic> _$$HomBranchImplToJson(_$HomBranchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'address': instance.address,
      'landmark': instance.landmark,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
      'partner_id': instance.partnerId,
      'manager_id': instance.managerId,
      'description': instance.description,
      'distance': instance.distance,
      'is_active': instance.isActive,
      'has_photo': instance.hasPhoto,
      'image': instance.image,
      'images': instance.images,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'deleted_at': instance.deletedAt,
    };

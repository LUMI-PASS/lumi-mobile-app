// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HomeModel _$HomeModelFromJson(Map<String, dynamic> json) {
  return _HomeModel.fromJson(json);
}

/// @nodoc
mixin _$HomeModel {
  bool? get success => throw _privateConstructorUsedError;
  HomData? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomeModelCopyWith<HomeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeModelCopyWith<$Res> {
  factory $HomeModelCopyWith(HomeModel value, $Res Function(HomeModel) then) =
      _$HomeModelCopyWithImpl<$Res, HomeModel>;
  @useResult
  $Res call({bool? success, HomData? data});

  $HomDataCopyWith<$Res>? get data;
}

/// @nodoc
class _$HomeModelCopyWithImpl<$Res, $Val extends HomeModel>
    implements $HomeModelCopyWith<$Res> {
  _$HomeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as HomData?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomDataCopyWith<$Res>? get data {
    if (_value.data == null) {
      return null;
    }

    return $HomDataCopyWith<$Res>(_value.data!, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeModelImplCopyWith<$Res>
    implements $HomeModelCopyWith<$Res> {
  factory _$$HomeModelImplCopyWith(
          _$HomeModelImpl value, $Res Function(_$HomeModelImpl) then) =
      __$$HomeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? success, HomData? data});

  @override
  $HomDataCopyWith<$Res>? get data;
}

/// @nodoc
class __$$HomeModelImplCopyWithImpl<$Res>
    extends _$HomeModelCopyWithImpl<$Res, _$HomeModelImpl>
    implements _$$HomeModelImplCopyWith<$Res> {
  __$$HomeModelImplCopyWithImpl(
      _$HomeModelImpl _value, $Res Function(_$HomeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = freezed,
    Object? data = freezed,
  }) {
    return _then(_$HomeModelImpl(
      success: freezed == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as HomData?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomeModelImpl implements _HomeModel {
  const _$HomeModelImpl({this.success, this.data});

  factory _$HomeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomeModelImplFromJson(json);

  @override
  final bool? success;
  @override
  final HomData? data;

  @override
  String toString() {
    return 'HomeModel(success: $success, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, success, data);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeModelImplCopyWith<_$HomeModelImpl> get copyWith =>
      __$$HomeModelImplCopyWithImpl<_$HomeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomeModelImplToJson(
      this,
    );
  }
}

abstract class _HomeModel implements HomeModel {
  const factory _HomeModel({final bool? success, final HomData? data}) =
      _$HomeModelImpl;

  factory _HomeModel.fromJson(Map<String, dynamic> json) =
      _$HomeModelImpl.fromJson;

  @override
  bool? get success;
  @override
  HomData? get data;
  @override
  @JsonKey(ignore: true)
  _$$HomeModelImplCopyWith<_$HomeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomData _$HomDataFromJson(Map<String, dynamic> json) {
  return _HomData.fromJson(json);
}

/// @nodoc
mixin _$HomData {
  HomForUser? get forUser => throw _privateConstructorUsedError;
  HomUpcomingClass? get upcomingClass => throw _privateConstructorUsedError;
  List<HomBanner>? get banners => throw _privateConstructorUsedError;
  HomCategoryPage? get categories => throw _privateConstructorUsedError;
  HomClassPage? get newClasses => throw _privateConstructorUsedError;
  HomNearClasses? get nearClasses =>
      throw _privateConstructorUsedError; // Courses — their own home row. The backend keeps them OUT of
// newClasses/nearClasses, because a course is bought as a trial or as the
// whole course, not per session.
  HomClassPage? get courses => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomDataCopyWith<HomData> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomDataCopyWith<$Res> {
  factory $HomDataCopyWith(HomData value, $Res Function(HomData) then) =
      _$HomDataCopyWithImpl<$Res, HomData>;
  @useResult
  $Res call(
      {HomForUser? forUser,
      HomUpcomingClass? upcomingClass,
      List<HomBanner>? banners,
      HomCategoryPage? categories,
      HomClassPage? newClasses,
      HomNearClasses? nearClasses,
      HomClassPage? courses});

  $HomForUserCopyWith<$Res>? get forUser;
  $HomUpcomingClassCopyWith<$Res>? get upcomingClass;
  $HomCategoryPageCopyWith<$Res>? get categories;
  $HomClassPageCopyWith<$Res>? get newClasses;
  $HomNearClassesCopyWith<$Res>? get nearClasses;
  $HomClassPageCopyWith<$Res>? get courses;
}

/// @nodoc
class _$HomDataCopyWithImpl<$Res, $Val extends HomData>
    implements $HomDataCopyWith<$Res> {
  _$HomDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? forUser = freezed,
    Object? upcomingClass = freezed,
    Object? banners = freezed,
    Object? categories = freezed,
    Object? newClasses = freezed,
    Object? nearClasses = freezed,
    Object? courses = freezed,
  }) {
    return _then(_value.copyWith(
      forUser: freezed == forUser
          ? _value.forUser
          : forUser // ignore: cast_nullable_to_non_nullable
              as HomForUser?,
      upcomingClass: freezed == upcomingClass
          ? _value.upcomingClass
          : upcomingClass // ignore: cast_nullable_to_non_nullable
              as HomUpcomingClass?,
      banners: freezed == banners
          ? _value.banners
          : banners // ignore: cast_nullable_to_non_nullable
              as List<HomBanner>?,
      categories: freezed == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as HomCategoryPage?,
      newClasses: freezed == newClasses
          ? _value.newClasses
          : newClasses // ignore: cast_nullable_to_non_nullable
              as HomClassPage?,
      nearClasses: freezed == nearClasses
          ? _value.nearClasses
          : nearClasses // ignore: cast_nullable_to_non_nullable
              as HomNearClasses?,
      courses: freezed == courses
          ? _value.courses
          : courses // ignore: cast_nullable_to_non_nullable
              as HomClassPage?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomForUserCopyWith<$Res>? get forUser {
    if (_value.forUser == null) {
      return null;
    }

    return $HomForUserCopyWith<$Res>(_value.forUser!, (value) {
      return _then(_value.copyWith(forUser: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HomUpcomingClassCopyWith<$Res>? get upcomingClass {
    if (_value.upcomingClass == null) {
      return null;
    }

    return $HomUpcomingClassCopyWith<$Res>(_value.upcomingClass!, (value) {
      return _then(_value.copyWith(upcomingClass: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HomCategoryPageCopyWith<$Res>? get categories {
    if (_value.categories == null) {
      return null;
    }

    return $HomCategoryPageCopyWith<$Res>(_value.categories!, (value) {
      return _then(_value.copyWith(categories: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HomClassPageCopyWith<$Res>? get newClasses {
    if (_value.newClasses == null) {
      return null;
    }

    return $HomClassPageCopyWith<$Res>(_value.newClasses!, (value) {
      return _then(_value.copyWith(newClasses: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HomNearClassesCopyWith<$Res>? get nearClasses {
    if (_value.nearClasses == null) {
      return null;
    }

    return $HomNearClassesCopyWith<$Res>(_value.nearClasses!, (value) {
      return _then(_value.copyWith(nearClasses: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $HomClassPageCopyWith<$Res>? get courses {
    if (_value.courses == null) {
      return null;
    }

    return $HomClassPageCopyWith<$Res>(_value.courses!, (value) {
      return _then(_value.copyWith(courses: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomDataImplCopyWith<$Res> implements $HomDataCopyWith<$Res> {
  factory _$$HomDataImplCopyWith(
          _$HomDataImpl value, $Res Function(_$HomDataImpl) then) =
      __$$HomDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {HomForUser? forUser,
      HomUpcomingClass? upcomingClass,
      List<HomBanner>? banners,
      HomCategoryPage? categories,
      HomClassPage? newClasses,
      HomNearClasses? nearClasses,
      HomClassPage? courses});

  @override
  $HomForUserCopyWith<$Res>? get forUser;
  @override
  $HomUpcomingClassCopyWith<$Res>? get upcomingClass;
  @override
  $HomCategoryPageCopyWith<$Res>? get categories;
  @override
  $HomClassPageCopyWith<$Res>? get newClasses;
  @override
  $HomNearClassesCopyWith<$Res>? get nearClasses;
  @override
  $HomClassPageCopyWith<$Res>? get courses;
}

/// @nodoc
class __$$HomDataImplCopyWithImpl<$Res>
    extends _$HomDataCopyWithImpl<$Res, _$HomDataImpl>
    implements _$$HomDataImplCopyWith<$Res> {
  __$$HomDataImplCopyWithImpl(
      _$HomDataImpl _value, $Res Function(_$HomDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? forUser = freezed,
    Object? upcomingClass = freezed,
    Object? banners = freezed,
    Object? categories = freezed,
    Object? newClasses = freezed,
    Object? nearClasses = freezed,
    Object? courses = freezed,
  }) {
    return _then(_$HomDataImpl(
      forUser: freezed == forUser
          ? _value.forUser
          : forUser // ignore: cast_nullable_to_non_nullable
              as HomForUser?,
      upcomingClass: freezed == upcomingClass
          ? _value.upcomingClass
          : upcomingClass // ignore: cast_nullable_to_non_nullable
              as HomUpcomingClass?,
      banners: freezed == banners
          ? _value._banners
          : banners // ignore: cast_nullable_to_non_nullable
              as List<HomBanner>?,
      categories: freezed == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as HomCategoryPage?,
      newClasses: freezed == newClasses
          ? _value.newClasses
          : newClasses // ignore: cast_nullable_to_non_nullable
              as HomClassPage?,
      nearClasses: freezed == nearClasses
          ? _value.nearClasses
          : nearClasses // ignore: cast_nullable_to_non_nullable
              as HomNearClasses?,
      courses: freezed == courses
          ? _value.courses
          : courses // ignore: cast_nullable_to_non_nullable
              as HomClassPage?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomDataImpl implements _HomData {
  const _$HomDataImpl(
      {this.forUser,
      this.upcomingClass,
      final List<HomBanner>? banners,
      this.categories,
      this.newClasses,
      this.nearClasses,
      this.courses})
      : _banners = banners;

  factory _$HomDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomDataImplFromJson(json);

  @override
  final HomForUser? forUser;
  @override
  final HomUpcomingClass? upcomingClass;
  final List<HomBanner>? _banners;
  @override
  List<HomBanner>? get banners {
    final value = _banners;
    if (value == null) return null;
    if (_banners is EqualUnmodifiableListView) return _banners;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final HomCategoryPage? categories;
  @override
  final HomClassPage? newClasses;
  @override
  final HomNearClasses? nearClasses;
// Courses — their own home row. The backend keeps them OUT of
// newClasses/nearClasses, because a course is bought as a trial or as the
// whole course, not per session.
  @override
  final HomClassPage? courses;

  @override
  String toString() {
    return 'HomData(forUser: $forUser, upcomingClass: $upcomingClass, banners: $banners, categories: $categories, newClasses: $newClasses, nearClasses: $nearClasses, courses: $courses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomDataImpl &&
            (identical(other.forUser, forUser) || other.forUser == forUser) &&
            (identical(other.upcomingClass, upcomingClass) ||
                other.upcomingClass == upcomingClass) &&
            const DeepCollectionEquality().equals(other._banners, _banners) &&
            (identical(other.categories, categories) ||
                other.categories == categories) &&
            (identical(other.newClasses, newClasses) ||
                other.newClasses == newClasses) &&
            (identical(other.nearClasses, nearClasses) ||
                other.nearClasses == nearClasses) &&
            (identical(other.courses, courses) || other.courses == courses));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      forUser,
      upcomingClass,
      const DeepCollectionEquality().hash(_banners),
      categories,
      newClasses,
      nearClasses,
      courses);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomDataImplCopyWith<_$HomDataImpl> get copyWith =>
      __$$HomDataImplCopyWithImpl<_$HomDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomDataImplToJson(
      this,
    );
  }
}

abstract class _HomData implements HomData {
  const factory _HomData(
      {final HomForUser? forUser,
      final HomUpcomingClass? upcomingClass,
      final List<HomBanner>? banners,
      final HomCategoryPage? categories,
      final HomClassPage? newClasses,
      final HomNearClasses? nearClasses,
      final HomClassPage? courses}) = _$HomDataImpl;

  factory _HomData.fromJson(Map<String, dynamic> json) = _$HomDataImpl.fromJson;

  @override
  HomForUser? get forUser;
  @override
  HomUpcomingClass? get upcomingClass;
  @override
  List<HomBanner>? get banners;
  @override
  HomCategoryPage? get categories;
  @override
  HomClassPage? get newClasses;
  @override
  HomNearClasses? get nearClasses;
  @override // Courses — their own home row. The backend keeps them OUT of
// newClasses/nearClasses, because a course is bought as a trial or as the
// whole course, not per session.
  HomClassPage? get courses;
  @override
  @JsonKey(ignore: true)
  _$$HomDataImplCopyWith<_$HomDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomForUser _$HomForUserFromJson(Map<String, dynamic> json) {
  return _HomForUser.fromJson(json);
}

/// @nodoc
mixin _$HomForUser {
  String? get id => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get dob => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get city => throw _privateConstructorUsedError;
  String? get district => throw _privateConstructorUsedError;
  bool? get isVerified => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomForUserCopyWith<HomForUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomForUserCopyWith<$Res> {
  factory $HomForUserCopyWith(
          HomForUser value, $Res Function(HomForUser) then) =
      _$HomForUserCopyWithImpl<$Res, HomForUser>;
  @useResult
  $Res call(
      {String? id,
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
      String? updatedAt});
}

/// @nodoc
class _$HomForUserCopyWithImpl<$Res, $Val extends HomForUser>
    implements $HomForUserCopyWith<$Res> {
  _$HomForUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? type = freezed,
    Object? city = freezed,
    Object? district = freezed,
    Object? isVerified = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomForUserImplCopyWith<$Res>
    implements $HomForUserCopyWith<$Res> {
  factory _$$HomForUserImplCopyWith(
          _$HomForUserImpl value, $Res Function(_$HomForUserImpl) then) =
      __$$HomForUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
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
      String? updatedAt});
}

/// @nodoc
class __$$HomForUserImplCopyWithImpl<$Res>
    extends _$HomForUserCopyWithImpl<$Res, _$HomForUserImpl>
    implements _$$HomForUserImplCopyWith<$Res> {
  __$$HomForUserImplCopyWithImpl(
      _$HomForUserImpl _value, $Res Function(_$HomForUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? phoneNumber = freezed,
    Object? dob = freezed,
    Object? gender = freezed,
    Object? type = freezed,
    Object? city = freezed,
    Object? district = freezed,
    Object? isVerified = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$HomForUserImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      district: freezed == district
          ? _value.district
          : district // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomForUserImpl implements _HomForUser {
  const _$HomForUserImpl(
      {this.id,
      this.firstName,
      this.lastName,
      this.phoneNumber,
      this.dob,
      this.gender,
      this.type,
      this.city,
      this.district,
      this.isVerified,
      this.createdAt,
      this.updatedAt});

  factory _$HomForUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomForUserImplFromJson(json);

  @override
  final String? id;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? phoneNumber;
  @override
  final String? dob;
  @override
  final String? gender;
  @override
  final String? type;
  @override
  final String? city;
  @override
  final String? district;
  @override
  final bool? isVerified;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'HomForUser(id: $id, firstName: $firstName, lastName: $lastName, phoneNumber: $phoneNumber, dob: $dob, gender: $gender, type: $type, city: $city, district: $district, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomForUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.district, district) ||
                other.district == district) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      firstName,
      lastName,
      phoneNumber,
      dob,
      gender,
      type,
      city,
      district,
      isVerified,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomForUserImplCopyWith<_$HomForUserImpl> get copyWith =>
      __$$HomForUserImplCopyWithImpl<_$HomForUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomForUserImplToJson(
      this,
    );
  }
}

abstract class _HomForUser implements HomForUser {
  const factory _HomForUser(
      {final String? id,
      final String? firstName,
      final String? lastName,
      final String? phoneNumber,
      final String? dob,
      final String? gender,
      final String? type,
      final String? city,
      final String? district,
      final bool? isVerified,
      final String? createdAt,
      final String? updatedAt}) = _$HomForUserImpl;

  factory _HomForUser.fromJson(Map<String, dynamic> json) =
      _$HomForUserImpl.fromJson;

  @override
  String? get id;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get phoneNumber;
  @override
  String? get dob;
  @override
  String? get gender;
  @override
  String? get type;
  @override
  String? get city;
  @override
  String? get district;
  @override
  bool? get isVerified;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$HomForUserImplCopyWith<_$HomForUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomBanner _$HomBannerFromJson(Map<String, dynamic> json) {
  return _HomBanner.fromJson(json);
}

/// @nodoc
mixin _$HomBanner {
  String? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomBannerCopyWith<HomBanner> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomBannerCopyWith<$Res> {
  factory $HomBannerCopyWith(HomBanner value, $Res Function(HomBanner) then) =
      _$HomBannerCopyWithImpl<$Res, HomBanner>;
  @useResult
  $Res call(
      {String? id,
      String? title,
      String? url,
      String? image,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class _$HomBannerCopyWithImpl<$Res, $Val extends HomBanner>
    implements $HomBannerCopyWith<$Res> {
  _$HomBannerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? url = freezed,
    Object? image = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomBannerImplCopyWith<$Res>
    implements $HomBannerCopyWith<$Res> {
  factory _$$HomBannerImplCopyWith(
          _$HomBannerImpl value, $Res Function(_$HomBannerImpl) then) =
      __$$HomBannerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? title,
      String? url,
      String? image,
      String? createdAt,
      String? updatedAt});
}

/// @nodoc
class __$$HomBannerImplCopyWithImpl<$Res>
    extends _$HomBannerCopyWithImpl<$Res, _$HomBannerImpl>
    implements _$$HomBannerImplCopyWith<$Res> {
  __$$HomBannerImplCopyWithImpl(
      _$HomBannerImpl _value, $Res Function(_$HomBannerImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? url = freezed,
    Object? image = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$HomBannerImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      url: freezed == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomBannerImpl implements _HomBanner {
  const _$HomBannerImpl(
      {this.id,
      this.title,
      this.url,
      this.image,
      this.createdAt,
      this.updatedAt});

  factory _$HomBannerImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomBannerImplFromJson(json);

  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? url;
  @override
  final String? image;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'HomBanner(id: $id, title: $title, url: $url, image: $image, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomBannerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, url, image, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomBannerImplCopyWith<_$HomBannerImpl> get copyWith =>
      __$$HomBannerImplCopyWithImpl<_$HomBannerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomBannerImplToJson(
      this,
    );
  }
}

abstract class _HomBanner implements HomBanner {
  const factory _HomBanner(
      {final String? id,
      final String? title,
      final String? url,
      final String? image,
      final String? createdAt,
      final String? updatedAt}) = _$HomBannerImpl;

  factory _HomBanner.fromJson(Map<String, dynamic> json) =
      _$HomBannerImpl.fromJson;

  @override
  String? get id;
  @override
  String? get title;
  @override
  String? get url;
  @override
  String? get image;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$HomBannerImplCopyWith<_$HomBannerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomCategoryPage _$HomCategoryPageFromJson(Map<String, dynamic> json) {
  return _HomCategoryPage.fromJson(json);
}

/// @nodoc
mixin _$HomCategoryPage {
  int? get page => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;
  List<HomCategory>? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomCategoryPageCopyWith<HomCategoryPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomCategoryPageCopyWith<$Res> {
  factory $HomCategoryPageCopyWith(
          HomCategoryPage value, $Res Function(HomCategoryPage) then) =
      _$HomCategoryPageCopyWithImpl<$Res, HomCategoryPage>;
  @useResult
  $Res call({int? page, int? limit, List<HomCategory>? data});
}

/// @nodoc
class _$HomCategoryPageCopyWithImpl<$Res, $Val extends HomCategoryPage>
    implements $HomCategoryPageCopyWith<$Res> {
  _$HomCategoryPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? limit = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<HomCategory>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomCategoryPageImplCopyWith<$Res>
    implements $HomCategoryPageCopyWith<$Res> {
  factory _$$HomCategoryPageImplCopyWith(_$HomCategoryPageImpl value,
          $Res Function(_$HomCategoryPageImpl) then) =
      __$$HomCategoryPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? page, int? limit, List<HomCategory>? data});
}

/// @nodoc
class __$$HomCategoryPageImplCopyWithImpl<$Res>
    extends _$HomCategoryPageCopyWithImpl<$Res, _$HomCategoryPageImpl>
    implements _$$HomCategoryPageImplCopyWith<$Res> {
  __$$HomCategoryPageImplCopyWithImpl(
      _$HomCategoryPageImpl _value, $Res Function(_$HomCategoryPageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? limit = freezed,
    Object? data = freezed,
  }) {
    return _then(_$HomCategoryPageImpl(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<HomCategory>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomCategoryPageImpl implements _HomCategoryPage {
  const _$HomCategoryPageImpl(
      {this.page, this.limit, final List<HomCategory>? data})
      : _data = data;

  factory _$HomCategoryPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomCategoryPageImplFromJson(json);

  @override
  final int? page;
  @override
  final int? limit;
  final List<HomCategory>? _data;
  @override
  List<HomCategory>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'HomCategoryPage(page: $page, limit: $limit, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomCategoryPageImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, page, limit, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomCategoryPageImplCopyWith<_$HomCategoryPageImpl> get copyWith =>
      __$$HomCategoryPageImplCopyWithImpl<_$HomCategoryPageImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomCategoryPageImplToJson(
      this,
    );
  }
}

abstract class _HomCategoryPage implements HomCategoryPage {
  const factory _HomCategoryPage(
      {final int? page,
      final int? limit,
      final List<HomCategory>? data}) = _$HomCategoryPageImpl;

  factory _HomCategoryPage.fromJson(Map<String, dynamic> json) =
      _$HomCategoryPageImpl.fromJson;

  @override
  int? get page;
  @override
  int? get limit;
  @override
  List<HomCategory>? get data;
  @override
  @JsonKey(ignore: true)
  _$$HomCategoryPageImplCopyWith<_$HomCategoryPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomCategory _$HomCategoryFromJson(Map<String, dynamic> json) {
  return _HomCategory.fromJson(json);
}

/// @nodoc
mixin _$HomCategory {
  String? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  bool? get hasPhoto => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get deletedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomCategoryCopyWith<HomCategory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomCategoryCopyWith<$Res> {
  factory $HomCategoryCopyWith(
          HomCategory value, $Res Function(HomCategory) then) =
      _$HomCategoryCopyWithImpl<$Res, HomCategory>;
  @useResult
  $Res call(
      {String? id,
      String? title,
      String? description,
      String? image,
      bool? hasPhoto,
      String? createdAt,
      String? updatedAt,
      String? deletedAt});
}

/// @nodoc
class _$HomCategoryCopyWithImpl<$Res, $Val extends HomCategory>
    implements $HomCategoryCopyWith<$Res> {
  _$HomCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? image = freezed,
    Object? hasPhoto = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomCategoryImplCopyWith<$Res>
    implements $HomCategoryCopyWith<$Res> {
  factory _$$HomCategoryImplCopyWith(
          _$HomCategoryImpl value, $Res Function(_$HomCategoryImpl) then) =
      __$$HomCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? title,
      String? description,
      String? image,
      bool? hasPhoto,
      String? createdAt,
      String? updatedAt,
      String? deletedAt});
}

/// @nodoc
class __$$HomCategoryImplCopyWithImpl<$Res>
    extends _$HomCategoryCopyWithImpl<$Res, _$HomCategoryImpl>
    implements _$$HomCategoryImplCopyWith<$Res> {
  __$$HomCategoryImplCopyWithImpl(
      _$HomCategoryImpl _value, $Res Function(_$HomCategoryImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? image = freezed,
    Object? hasPhoto = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_$HomCategoryImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomCategoryImpl implements _HomCategory {
  const _$HomCategoryImpl(
      {this.id,
      this.title,
      this.description,
      this.image,
      this.hasPhoto,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  factory _$HomCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomCategoryImplFromJson(json);

  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? image;
  @override
  final bool? hasPhoto;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final String? deletedAt;

  @override
  String toString() {
    return 'HomCategory(id: $id, title: $title, description: $description, image: $image, hasPhoto: $hasPhoto, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomCategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.hasPhoto, hasPhoto) ||
                other.hasPhoto == hasPhoto) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, description, image,
      hasPhoto, createdAt, updatedAt, deletedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomCategoryImplCopyWith<_$HomCategoryImpl> get copyWith =>
      __$$HomCategoryImplCopyWithImpl<_$HomCategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomCategoryImplToJson(
      this,
    );
  }
}

abstract class _HomCategory implements HomCategory {
  const factory _HomCategory(
      {final String? id,
      final String? title,
      final String? description,
      final String? image,
      final bool? hasPhoto,
      final String? createdAt,
      final String? updatedAt,
      final String? deletedAt}) = _$HomCategoryImpl;

  factory _HomCategory.fromJson(Map<String, dynamic> json) =
      _$HomCategoryImpl.fromJson;

  @override
  String? get id;
  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get image;
  @override
  bool? get hasPhoto;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  String? get deletedAt;
  @override
  @JsonKey(ignore: true)
  _$$HomCategoryImplCopyWith<_$HomCategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomClassPage _$HomClassPageFromJson(Map<String, dynamic> json) {
  return _HomClassPage.fromJson(json);
}

/// @nodoc
mixin _$HomClassPage {
  int? get page => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;
  List<HomClass>? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomClassPageCopyWith<HomClassPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomClassPageCopyWith<$Res> {
  factory $HomClassPageCopyWith(
          HomClassPage value, $Res Function(HomClassPage) then) =
      _$HomClassPageCopyWithImpl<$Res, HomClassPage>;
  @useResult
  $Res call({int? page, int? limit, List<HomClass>? data});
}

/// @nodoc
class _$HomClassPageCopyWithImpl<$Res, $Val extends HomClassPage>
    implements $HomClassPageCopyWith<$Res> {
  _$HomClassPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? limit = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<HomClass>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomClassPageImplCopyWith<$Res>
    implements $HomClassPageCopyWith<$Res> {
  factory _$$HomClassPageImplCopyWith(
          _$HomClassPageImpl value, $Res Function(_$HomClassPageImpl) then) =
      __$$HomClassPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? page, int? limit, List<HomClass>? data});
}

/// @nodoc
class __$$HomClassPageImplCopyWithImpl<$Res>
    extends _$HomClassPageCopyWithImpl<$Res, _$HomClassPageImpl>
    implements _$$HomClassPageImplCopyWith<$Res> {
  __$$HomClassPageImplCopyWithImpl(
      _$HomClassPageImpl _value, $Res Function(_$HomClassPageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? limit = freezed,
    Object? data = freezed,
  }) {
    return _then(_$HomClassPageImpl(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<HomClass>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomClassPageImpl implements _HomClassPage {
  const _$HomClassPageImpl({this.page, this.limit, final List<HomClass>? data})
      : _data = data;

  factory _$HomClassPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomClassPageImplFromJson(json);

  @override
  final int? page;
  @override
  final int? limit;
  final List<HomClass>? _data;
  @override
  List<HomClass>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'HomClassPage(page: $page, limit: $limit, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomClassPageImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, page, limit, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomClassPageImplCopyWith<_$HomClassPageImpl> get copyWith =>
      __$$HomClassPageImplCopyWithImpl<_$HomClassPageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomClassPageImplToJson(
      this,
    );
  }
}

abstract class _HomClassPage implements HomClassPage {
  const factory _HomClassPage(
      {final int? page,
      final int? limit,
      final List<HomClass>? data}) = _$HomClassPageImpl;

  factory _HomClassPage.fromJson(Map<String, dynamic> json) =
      _$HomClassPageImpl.fromJson;

  @override
  int? get page;
  @override
  int? get limit;
  @override
  List<HomClass>? get data;
  @override
  @JsonKey(ignore: true)
  _$$HomClassPageImplCopyWith<_$HomClassPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomNearClasses _$HomNearClassesFromJson(Map<String, dynamic> json) {
  return _HomNearClasses.fromJson(json);
}

/// @nodoc
mixin _$HomNearClasses {
  int? get page => throw _privateConstructorUsedError;
  int? get limit => throw _privateConstructorUsedError;
  List<HomClass>? get data => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomNearClassesCopyWith<HomNearClasses> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomNearClassesCopyWith<$Res> {
  factory $HomNearClassesCopyWith(
          HomNearClasses value, $Res Function(HomNearClasses) then) =
      _$HomNearClassesCopyWithImpl<$Res, HomNearClasses>;
  @useResult
  $Res call({int? page, int? limit, List<HomClass>? data});
}

/// @nodoc
class _$HomNearClassesCopyWithImpl<$Res, $Val extends HomNearClasses>
    implements $HomNearClassesCopyWith<$Res> {
  _$HomNearClassesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? limit = freezed,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as List<HomClass>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomNearClassesImplCopyWith<$Res>
    implements $HomNearClassesCopyWith<$Res> {
  factory _$$HomNearClassesImplCopyWith(_$HomNearClassesImpl value,
          $Res Function(_$HomNearClassesImpl) then) =
      __$$HomNearClassesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? page, int? limit, List<HomClass>? data});
}

/// @nodoc
class __$$HomNearClassesImplCopyWithImpl<$Res>
    extends _$HomNearClassesCopyWithImpl<$Res, _$HomNearClassesImpl>
    implements _$$HomNearClassesImplCopyWith<$Res> {
  __$$HomNearClassesImplCopyWithImpl(
      _$HomNearClassesImpl _value, $Res Function(_$HomNearClassesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = freezed,
    Object? limit = freezed,
    Object? data = freezed,
  }) {
    return _then(_$HomNearClassesImpl(
      page: freezed == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int?,
      limit: freezed == limit
          ? _value.limit
          : limit // ignore: cast_nullable_to_non_nullable
              as int?,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as List<HomClass>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HomNearClassesImpl implements _HomNearClasses {
  const _$HomNearClassesImpl(
      {this.page, this.limit, final List<HomClass>? data})
      : _data = data;

  factory _$HomNearClassesImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomNearClassesImplFromJson(json);

  @override
  final int? page;
  @override
  final int? limit;
  final List<HomClass>? _data;
  @override
  List<HomClass>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableListView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'HomNearClasses(page: $page, limit: $limit, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomNearClassesImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.limit, limit) || other.limit == limit) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, page, limit, const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomNearClassesImplCopyWith<_$HomNearClassesImpl> get copyWith =>
      __$$HomNearClassesImplCopyWithImpl<_$HomNearClassesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomNearClassesImplToJson(
      this,
    );
  }
}

abstract class _HomNearClasses implements HomNearClasses {
  const factory _HomNearClasses(
      {final int? page,
      final int? limit,
      final List<HomClass>? data}) = _$HomNearClassesImpl;

  factory _HomNearClasses.fromJson(Map<String, dynamic> json) =
      _$HomNearClassesImpl.fromJson;

  @override
  int? get page;
  @override
  int? get limit;
  @override
  List<HomClass>? get data;
  @override
  @JsonKey(ignore: true)
  _$$HomNearClassesImplCopyWith<_$HomNearClassesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomClass _$HomClassFromJson(Map<String, dynamic> json) {
  return _HomClass.fromJson(json);
}

/// @nodoc
mixin _$HomClass {
  String? get id => throw _privateConstructorUsedError;
  HomBranch? get branch => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;
  num? get price => throw _privateConstructorUsedError;
  num? get trialPrice => throw _privateConstructorUsedError;
  bool? get trialEnabled => throw _privateConstructorUsedError;
  int? get minAge => throw _privateConstructorUsedError;
  int? get maxAge => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  bool? get hasPhoto => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  double? get distance => throw _privateConstructorUsedError;
  String? get videoUrl => throw _privateConstructorUsedError;
  String? get videoProvider => throw _privateConstructorUsedError;
  int? get discountPercentage =>
      throw _privateConstructorUsedError; // ── course fields (present only on cards from the `courses` section) ────
  bool? get isCourse => throw _privateConstructorUsedError;

  /// How many trial lessons the course sells (normally 3).
  int? get trialLessons => throw _privateConstructorUsedError;

  /// Price of the WHOLE course. `trialPrice` above is the trial total.
  num? get coursePrice => throw _privateConstructorUsedError;

  /// Cohort size for full enrolment. null = unlimited.
  int? get seats => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get deletedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomClassCopyWith<HomClass> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomClassCopyWith<$Res> {
  factory $HomClassCopyWith(HomClass value, $Res Function(HomClass) then) =
      _$HomClassCopyWithImpl<$Res, HomClass>;
  @useResult
  $Res call(
      {String? id,
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
      bool? isCourse,
      int? trialLessons,
      num? coursePrice,
      int? seats,
      String? createdAt,
      String? updatedAt,
      String? deletedAt});

  $HomBranchCopyWith<$Res>? get branch;
}

/// @nodoc
class _$HomClassCopyWithImpl<$Res, $Val extends HomClass>
    implements $HomClassCopyWith<$Res> {
  _$HomClassCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? branch = freezed,
    Object? category = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? duration = freezed,
    Object? price = freezed,
    Object? trialPrice = freezed,
    Object? trialEnabled = freezed,
    Object? minAge = freezed,
    Object? maxAge = freezed,
    Object? gender = freezed,
    Object? isActive = freezed,
    Object? hasPhoto = freezed,
    Object? image = freezed,
    Object? distance = freezed,
    Object? videoUrl = freezed,
    Object? videoProvider = freezed,
    Object? discountPercentage = freezed,
    Object? isCourse = freezed,
    Object? trialLessons = freezed,
    Object? coursePrice = freezed,
    Object? seats = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      branch: freezed == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as HomBranch?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num?,
      trialPrice: freezed == trialPrice
          ? _value.trialPrice
          : trialPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      trialEnabled: freezed == trialEnabled
          ? _value.trialEnabled
          : trialEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      minAge: freezed == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int?,
      maxAge: freezed == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoProvider: freezed == videoProvider
          ? _value.videoProvider
          : videoProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPercentage: freezed == discountPercentage
          ? _value.discountPercentage
          : discountPercentage // ignore: cast_nullable_to_non_nullable
              as int?,
      isCourse: freezed == isCourse
          ? _value.isCourse
          : isCourse // ignore: cast_nullable_to_non_nullable
              as bool?,
      trialLessons: freezed == trialLessons
          ? _value.trialLessons
          : trialLessons // ignore: cast_nullable_to_non_nullable
              as int?,
      coursePrice: freezed == coursePrice
          ? _value.coursePrice
          : coursePrice // ignore: cast_nullable_to_non_nullable
              as num?,
      seats: freezed == seats
          ? _value.seats
          : seats // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomBranchCopyWith<$Res>? get branch {
    if (_value.branch == null) {
      return null;
    }

    return $HomBranchCopyWith<$Res>(_value.branch!, (value) {
      return _then(_value.copyWith(branch: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomClassImplCopyWith<$Res>
    implements $HomClassCopyWith<$Res> {
  factory _$$HomClassImplCopyWith(
          _$HomClassImpl value, $Res Function(_$HomClassImpl) then) =
      __$$HomClassImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
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
      bool? isCourse,
      int? trialLessons,
      num? coursePrice,
      int? seats,
      String? createdAt,
      String? updatedAt,
      String? deletedAt});

  @override
  $HomBranchCopyWith<$Res>? get branch;
}

/// @nodoc
class __$$HomClassImplCopyWithImpl<$Res>
    extends _$HomClassCopyWithImpl<$Res, _$HomClassImpl>
    implements _$$HomClassImplCopyWith<$Res> {
  __$$HomClassImplCopyWithImpl(
      _$HomClassImpl _value, $Res Function(_$HomClassImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? branch = freezed,
    Object? category = freezed,
    Object? title = freezed,
    Object? description = freezed,
    Object? duration = freezed,
    Object? price = freezed,
    Object? trialPrice = freezed,
    Object? trialEnabled = freezed,
    Object? minAge = freezed,
    Object? maxAge = freezed,
    Object? gender = freezed,
    Object? isActive = freezed,
    Object? hasPhoto = freezed,
    Object? image = freezed,
    Object? distance = freezed,
    Object? videoUrl = freezed,
    Object? videoProvider = freezed,
    Object? discountPercentage = freezed,
    Object? isCourse = freezed,
    Object? trialLessons = freezed,
    Object? coursePrice = freezed,
    Object? seats = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_$HomClassImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      branch: freezed == branch
          ? _value.branch
          : branch // ignore: cast_nullable_to_non_nullable
              as HomBranch?,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      duration: freezed == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as int?,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as num?,
      trialPrice: freezed == trialPrice
          ? _value.trialPrice
          : trialPrice // ignore: cast_nullable_to_non_nullable
              as num?,
      trialEnabled: freezed == trialEnabled
          ? _value.trialEnabled
          : trialEnabled // ignore: cast_nullable_to_non_nullable
              as bool?,
      minAge: freezed == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int?,
      maxAge: freezed == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      videoUrl: freezed == videoUrl
          ? _value.videoUrl
          : videoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      videoProvider: freezed == videoProvider
          ? _value.videoProvider
          : videoProvider // ignore: cast_nullable_to_non_nullable
              as String?,
      discountPercentage: freezed == discountPercentage
          ? _value.discountPercentage
          : discountPercentage // ignore: cast_nullable_to_non_nullable
              as int?,
      isCourse: freezed == isCourse
          ? _value.isCourse
          : isCourse // ignore: cast_nullable_to_non_nullable
              as bool?,
      trialLessons: freezed == trialLessons
          ? _value.trialLessons
          : trialLessons // ignore: cast_nullable_to_non_nullable
              as int?,
      coursePrice: freezed == coursePrice
          ? _value.coursePrice
          : coursePrice // ignore: cast_nullable_to_non_nullable
              as num?,
      seats: freezed == seats
          ? _value.seats
          : seats // ignore: cast_nullable_to_non_nullable
              as int?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomClassImpl implements _HomClass {
  const _$HomClassImpl(
      {this.id,
      this.branch,
      this.category,
      this.title,
      this.description,
      this.duration,
      this.price,
      this.trialPrice,
      this.trialEnabled,
      this.minAge,
      this.maxAge,
      this.gender,
      this.isActive,
      this.hasPhoto,
      this.image,
      this.distance,
      this.videoUrl,
      this.videoProvider,
      this.discountPercentage,
      this.isCourse,
      this.trialLessons,
      this.coursePrice,
      this.seats,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  factory _$HomClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomClassImplFromJson(json);

  @override
  final String? id;
  @override
  final HomBranch? branch;
  @override
  final String? category;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final int? duration;
  @override
  final num? price;
  @override
  final num? trialPrice;
  @override
  final bool? trialEnabled;
  @override
  final int? minAge;
  @override
  final int? maxAge;
  @override
  final String? gender;
  @override
  final bool? isActive;
  @override
  final bool? hasPhoto;
  @override
  final String? image;
  @override
  final double? distance;
  @override
  final String? videoUrl;
  @override
  final String? videoProvider;
  @override
  final int? discountPercentage;
// ── course fields (present only on cards from the `courses` section) ────
  @override
  final bool? isCourse;

  /// How many trial lessons the course sells (normally 3).
  @override
  final int? trialLessons;

  /// Price of the WHOLE course. `trialPrice` above is the trial total.
  @override
  final num? coursePrice;

  /// Cohort size for full enrolment. null = unlimited.
  @override
  final int? seats;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final String? deletedAt;

  @override
  String toString() {
    return 'HomClass(id: $id, branch: $branch, category: $category, title: $title, description: $description, duration: $duration, price: $price, trialPrice: $trialPrice, trialEnabled: $trialEnabled, minAge: $minAge, maxAge: $maxAge, gender: $gender, isActive: $isActive, hasPhoto: $hasPhoto, image: $image, distance: $distance, videoUrl: $videoUrl, videoProvider: $videoProvider, discountPercentage: $discountPercentage, isCourse: $isCourse, trialLessons: $trialLessons, coursePrice: $coursePrice, seats: $seats, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomClassImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.branch, branch) || other.branch == branch) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.trialPrice, trialPrice) ||
                other.trialPrice == trialPrice) &&
            (identical(other.trialEnabled, trialEnabled) ||
                other.trialEnabled == trialEnabled) &&
            (identical(other.minAge, minAge) || other.minAge == minAge) &&
            (identical(other.maxAge, maxAge) || other.maxAge == maxAge) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.hasPhoto, hasPhoto) ||
                other.hasPhoto == hasPhoto) &&
            (identical(other.image, image) || other.image == image) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.videoProvider, videoProvider) ||
                other.videoProvider == videoProvider) &&
            (identical(other.discountPercentage, discountPercentage) ||
                other.discountPercentage == discountPercentage) &&
            (identical(other.isCourse, isCourse) ||
                other.isCourse == isCourse) &&
            (identical(other.trialLessons, trialLessons) ||
                other.trialLessons == trialLessons) &&
            (identical(other.coursePrice, coursePrice) ||
                other.coursePrice == coursePrice) &&
            (identical(other.seats, seats) || other.seats == seats) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        branch,
        category,
        title,
        description,
        duration,
        price,
        trialPrice,
        trialEnabled,
        minAge,
        maxAge,
        gender,
        isActive,
        hasPhoto,
        image,
        distance,
        videoUrl,
        videoProvider,
        discountPercentage,
        isCourse,
        trialLessons,
        coursePrice,
        seats,
        createdAt,
        updatedAt,
        deletedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomClassImplCopyWith<_$HomClassImpl> get copyWith =>
      __$$HomClassImplCopyWithImpl<_$HomClassImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomClassImplToJson(
      this,
    );
  }
}

abstract class _HomClass implements HomClass {
  const factory _HomClass(
      {final String? id,
      final HomBranch? branch,
      final String? category,
      final String? title,
      final String? description,
      final int? duration,
      final num? price,
      final num? trialPrice,
      final bool? trialEnabled,
      final int? minAge,
      final int? maxAge,
      final String? gender,
      final bool? isActive,
      final bool? hasPhoto,
      final String? image,
      final double? distance,
      final String? videoUrl,
      final String? videoProvider,
      final int? discountPercentage,
      final bool? isCourse,
      final int? trialLessons,
      final num? coursePrice,
      final int? seats,
      final String? createdAt,
      final String? updatedAt,
      final String? deletedAt}) = _$HomClassImpl;

  factory _HomClass.fromJson(Map<String, dynamic> json) =
      _$HomClassImpl.fromJson;

  @override
  String? get id;
  @override
  HomBranch? get branch;
  @override
  String? get category;
  @override
  String? get title;
  @override
  String? get description;
  @override
  int? get duration;
  @override
  num? get price;
  @override
  num? get trialPrice;
  @override
  bool? get trialEnabled;
  @override
  int? get minAge;
  @override
  int? get maxAge;
  @override
  String? get gender;
  @override
  bool? get isActive;
  @override
  bool? get hasPhoto;
  @override
  String? get image;
  @override
  double? get distance;
  @override
  String? get videoUrl;
  @override
  String? get videoProvider;
  @override
  int? get discountPercentage;
  @override // ── course fields (present only on cards from the `courses` section) ────
  bool? get isCourse;
  @override

  /// How many trial lessons the course sells (normally 3).
  int? get trialLessons;
  @override

  /// Price of the WHOLE course. `trialPrice` above is the trial total.
  num? get coursePrice;
  @override

  /// Cohort size for full enrolment. null = unlimited.
  int? get seats;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  String? get deletedAt;
  @override
  @JsonKey(ignore: true)
  _$$HomClassImplCopyWith<_$HomClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomUpcomingClass _$HomUpcomingClassFromJson(Map<String, dynamic> json) {
  return _HomUpcomingClass.fromJson(json);
}

/// @nodoc
mixin _$HomUpcomingClass {
  String? get classId => throw _privateConstructorUsedError;
  String? get scheduleId => throw _privateConstructorUsedError;
  String? get bookingId => throw _privateConstructorUsedError;
  String? get className => throw _privateConstructorUsedError;
  String? get branchName => throw _privateConstructorUsedError;
  String? get branchAddress => throw _privateConstructorUsedError;
  String? get categoryName => throw _privateConstructorUsedError;
  DateTime? get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;
  int? get count => throw _privateConstructorUsedError;
  String? get distance => throw _privateConstructorUsedError;
  HomChildData? get forChild => throw _privateConstructorUsedError;
  List<HomRelatedBooking>? get relatedBookings =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomUpcomingClassCopyWith<HomUpcomingClass> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomUpcomingClassCopyWith<$Res> {
  factory $HomUpcomingClassCopyWith(
          HomUpcomingClass value, $Res Function(HomUpcomingClass) then) =
      _$HomUpcomingClassCopyWithImpl<$Res, HomUpcomingClass>;
  @useResult
  $Res call(
      {String? classId,
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
      List<HomRelatedBooking>? relatedBookings});

  $HomChildDataCopyWith<$Res>? get forChild;
}

/// @nodoc
class _$HomUpcomingClassCopyWithImpl<$Res, $Val extends HomUpcomingClass>
    implements $HomUpcomingClassCopyWith<$Res> {
  _$HomUpcomingClassCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = freezed,
    Object? scheduleId = freezed,
    Object? bookingId = freezed,
    Object? className = freezed,
    Object? branchName = freezed,
    Object? branchAddress = freezed,
    Object? categoryName = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? count = freezed,
    Object? distance = freezed,
    Object? forChild = freezed,
    Object? relatedBookings = freezed,
  }) {
    return _then(_value.copyWith(
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      className: freezed == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      branchName: freezed == branchName
          ? _value.branchName
          : branchName // ignore: cast_nullable_to_non_nullable
              as String?,
      branchAddress: freezed == branchAddress
          ? _value.branchAddress
          : branchAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String?,
      forChild: freezed == forChild
          ? _value.forChild
          : forChild // ignore: cast_nullable_to_non_nullable
              as HomChildData?,
      relatedBookings: freezed == relatedBookings
          ? _value.relatedBookings
          : relatedBookings // ignore: cast_nullable_to_non_nullable
              as List<HomRelatedBooking>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomChildDataCopyWith<$Res>? get forChild {
    if (_value.forChild == null) {
      return null;
    }

    return $HomChildDataCopyWith<$Res>(_value.forChild!, (value) {
      return _then(_value.copyWith(forChild: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomUpcomingClassImplCopyWith<$Res>
    implements $HomUpcomingClassCopyWith<$Res> {
  factory _$$HomUpcomingClassImplCopyWith(_$HomUpcomingClassImpl value,
          $Res Function(_$HomUpcomingClassImpl) then) =
      __$$HomUpcomingClassImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? classId,
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
      List<HomRelatedBooking>? relatedBookings});

  @override
  $HomChildDataCopyWith<$Res>? get forChild;
}

/// @nodoc
class __$$HomUpcomingClassImplCopyWithImpl<$Res>
    extends _$HomUpcomingClassCopyWithImpl<$Res, _$HomUpcomingClassImpl>
    implements _$$HomUpcomingClassImplCopyWith<$Res> {
  __$$HomUpcomingClassImplCopyWithImpl(_$HomUpcomingClassImpl _value,
      $Res Function(_$HomUpcomingClassImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? classId = freezed,
    Object? scheduleId = freezed,
    Object? bookingId = freezed,
    Object? className = freezed,
    Object? branchName = freezed,
    Object? branchAddress = freezed,
    Object? categoryName = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? count = freezed,
    Object? distance = freezed,
    Object? forChild = freezed,
    Object? relatedBookings = freezed,
  }) {
    return _then(_$HomUpcomingClassImpl(
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingId: freezed == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String?,
      className: freezed == className
          ? _value.className
          : className // ignore: cast_nullable_to_non_nullable
              as String?,
      branchName: freezed == branchName
          ? _value.branchName
          : branchName // ignore: cast_nullable_to_non_nullable
              as String?,
      branchAddress: freezed == branchAddress
          ? _value.branchAddress
          : branchAddress // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryName: freezed == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String?,
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      count: freezed == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String?,
      forChild: freezed == forChild
          ? _value.forChild
          : forChild // ignore: cast_nullable_to_non_nullable
              as HomChildData?,
      relatedBookings: freezed == relatedBookings
          ? _value._relatedBookings
          : relatedBookings // ignore: cast_nullable_to_non_nullable
              as List<HomRelatedBooking>?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomUpcomingClassImpl implements _HomUpcomingClass {
  const _$HomUpcomingClassImpl(
      {this.classId,
      this.scheduleId,
      this.bookingId,
      this.className,
      this.branchName,
      this.branchAddress,
      this.categoryName,
      this.startTime,
      this.endTime,
      this.count,
      this.distance,
      this.forChild,
      final List<HomRelatedBooking>? relatedBookings})
      : _relatedBookings = relatedBookings;

  factory _$HomUpcomingClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomUpcomingClassImplFromJson(json);

  @override
  final String? classId;
  @override
  final String? scheduleId;
  @override
  final String? bookingId;
  @override
  final String? className;
  @override
  final String? branchName;
  @override
  final String? branchAddress;
  @override
  final String? categoryName;
  @override
  final DateTime? startTime;
  @override
  final DateTime? endTime;
  @override
  final int? count;
  @override
  final String? distance;
  @override
  final HomChildData? forChild;
  final List<HomRelatedBooking>? _relatedBookings;
  @override
  List<HomRelatedBooking>? get relatedBookings {
    final value = _relatedBookings;
    if (value == null) return null;
    if (_relatedBookings is EqualUnmodifiableListView) return _relatedBookings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'HomUpcomingClass(classId: $classId, scheduleId: $scheduleId, bookingId: $bookingId, className: $className, branchName: $branchName, branchAddress: $branchAddress, categoryName: $categoryName, startTime: $startTime, endTime: $endTime, count: $count, distance: $distance, forChild: $forChild, relatedBookings: $relatedBookings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomUpcomingClassImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.branchAddress, branchAddress) ||
                other.branchAddress == branchAddress) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.forChild, forChild) ||
                other.forChild == forChild) &&
            const DeepCollectionEquality()
                .equals(other._relatedBookings, _relatedBookings));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      classId,
      scheduleId,
      bookingId,
      className,
      branchName,
      branchAddress,
      categoryName,
      startTime,
      endTime,
      count,
      distance,
      forChild,
      const DeepCollectionEquality().hash(_relatedBookings));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomUpcomingClassImplCopyWith<_$HomUpcomingClassImpl> get copyWith =>
      __$$HomUpcomingClassImplCopyWithImpl<_$HomUpcomingClassImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomUpcomingClassImplToJson(
      this,
    );
  }
}

abstract class _HomUpcomingClass implements HomUpcomingClass {
  const factory _HomUpcomingClass(
      {final String? classId,
      final String? scheduleId,
      final String? bookingId,
      final String? className,
      final String? branchName,
      final String? branchAddress,
      final String? categoryName,
      final DateTime? startTime,
      final DateTime? endTime,
      final int? count,
      final String? distance,
      final HomChildData? forChild,
      final List<HomRelatedBooking>? relatedBookings}) = _$HomUpcomingClassImpl;

  factory _HomUpcomingClass.fromJson(Map<String, dynamic> json) =
      _$HomUpcomingClassImpl.fromJson;

  @override
  String? get classId;
  @override
  String? get scheduleId;
  @override
  String? get bookingId;
  @override
  String? get className;
  @override
  String? get branchName;
  @override
  String? get branchAddress;
  @override
  String? get categoryName;
  @override
  DateTime? get startTime;
  @override
  DateTime? get endTime;
  @override
  int? get count;
  @override
  String? get distance;
  @override
  HomChildData? get forChild;
  @override
  List<HomRelatedBooking>? get relatedBookings;
  @override
  @JsonKey(ignore: true)
  _$$HomUpcomingClassImplCopyWith<_$HomUpcomingClassImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomChildData _$HomChildDataFromJson(Map<String, dynamic> json) {
  return _HomChildData.fromJson(json);
}

/// @nodoc
mixin _$HomChildData {
  String? get id => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get childAgeType => throw _privateConstructorUsedError;
  bool? get isEligible => throw _privateConstructorUsedError;
  bool? get hasPhoto => throw _privateConstructorUsedError;
  bool? get isVerified => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomChildDataCopyWith<HomChildData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomChildDataCopyWith<$Res> {
  factory $HomChildDataCopyWith(
          HomChildData value, $Res Function(HomChildData) then) =
      _$HomChildDataCopyWithImpl<$Res, HomChildData>;
  @useResult
  $Res call(
      {String? id,
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
      String? updatedAt});
}

/// @nodoc
class _$HomChildDataCopyWithImpl<$Res, $Val extends HomChildData>
    implements $HomChildDataCopyWith<$Res> {
  _$HomChildDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? parentId = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? type = freezed,
    Object? age = freezed,
    Object? childAgeType = freezed,
    Object? isEligible = freezed,
    Object? hasPhoto = freezed,
    Object? isVerified = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      childAgeType: freezed == childAgeType
          ? _value.childAgeType
          : childAgeType // ignore: cast_nullable_to_non_nullable
              as String?,
      isEligible: freezed == isEligible
          ? _value.isEligible
          : isEligible // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomChildDataImplCopyWith<$Res>
    implements $HomChildDataCopyWith<$Res> {
  factory _$$HomChildDataImplCopyWith(
          _$HomChildDataImpl value, $Res Function(_$HomChildDataImpl) then) =
      __$$HomChildDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
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
      String? updatedAt});
}

/// @nodoc
class __$$HomChildDataImplCopyWithImpl<$Res>
    extends _$HomChildDataCopyWithImpl<$Res, _$HomChildDataImpl>
    implements _$$HomChildDataImplCopyWith<$Res> {
  __$$HomChildDataImplCopyWithImpl(
      _$HomChildDataImpl _value, $Res Function(_$HomChildDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? parentId = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? type = freezed,
    Object? age = freezed,
    Object? childAgeType = freezed,
    Object? isEligible = freezed,
    Object? hasPhoto = freezed,
    Object? isVerified = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$HomChildDataImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      childAgeType: freezed == childAgeType
          ? _value.childAgeType
          : childAgeType // ignore: cast_nullable_to_non_nullable
              as String?,
      isEligible: freezed == isEligible
          ? _value.isEligible
          : isEligible // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomChildDataImpl implements _HomChildData {
  const _$HomChildDataImpl(
      {this.id,
      this.parentId,
      this.firstName,
      this.lastName,
      this.type,
      this.age,
      this.childAgeType,
      this.isEligible,
      this.hasPhoto,
      this.isVerified,
      this.createdAt,
      this.updatedAt});

  factory _$HomChildDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomChildDataImplFromJson(json);

  @override
  final String? id;
  @override
  final String? parentId;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  final String? type;
  @override
  final int? age;
  @override
  final String? childAgeType;
  @override
  final bool? isEligible;
  @override
  final bool? hasPhoto;
  @override
  final bool? isVerified;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'HomChildData(id: $id, parentId: $parentId, firstName: $firstName, lastName: $lastName, type: $type, age: $age, childAgeType: $childAgeType, isEligible: $isEligible, hasPhoto: $hasPhoto, isVerified: $isVerified, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomChildDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.childAgeType, childAgeType) ||
                other.childAgeType == childAgeType) &&
            (identical(other.isEligible, isEligible) ||
                other.isEligible == isEligible) &&
            (identical(other.hasPhoto, hasPhoto) ||
                other.hasPhoto == hasPhoto) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      parentId,
      firstName,
      lastName,
      type,
      age,
      childAgeType,
      isEligible,
      hasPhoto,
      isVerified,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomChildDataImplCopyWith<_$HomChildDataImpl> get copyWith =>
      __$$HomChildDataImplCopyWithImpl<_$HomChildDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomChildDataImplToJson(
      this,
    );
  }
}

abstract class _HomChildData implements HomChildData {
  const factory _HomChildData(
      {final String? id,
      final String? parentId,
      final String? firstName,
      final String? lastName,
      final String? type,
      final int? age,
      final String? childAgeType,
      final bool? isEligible,
      final bool? hasPhoto,
      final bool? isVerified,
      final String? createdAt,
      final String? updatedAt}) = _$HomChildDataImpl;

  factory _HomChildData.fromJson(Map<String, dynamic> json) =
      _$HomChildDataImpl.fromJson;

  @override
  String? get id;
  @override
  String? get parentId;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  String? get type;
  @override
  int? get age;
  @override
  String? get childAgeType;
  @override
  bool? get isEligible;
  @override
  bool? get hasPhoto;
  @override
  bool? get isVerified;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$HomChildDataImplCopyWith<_$HomChildDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomRelatedBooking _$HomRelatedBookingFromJson(Map<String, dynamic> json) {
  return _HomRelatedBooking.fromJson(json);
}

/// @nodoc
mixin _$HomRelatedBooking {
  String? get id => throw _privateConstructorUsedError;
  String? get scheduleId => throw _privateConstructorUsedError;
  String? get childId => throw _privateConstructorUsedError;
  String? get bookingStatus => throw _privateConstructorUsedError;
  num? get chargedCoinAmount => throw _privateConstructorUsedError;
  bool? get isTrialBooking => throw _privateConstructorUsedError;
  String? get attendanceStatus => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get deletedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomRelatedBookingCopyWith<HomRelatedBooking> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomRelatedBookingCopyWith<$Res> {
  factory $HomRelatedBookingCopyWith(
          HomRelatedBooking value, $Res Function(HomRelatedBooking) then) =
      _$HomRelatedBookingCopyWithImpl<$Res, HomRelatedBooking>;
  @useResult
  $Res call(
      {String? id,
      String? scheduleId,
      String? childId,
      String? bookingStatus,
      num? chargedCoinAmount,
      bool? isTrialBooking,
      String? attendanceStatus,
      String? createdAt,
      String? updatedAt,
      String? deletedAt});
}

/// @nodoc
class _$HomRelatedBookingCopyWithImpl<$Res, $Val extends HomRelatedBooking>
    implements $HomRelatedBookingCopyWith<$Res> {
  _$HomRelatedBookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? scheduleId = freezed,
    Object? childId = freezed,
    Object? bookingStatus = freezed,
    Object? chargedCoinAmount = freezed,
    Object? isTrialBooking = freezed,
    Object? attendanceStatus = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      chargedCoinAmount: freezed == chargedCoinAmount
          ? _value.chargedCoinAmount
          : chargedCoinAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      isTrialBooking: freezed == isTrialBooking
          ? _value.isTrialBooking
          : isTrialBooking // ignore: cast_nullable_to_non_nullable
              as bool?,
      attendanceStatus: freezed == attendanceStatus
          ? _value.attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomRelatedBookingImplCopyWith<$Res>
    implements $HomRelatedBookingCopyWith<$Res> {
  factory _$$HomRelatedBookingImplCopyWith(_$HomRelatedBookingImpl value,
          $Res Function(_$HomRelatedBookingImpl) then) =
      __$$HomRelatedBookingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String? scheduleId,
      String? childId,
      String? bookingStatus,
      num? chargedCoinAmount,
      bool? isTrialBooking,
      String? attendanceStatus,
      String? createdAt,
      String? updatedAt,
      String? deletedAt});
}

/// @nodoc
class __$$HomRelatedBookingImplCopyWithImpl<$Res>
    extends _$HomRelatedBookingCopyWithImpl<$Res, _$HomRelatedBookingImpl>
    implements _$$HomRelatedBookingImplCopyWith<$Res> {
  __$$HomRelatedBookingImplCopyWithImpl(_$HomRelatedBookingImpl _value,
      $Res Function(_$HomRelatedBookingImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? scheduleId = freezed,
    Object? childId = freezed,
    Object? bookingStatus = freezed,
    Object? chargedCoinAmount = freezed,
    Object? isTrialBooking = freezed,
    Object? attendanceStatus = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_$HomRelatedBookingImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      scheduleId: freezed == scheduleId
          ? _value.scheduleId
          : scheduleId // ignore: cast_nullable_to_non_nullable
              as String?,
      childId: freezed == childId
          ? _value.childId
          : childId // ignore: cast_nullable_to_non_nullable
              as String?,
      bookingStatus: freezed == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      chargedCoinAmount: freezed == chargedCoinAmount
          ? _value.chargedCoinAmount
          : chargedCoinAmount // ignore: cast_nullable_to_non_nullable
              as num?,
      isTrialBooking: freezed == isTrialBooking
          ? _value.isTrialBooking
          : isTrialBooking // ignore: cast_nullable_to_non_nullable
              as bool?,
      attendanceStatus: freezed == attendanceStatus
          ? _value.attendanceStatus
          : attendanceStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomRelatedBookingImpl implements _HomRelatedBooking {
  const _$HomRelatedBookingImpl(
      {this.id,
      this.scheduleId,
      this.childId,
      this.bookingStatus,
      this.chargedCoinAmount,
      this.isTrialBooking,
      this.attendanceStatus,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  factory _$HomRelatedBookingImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomRelatedBookingImplFromJson(json);

  @override
  final String? id;
  @override
  final String? scheduleId;
  @override
  final String? childId;
  @override
  final String? bookingStatus;
  @override
  final num? chargedCoinAmount;
  @override
  final bool? isTrialBooking;
  @override
  final String? attendanceStatus;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final String? deletedAt;

  @override
  String toString() {
    return 'HomRelatedBooking(id: $id, scheduleId: $scheduleId, childId: $childId, bookingStatus: $bookingStatus, chargedCoinAmount: $chargedCoinAmount, isTrialBooking: $isTrialBooking, attendanceStatus: $attendanceStatus, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomRelatedBookingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.scheduleId, scheduleId) ||
                other.scheduleId == scheduleId) &&
            (identical(other.childId, childId) || other.childId == childId) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.chargedCoinAmount, chargedCoinAmount) ||
                other.chargedCoinAmount == chargedCoinAmount) &&
            (identical(other.isTrialBooking, isTrialBooking) ||
                other.isTrialBooking == isTrialBooking) &&
            (identical(other.attendanceStatus, attendanceStatus) ||
                other.attendanceStatus == attendanceStatus) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      scheduleId,
      childId,
      bookingStatus,
      chargedCoinAmount,
      isTrialBooking,
      attendanceStatus,
      createdAt,
      updatedAt,
      deletedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomRelatedBookingImplCopyWith<_$HomRelatedBookingImpl> get copyWith =>
      __$$HomRelatedBookingImplCopyWithImpl<_$HomRelatedBookingImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomRelatedBookingImplToJson(
      this,
    );
  }
}

abstract class _HomRelatedBooking implements HomRelatedBooking {
  const factory _HomRelatedBooking(
      {final String? id,
      final String? scheduleId,
      final String? childId,
      final String? bookingStatus,
      final num? chargedCoinAmount,
      final bool? isTrialBooking,
      final String? attendanceStatus,
      final String? createdAt,
      final String? updatedAt,
      final String? deletedAt}) = _$HomRelatedBookingImpl;

  factory _HomRelatedBooking.fromJson(Map<String, dynamic> json) =
      _$HomRelatedBookingImpl.fromJson;

  @override
  String? get id;
  @override
  String? get scheduleId;
  @override
  String? get childId;
  @override
  String? get bookingStatus;
  @override
  num? get chargedCoinAmount;
  @override
  bool? get isTrialBooking;
  @override
  String? get attendanceStatus;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  String? get deletedAt;
  @override
  @JsonKey(ignore: true)
  _$$HomRelatedBookingImplCopyWith<_$HomRelatedBookingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CoinFlow _$CoinFlowFromJson(Map<String, dynamic> json) {
  return _CoinFlow.fromJson(json);
}

/// @nodoc
mixin _$CoinFlow {
  String? get id => throw _privateConstructorUsedError;
  num? get amount => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CoinFlowCopyWith<CoinFlow> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoinFlowCopyWith<$Res> {
  factory $CoinFlowCopyWith(CoinFlow value, $Res Function(CoinFlow) then) =
      _$CoinFlowCopyWithImpl<$Res, CoinFlow>;
  @useResult
  $Res call({String? id, num? amount, String? type, String? createdAt});
}

/// @nodoc
class _$CoinFlowCopyWithImpl<$Res, $Val extends CoinFlow>
    implements $CoinFlowCopyWith<$Res> {
  _$CoinFlowCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? amount = freezed,
    Object? type = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoinFlowImplCopyWith<$Res>
    implements $CoinFlowCopyWith<$Res> {
  factory _$$CoinFlowImplCopyWith(
          _$CoinFlowImpl value, $Res Function(_$CoinFlowImpl) then) =
      __$$CoinFlowImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, num? amount, String? type, String? createdAt});
}

/// @nodoc
class __$$CoinFlowImplCopyWithImpl<$Res>
    extends _$CoinFlowCopyWithImpl<$Res, _$CoinFlowImpl>
    implements _$$CoinFlowImplCopyWith<$Res> {
  __$$CoinFlowImplCopyWithImpl(
      _$CoinFlowImpl _value, $Res Function(_$CoinFlowImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? amount = freezed,
    Object? type = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_$CoinFlowImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: freezed == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as num?,
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$CoinFlowImpl implements _CoinFlow {
  const _$CoinFlowImpl({this.id, this.amount, this.type, this.createdAt});

  factory _$CoinFlowImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoinFlowImplFromJson(json);

  @override
  final String? id;
  @override
  final num? amount;
  @override
  final String? type;
  @override
  final String? createdAt;

  @override
  String toString() {
    return 'CoinFlow(id: $id, amount: $amount, type: $type, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoinFlowImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, amount, type, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CoinFlowImplCopyWith<_$CoinFlowImpl> get copyWith =>
      __$$CoinFlowImplCopyWithImpl<_$CoinFlowImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoinFlowImplToJson(
      this,
    );
  }
}

abstract class _CoinFlow implements CoinFlow {
  const factory _CoinFlow(
      {final String? id,
      final num? amount,
      final String? type,
      final String? createdAt}) = _$CoinFlowImpl;

  factory _CoinFlow.fromJson(Map<String, dynamic> json) =
      _$CoinFlowImpl.fromJson;

  @override
  String? get id;
  @override
  num? get amount;
  @override
  String? get type;
  @override
  String? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$CoinFlowImplCopyWith<_$CoinFlowImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

HomBranch _$HomBranchFromJson(Map<String, dynamic> json) {
  return _HomBranch.fromJson(json);
}

/// @nodoc
mixin _$HomBranch {
  String? get id => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;
  String? get landmark => throw _privateConstructorUsedError;
  double? get longitude => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  String? get partnerId => throw _privateConstructorUsedError;
  String? get managerId => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  double? get distance => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  bool? get hasPhoto => throw _privateConstructorUsedError;
  String? get image => throw _privateConstructorUsedError;
  List<String>? get images => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  String? get deletedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $HomBranchCopyWith<HomBranch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomBranchCopyWith<$Res> {
  factory $HomBranchCopyWith(HomBranch value, $Res Function(HomBranch) then) =
      _$HomBranchCopyWithImpl<$Res, HomBranch>;
  @useResult
  $Res call(
      {String? id,
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
      String? deletedAt});
}

/// @nodoc
class _$HomBranchCopyWithImpl<$Res, $Val extends HomBranch>
    implements $HomBranchCopyWith<$Res> {
  _$HomBranchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? address = freezed,
    Object? landmark = freezed,
    Object? longitude = freezed,
    Object? latitude = freezed,
    Object? partnerId = freezed,
    Object? managerId = freezed,
    Object? description = freezed,
    Object? distance = freezed,
    Object? isActive = freezed,
    Object? hasPhoto = freezed,
    Object? image = freezed,
    Object? images = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      landmark: freezed == landmark
          ? _value.landmark
          : landmark // ignore: cast_nullable_to_non_nullable
              as String?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      partnerId: freezed == partnerId
          ? _value.partnerId
          : partnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      managerId: freezed == managerId
          ? _value.managerId
          : managerId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomBranchImplCopyWith<$Res>
    implements $HomBranchCopyWith<$Res> {
  factory _$$HomBranchImplCopyWith(
          _$HomBranchImpl value, $Res Function(_$HomBranchImpl) then) =
      __$$HomBranchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
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
      String? deletedAt});
}

/// @nodoc
class __$$HomBranchImplCopyWithImpl<$Res>
    extends _$HomBranchCopyWithImpl<$Res, _$HomBranchImpl>
    implements _$$HomBranchImplCopyWith<$Res> {
  __$$HomBranchImplCopyWithImpl(
      _$HomBranchImpl _value, $Res Function(_$HomBranchImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = freezed,
    Object? address = freezed,
    Object? landmark = freezed,
    Object? longitude = freezed,
    Object? latitude = freezed,
    Object? partnerId = freezed,
    Object? managerId = freezed,
    Object? description = freezed,
    Object? distance = freezed,
    Object? isActive = freezed,
    Object? hasPhoto = freezed,
    Object? image = freezed,
    Object? images = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
  }) {
    return _then(_$HomBranchImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
      landmark: freezed == landmark
          ? _value.landmark
          : landmark // ignore: cast_nullable_to_non_nullable
              as String?,
      longitude: freezed == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      latitude: freezed == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      partnerId: freezed == partnerId
          ? _value.partnerId
          : partnerId // ignore: cast_nullable_to_non_nullable
              as String?,
      managerId: freezed == managerId
          ? _value.managerId
          : managerId // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as double?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool?,
      hasPhoto: freezed == hasPhoto
          ? _value.hasPhoto
          : hasPhoto // ignore: cast_nullable_to_non_nullable
              as bool?,
      image: freezed == image
          ? _value.image
          : image // ignore: cast_nullable_to_non_nullable
              as String?,
      images: freezed == images
          ? _value._images
          : images // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String?,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomBranchImpl implements _HomBranch {
  const _$HomBranchImpl(
      {this.id,
      this.title,
      this.address,
      this.landmark,
      this.longitude,
      this.latitude,
      this.partnerId,
      this.managerId,
      this.description,
      this.distance,
      this.isActive,
      this.hasPhoto,
      this.image,
      final List<String>? images,
      this.createdAt,
      this.updatedAt,
      this.deletedAt})
      : _images = images;

  factory _$HomBranchImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomBranchImplFromJson(json);

  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? address;
  @override
  final String? landmark;
  @override
  final double? longitude;
  @override
  final double? latitude;
  @override
  final String? partnerId;
  @override
  final String? managerId;
  @override
  final String? description;
  @override
  final double? distance;
  @override
  final bool? isActive;
  @override
  final bool? hasPhoto;
  @override
  final String? image;
  final List<String>? _images;
  @override
  List<String>? get images {
    final value = _images;
    if (value == null) return null;
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final String? deletedAt;

  @override
  String toString() {
    return 'HomBranch(id: $id, title: $title, address: $address, landmark: $landmark, longitude: $longitude, latitude: $latitude, partnerId: $partnerId, managerId: $managerId, description: $description, distance: $distance, isActive: $isActive, hasPhoto: $hasPhoto, image: $image, images: $images, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomBranchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.landmark, landmark) ||
                other.landmark == landmark) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.partnerId, partnerId) ||
                other.partnerId == partnerId) &&
            (identical(other.managerId, managerId) ||
                other.managerId == managerId) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.hasPhoto, hasPhoto) ||
                other.hasPhoto == hasPhoto) &&
            (identical(other.image, image) || other.image == image) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      address,
      landmark,
      longitude,
      latitude,
      partnerId,
      managerId,
      description,
      distance,
      isActive,
      hasPhoto,
      image,
      const DeepCollectionEquality().hash(_images),
      createdAt,
      updatedAt,
      deletedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomBranchImplCopyWith<_$HomBranchImpl> get copyWith =>
      __$$HomBranchImplCopyWithImpl<_$HomBranchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HomBranchImplToJson(
      this,
    );
  }
}

abstract class _HomBranch implements HomBranch {
  const factory _HomBranch(
      {final String? id,
      final String? title,
      final String? address,
      final String? landmark,
      final double? longitude,
      final double? latitude,
      final String? partnerId,
      final String? managerId,
      final String? description,
      final double? distance,
      final bool? isActive,
      final bool? hasPhoto,
      final String? image,
      final List<String>? images,
      final String? createdAt,
      final String? updatedAt,
      final String? deletedAt}) = _$HomBranchImpl;

  factory _HomBranch.fromJson(Map<String, dynamic> json) =
      _$HomBranchImpl.fromJson;

  @override
  String? get id;
  @override
  String? get title;
  @override
  String? get address;
  @override
  String? get landmark;
  @override
  double? get longitude;
  @override
  double? get latitude;
  @override
  String? get partnerId;
  @override
  String? get managerId;
  @override
  String? get description;
  @override
  double? get distance;
  @override
  bool? get isActive;
  @override
  bool? get hasPhoto;
  @override
  String? get image;
  @override
  List<String>? get images;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  String? get deletedAt;
  @override
  @JsonKey(ignore: true)
  _$$HomBranchImplCopyWith<_$HomBranchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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
  HomNearClasses? get nearClasses => throw _privateConstructorUsedError;

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
      HomNearClasses? nearClasses});

  $HomForUserCopyWith<$Res>? get forUser;
  $HomUpcomingClassCopyWith<$Res>? get upcomingClass;
  $HomCategoryPageCopyWith<$Res>? get categories;
  $HomClassPageCopyWith<$Res>? get newClasses;
  $HomNearClassesCopyWith<$Res>? get nearClasses;
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
      HomNearClasses? nearClasses});

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
      this.nearClasses})
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

  @override
  String toString() {
    return 'HomData(forUser: $forUser, upcomingClass: $upcomingClass, banners: $banners, categories: $categories, newClasses: $newClasses, nearClasses: $nearClasses)';
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
                other.nearClasses == nearClasses));
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
      nearClasses);

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
      final HomNearClasses? nearClasses}) = _$HomDataImpl;

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
      {this.id, this.title, this.url, this.createdAt, this.updatedAt});

  factory _$HomBannerImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomBannerImplFromJson(json);

  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? url;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'HomBanner(id: $id, title: $title, url: $url, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomBannerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, url, createdAt, updatedAt);

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
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

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
      String? createdAt,
      String? updatedAt});
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
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
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
      String? createdAt,
      String? updatedAt});
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
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
class _$HomCategoryImpl implements _HomCategory {
  const _$HomCategoryImpl(
      {this.id, this.title, this.description, this.createdAt, this.updatedAt});

  factory _$HomCategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomCategoryImplFromJson(json);

  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'HomCategory(id: $id, title: $title, description: $description, createdAt: $createdAt, updatedAt: $updatedAt)';
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
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, description, createdAt, updatedAt);

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
      final String? createdAt,
      final String? updatedAt}) = _$HomCategoryImpl;

  factory _HomCategory.fromJson(Map<String, dynamic> json) =
      _$HomCategoryImpl.fromJson;

  @override
  String? get id;
  @override
  String? get title;
  @override
  String? get description;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
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
  int? get minAge => throw _privateConstructorUsedError;
  int? get maxAge => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

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
      int? minAge,
      int? maxAge,
      bool? isActive,
      String? createdAt,
      String? updatedAt});

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
    Object? minAge = freezed,
    Object? maxAge = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      minAge: freezed == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int?,
      maxAge: freezed == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
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
      int? minAge,
      int? maxAge,
      bool? isActive,
      String? createdAt,
      String? updatedAt});

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
    Object? minAge = freezed,
    Object? maxAge = freezed,
    Object? isActive = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      minAge: freezed == minAge
          ? _value.minAge
          : minAge // ignore: cast_nullable_to_non_nullable
              as int?,
      maxAge: freezed == maxAge
          ? _value.maxAge
          : maxAge // ignore: cast_nullable_to_non_nullable
              as int?,
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
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
class _$HomClassImpl implements _HomClass {
  const _$HomClassImpl(
      {this.id,
      this.branch,
      this.category,
      this.title,
      this.description,
      this.duration,
      this.price,
      this.minAge,
      this.maxAge,
      this.isActive,
      this.createdAt,
      this.updatedAt});

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
  final int? minAge;
  @override
  final int? maxAge;
  @override
  final bool? isActive;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'HomClass(id: $id, branch: $branch, category: $category, title: $title, description: $description, duration: $duration, price: $price, minAge: $minAge, maxAge: $maxAge, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
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
            (identical(other.minAge, minAge) || other.minAge == minAge) &&
            (identical(other.maxAge, maxAge) || other.maxAge == maxAge) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
      branch,
      category,
      title,
      description,
      duration,
      price,
      minAge,
      maxAge,
      isActive,
      createdAt,
      updatedAt);

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
      final int? minAge,
      final int? maxAge,
      final bool? isActive,
      final String? createdAt,
      final String? updatedAt}) = _$HomClassImpl;

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
  int? get minAge;
  @override
  int? get maxAge;
  @override
  bool? get isActive;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
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
  String? get className => throw _privateConstructorUsedError;
  String? get branchName => throw _privateConstructorUsedError;
  String? get branchAddress => throw _privateConstructorUsedError;
  DateTime? get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;

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
      String? className,
      String? branchName,
      String? branchAddress,
      DateTime? startTime,
      DateTime? endTime});
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
    Object? className = freezed,
    Object? branchName = freezed,
    Object? branchAddress = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
  }) {
    return _then(_value.copyWith(
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
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
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
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
      String? className,
      String? branchName,
      String? branchAddress,
      DateTime? startTime,
      DateTime? endTime});
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
    Object? className = freezed,
    Object? branchName = freezed,
    Object? branchAddress = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
  }) {
    return _then(_$HomUpcomingClassImpl(
      classId: freezed == classId
          ? _value.classId
          : classId // ignore: cast_nullable_to_non_nullable
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
      startTime: freezed == startTime
          ? _value.startTime
          : startTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endTime: freezed == endTime
          ? _value.endTime
          : endTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$HomUpcomingClassImpl implements _HomUpcomingClass {
  const _$HomUpcomingClassImpl(
      {this.classId,
      this.className,
      this.branchName,
      this.branchAddress,
      this.startTime,
      this.endTime});

  factory _$HomUpcomingClassImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomUpcomingClassImplFromJson(json);

  @override
  final String? classId;
  @override
  final String? className;
  @override
  final String? branchName;
  @override
  final String? branchAddress;
  @override
  final DateTime? startTime;
  @override
  final DateTime? endTime;

  @override
  String toString() {
    return 'HomUpcomingClass(classId: $classId, className: $className, branchName: $branchName, branchAddress: $branchAddress, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomUpcomingClassImpl &&
            (identical(other.classId, classId) || other.classId == classId) &&
            (identical(other.className, className) ||
                other.className == className) &&
            (identical(other.branchName, branchName) ||
                other.branchName == branchName) &&
            (identical(other.branchAddress, branchAddress) ||
                other.branchAddress == branchAddress) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, classId, className, branchName,
      branchAddress, startTime, endTime);

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
      final String? className,
      final String? branchName,
      final String? branchAddress,
      final DateTime? startTime,
      final DateTime? endTime}) = _$HomUpcomingClassImpl;

  factory _HomUpcomingClass.fromJson(Map<String, dynamic> json) =
      _$HomUpcomingClassImpl.fromJson;

  @override
  String? get classId;
  @override
  String? get className;
  @override
  String? get branchName;
  @override
  String? get branchAddress;
  @override
  DateTime? get startTime;
  @override
  DateTime? get endTime;
  @override
  @JsonKey(ignore: true)
  _$$HomUpcomingClassImplCopyWith<_$HomUpcomingClassImpl> get copyWith =>
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
  double? get longitude => throw _privateConstructorUsedError;
  double? get latitude => throw _privateConstructorUsedError;
  String? get partnerId => throw _privateConstructorUsedError;
  String? get managerId => throw _privateConstructorUsedError;
  bool? get isActive => throw _privateConstructorUsedError;
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
      double? longitude,
      double? latitude,
      String? partnerId,
      String? managerId,
      bool? isActive,
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
    Object? longitude = freezed,
    Object? latitude = freezed,
    Object? partnerId = freezed,
    Object? managerId = freezed,
    Object? isActive = freezed,
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
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
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
      double? longitude,
      double? latitude,
      String? partnerId,
      String? managerId,
      bool? isActive,
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
    Object? longitude = freezed,
    Object? latitude = freezed,
    Object? partnerId = freezed,
    Object? managerId = freezed,
    Object? isActive = freezed,
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
      isActive: freezed == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
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
class _$HomBranchImpl implements _HomBranch {
  const _$HomBranchImpl(
      {this.id,
      this.title,
      this.address,
      this.longitude,
      this.latitude,
      this.partnerId,
      this.managerId,
      this.isActive,
      this.createdAt,
      this.updatedAt,
      this.deletedAt});

  factory _$HomBranchImpl.fromJson(Map<String, dynamic> json) =>
      _$$HomBranchImplFromJson(json);

  @override
  final String? id;
  @override
  final String? title;
  @override
  final String? address;
  @override
  final double? longitude;
  @override
  final double? latitude;
  @override
  final String? partnerId;
  @override
  final String? managerId;
  @override
  final bool? isActive;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  @override
  final String? deletedAt;

  @override
  String toString() {
    return 'HomBranch(id: $id, title: $title, address: $address, longitude: $longitude, latitude: $latitude, partnerId: $partnerId, managerId: $managerId, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomBranchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.partnerId, partnerId) ||
                other.partnerId == partnerId) &&
            (identical(other.managerId, managerId) ||
                other.managerId == managerId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
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
      longitude,
      latitude,
      partnerId,
      managerId,
      isActive,
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
      final double? longitude,
      final double? latitude,
      final String? partnerId,
      final String? managerId,
      final bool? isActive,
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
  double? get longitude;
  @override
  double? get latitude;
  @override
  String? get partnerId;
  @override
  String? get managerId;
  @override
  bool? get isActive;
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

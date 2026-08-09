// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HomeBuildable {
  bool get isSelected => throw _privateConstructorUsedError;

  /// Starts TRUE, because a fresh home screen is always about to load.
  ///
  /// Home reads "no model and no classes" as a connection failure. On a
  /// default state that description also fits a screen that simply hasn't
  /// fetched yet — so a `false` here put the offline view on screen for every
  /// frame between the page mounting and the first response landing, and the
  /// user saw "no connection" on a perfectly good network.
  bool get isLoading => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  HomeModel? get homeModel => throw _privateConstructorUsedError;
  List<HomCategory>? get categories =>
      throw _privateConstructorUsedError; // Location
  double? get lat => throw _privateConstructorUsedError;
  double? get lng =>
      throw _privateConstructorUsedError; // Pagination for new classes
  List<HomClass> get newClassesList => throw _privateConstructorUsedError;

  /// Real courses — the home 'Курсы' row. Kept separate from the class
  /// lists because a course is bought as a trial or as the whole course.
  List<HomClass> get coursesList => throw _privateConstructorUsedError;
  int get newClassesPage => throw _privateConstructorUsedError;
  bool get isLoadingNewClasses => throw _privateConstructorUsedError;
  bool get hasMoreNewClasses =>
      throw _privateConstructorUsedError; // Pagination for near classes
  List<HomClass> get nearClassesList => throw _privateConstructorUsedError;
  int get nearClassesPage => throw _privateConstructorUsedError;
  bool get isLoadingNearClasses => throw _privateConstructorUsedError;
  bool get hasMoreNearClasses => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeBuildableCopyWith<HomeBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeBuildableCopyWith<$Res> {
  factory $HomeBuildableCopyWith(
          HomeBuildable value, $Res Function(HomeBuildable) then) =
      _$HomeBuildableCopyWithImpl<$Res, HomeBuildable>;
  @useResult
  $Res call(
      {bool isSelected,
      bool isLoading,
      bool success,
      HomeModel? homeModel,
      List<HomCategory>? categories,
      double? lat,
      double? lng,
      List<HomClass> newClassesList,
      List<HomClass> coursesList,
      int newClassesPage,
      bool isLoadingNewClasses,
      bool hasMoreNewClasses,
      List<HomClass> nearClassesList,
      int nearClassesPage,
      bool isLoadingNearClasses,
      bool hasMoreNearClasses});

  $HomeModelCopyWith<$Res>? get homeModel;
}

/// @nodoc
class _$HomeBuildableCopyWithImpl<$Res, $Val extends HomeBuildable>
    implements $HomeBuildableCopyWith<$Res> {
  _$HomeBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? success = null,
    Object? homeModel = freezed,
    Object? categories = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? newClassesList = null,
    Object? coursesList = null,
    Object? newClassesPage = null,
    Object? isLoadingNewClasses = null,
    Object? hasMoreNewClasses = null,
    Object? nearClassesList = null,
    Object? nearClassesPage = null,
    Object? isLoadingNearClasses = null,
    Object? hasMoreNearClasses = null,
  }) {
    return _then(_value.copyWith(
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      homeModel: freezed == homeModel
          ? _value.homeModel
          : homeModel // ignore: cast_nullable_to_non_nullable
              as HomeModel?,
      categories: freezed == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<HomCategory>?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      newClassesList: null == newClassesList
          ? _value.newClassesList
          : newClassesList // ignore: cast_nullable_to_non_nullable
              as List<HomClass>,
      coursesList: null == coursesList
          ? _value.coursesList
          : coursesList // ignore: cast_nullable_to_non_nullable
              as List<HomClass>,
      newClassesPage: null == newClassesPage
          ? _value.newClassesPage
          : newClassesPage // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingNewClasses: null == isLoadingNewClasses
          ? _value.isLoadingNewClasses
          : isLoadingNewClasses // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMoreNewClasses: null == hasMoreNewClasses
          ? _value.hasMoreNewClasses
          : hasMoreNewClasses // ignore: cast_nullable_to_non_nullable
              as bool,
      nearClassesList: null == nearClassesList
          ? _value.nearClassesList
          : nearClassesList // ignore: cast_nullable_to_non_nullable
              as List<HomClass>,
      nearClassesPage: null == nearClassesPage
          ? _value.nearClassesPage
          : nearClassesPage // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingNearClasses: null == isLoadingNearClasses
          ? _value.isLoadingNearClasses
          : isLoadingNearClasses // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMoreNearClasses: null == hasMoreNearClasses
          ? _value.hasMoreNearClasses
          : hasMoreNearClasses // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomeModelCopyWith<$Res>? get homeModel {
    if (_value.homeModel == null) {
      return null;
    }

    return $HomeModelCopyWith<$Res>(_value.homeModel!, (value) {
      return _then(_value.copyWith(homeModel: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$HomeBuildableImplCopyWith<$Res>
    implements $HomeBuildableCopyWith<$Res> {
  factory _$$HomeBuildableImplCopyWith(
          _$HomeBuildableImpl value, $Res Function(_$HomeBuildableImpl) then) =
      __$$HomeBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isSelected,
      bool isLoading,
      bool success,
      HomeModel? homeModel,
      List<HomCategory>? categories,
      double? lat,
      double? lng,
      List<HomClass> newClassesList,
      List<HomClass> coursesList,
      int newClassesPage,
      bool isLoadingNewClasses,
      bool hasMoreNewClasses,
      List<HomClass> nearClassesList,
      int nearClassesPage,
      bool isLoadingNearClasses,
      bool hasMoreNearClasses});

  @override
  $HomeModelCopyWith<$Res>? get homeModel;
}

/// @nodoc
class __$$HomeBuildableImplCopyWithImpl<$Res>
    extends _$HomeBuildableCopyWithImpl<$Res, _$HomeBuildableImpl>
    implements _$$HomeBuildableImplCopyWith<$Res> {
  __$$HomeBuildableImplCopyWithImpl(
      _$HomeBuildableImpl _value, $Res Function(_$HomeBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isSelected = null,
    Object? isLoading = null,
    Object? success = null,
    Object? homeModel = freezed,
    Object? categories = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
    Object? newClassesList = null,
    Object? coursesList = null,
    Object? newClassesPage = null,
    Object? isLoadingNewClasses = null,
    Object? hasMoreNewClasses = null,
    Object? nearClassesList = null,
    Object? nearClassesPage = null,
    Object? isLoadingNearClasses = null,
    Object? hasMoreNearClasses = null,
  }) {
    return _then(_$HomeBuildableImpl(
      isSelected: null == isSelected
          ? _value.isSelected
          : isSelected // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      homeModel: freezed == homeModel
          ? _value.homeModel
          : homeModel // ignore: cast_nullable_to_non_nullable
              as HomeModel?,
      categories: freezed == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<HomCategory>?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      newClassesList: null == newClassesList
          ? _value._newClassesList
          : newClassesList // ignore: cast_nullable_to_non_nullable
              as List<HomClass>,
      coursesList: null == coursesList
          ? _value._coursesList
          : coursesList // ignore: cast_nullable_to_non_nullable
              as List<HomClass>,
      newClassesPage: null == newClassesPage
          ? _value.newClassesPage
          : newClassesPage // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingNewClasses: null == isLoadingNewClasses
          ? _value.isLoadingNewClasses
          : isLoadingNewClasses // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMoreNewClasses: null == hasMoreNewClasses
          ? _value.hasMoreNewClasses
          : hasMoreNewClasses // ignore: cast_nullable_to_non_nullable
              as bool,
      nearClassesList: null == nearClassesList
          ? _value._nearClassesList
          : nearClassesList // ignore: cast_nullable_to_non_nullable
              as List<HomClass>,
      nearClassesPage: null == nearClassesPage
          ? _value.nearClassesPage
          : nearClassesPage // ignore: cast_nullable_to_non_nullable
              as int,
      isLoadingNearClasses: null == isLoadingNearClasses
          ? _value.isLoadingNearClasses
          : isLoadingNearClasses // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMoreNearClasses: null == hasMoreNearClasses
          ? _value.hasMoreNearClasses
          : hasMoreNearClasses // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$HomeBuildableImpl implements _HomeBuildable {
  const _$HomeBuildableImpl(
      {this.isSelected = false,
      this.isLoading = true,
      this.success = false,
      this.homeModel,
      final List<HomCategory>? categories,
      this.lat = null,
      this.lng = null,
      final List<HomClass> newClassesList = const [],
      final List<HomClass> coursesList = const [],
      this.newClassesPage = 2,
      this.isLoadingNewClasses = false,
      this.hasMoreNewClasses = true,
      final List<HomClass> nearClassesList = const [],
      this.nearClassesPage = 2,
      this.isLoadingNearClasses = false,
      this.hasMoreNearClasses = true})
      : _categories = categories,
        _newClassesList = newClassesList,
        _coursesList = coursesList,
        _nearClassesList = nearClassesList;

  @override
  @JsonKey()
  final bool isSelected;

  /// Starts TRUE, because a fresh home screen is always about to load.
  ///
  /// Home reads "no model and no classes" as a connection failure. On a
  /// default state that description also fits a screen that simply hasn't
  /// fetched yet — so a `false` here put the offline view on screen for every
  /// frame between the page mounting and the first response landing, and the
  /// user saw "no connection" on a perfectly good network.
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool success;
  @override
  final HomeModel? homeModel;
  final List<HomCategory>? _categories;
  @override
  List<HomCategory>? get categories {
    final value = _categories;
    if (value == null) return null;
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// Location
  @override
  @JsonKey()
  final double? lat;
  @override
  @JsonKey()
  final double? lng;
// Pagination for new classes
  final List<HomClass> _newClassesList;
// Pagination for new classes
  @override
  @JsonKey()
  List<HomClass> get newClassesList {
    if (_newClassesList is EqualUnmodifiableListView) return _newClassesList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_newClassesList);
  }

  /// Real courses — the home 'Курсы' row. Kept separate from the class
  /// lists because a course is bought as a trial or as the whole course.
  final List<HomClass> _coursesList;

  /// Real courses — the home 'Курсы' row. Kept separate from the class
  /// lists because a course is bought as a trial or as the whole course.
  @override
  @JsonKey()
  List<HomClass> get coursesList {
    if (_coursesList is EqualUnmodifiableListView) return _coursesList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coursesList);
  }

  @override
  @JsonKey()
  final int newClassesPage;
  @override
  @JsonKey()
  final bool isLoadingNewClasses;
  @override
  @JsonKey()
  final bool hasMoreNewClasses;
// Pagination for near classes
  final List<HomClass> _nearClassesList;
// Pagination for near classes
  @override
  @JsonKey()
  List<HomClass> get nearClassesList {
    if (_nearClassesList is EqualUnmodifiableListView) return _nearClassesList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_nearClassesList);
  }

  @override
  @JsonKey()
  final int nearClassesPage;
  @override
  @JsonKey()
  final bool isLoadingNearClasses;
  @override
  @JsonKey()
  final bool hasMoreNearClasses;

  @override
  String toString() {
    return 'HomeBuildable(isSelected: $isSelected, isLoading: $isLoading, success: $success, homeModel: $homeModel, categories: $categories, lat: $lat, lng: $lng, newClassesList: $newClassesList, coursesList: $coursesList, newClassesPage: $newClassesPage, isLoadingNewClasses: $isLoadingNewClasses, hasMoreNewClasses: $hasMoreNewClasses, nearClassesList: $nearClassesList, nearClassesPage: $nearClassesPage, isLoadingNearClasses: $isLoadingNearClasses, hasMoreNearClasses: $hasMoreNearClasses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeBuildableImpl &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.homeModel, homeModel) ||
                other.homeModel == homeModel) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            const DeepCollectionEquality()
                .equals(other._newClassesList, _newClassesList) &&
            const DeepCollectionEquality()
                .equals(other._coursesList, _coursesList) &&
            (identical(other.newClassesPage, newClassesPage) ||
                other.newClassesPage == newClassesPage) &&
            (identical(other.isLoadingNewClasses, isLoadingNewClasses) ||
                other.isLoadingNewClasses == isLoadingNewClasses) &&
            (identical(other.hasMoreNewClasses, hasMoreNewClasses) ||
                other.hasMoreNewClasses == hasMoreNewClasses) &&
            const DeepCollectionEquality()
                .equals(other._nearClassesList, _nearClassesList) &&
            (identical(other.nearClassesPage, nearClassesPage) ||
                other.nearClassesPage == nearClassesPage) &&
            (identical(other.isLoadingNearClasses, isLoadingNearClasses) ||
                other.isLoadingNearClasses == isLoadingNearClasses) &&
            (identical(other.hasMoreNearClasses, hasMoreNearClasses) ||
                other.hasMoreNearClasses == hasMoreNearClasses));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isSelected,
      isLoading,
      success,
      homeModel,
      const DeepCollectionEquality().hash(_categories),
      lat,
      lng,
      const DeepCollectionEquality().hash(_newClassesList),
      const DeepCollectionEquality().hash(_coursesList),
      newClassesPage,
      isLoadingNewClasses,
      hasMoreNewClasses,
      const DeepCollectionEquality().hash(_nearClassesList),
      nearClassesPage,
      isLoadingNearClasses,
      hasMoreNearClasses);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeBuildableImplCopyWith<_$HomeBuildableImpl> get copyWith =>
      __$$HomeBuildableImplCopyWithImpl<_$HomeBuildableImpl>(this, _$identity);
}

abstract class _HomeBuildable implements HomeBuildable {
  const factory _HomeBuildable(
      {final bool isSelected,
      final bool isLoading,
      final bool success,
      final HomeModel? homeModel,
      final List<HomCategory>? categories,
      final double? lat,
      final double? lng,
      final List<HomClass> newClassesList,
      final List<HomClass> coursesList,
      final int newClassesPage,
      final bool isLoadingNewClasses,
      final bool hasMoreNewClasses,
      final List<HomClass> nearClassesList,
      final int nearClassesPage,
      final bool isLoadingNearClasses,
      final bool hasMoreNearClasses}) = _$HomeBuildableImpl;

  @override
  bool get isSelected;
  @override

  /// Starts TRUE, because a fresh home screen is always about to load.
  ///
  /// Home reads "no model and no classes" as a connection failure. On a
  /// default state that description also fits a screen that simply hasn't
  /// fetched yet — so a `false` here put the offline view on screen for every
  /// frame between the page mounting and the first response landing, and the
  /// user saw "no connection" on a perfectly good network.
  bool get isLoading;
  @override
  bool get success;
  @override
  HomeModel? get homeModel;
  @override
  List<HomCategory>? get categories;
  @override // Location
  double? get lat;
  @override
  double? get lng;
  @override // Pagination for new classes
  List<HomClass> get newClassesList;
  @override

  /// Real courses — the home 'Курсы' row. Kept separate from the class
  /// lists because a course is bought as a trial or as the whole course.
  List<HomClass> get coursesList;
  @override
  int get newClassesPage;
  @override
  bool get isLoadingNewClasses;
  @override
  bool get hasMoreNewClasses;
  @override // Pagination for near classes
  List<HomClass> get nearClassesList;
  @override
  int get nearClassesPage;
  @override
  bool get isLoadingNearClasses;
  @override
  bool get hasMoreNearClasses;
  @override
  @JsonKey(ignore: true)
  _$$HomeBuildableImplCopyWith<_$HomeBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$HomeListenable {
  HomeEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HomeListenableCopyWith<HomeListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeListenableCopyWith<$Res> {
  factory $HomeListenableCopyWith(
          HomeListenable value, $Res Function(HomeListenable) then) =
      _$HomeListenableCopyWithImpl<$Res, HomeListenable>;
  @useResult
  $Res call({HomeEffect effect});
}

/// @nodoc
class _$HomeListenableCopyWithImpl<$Res, $Val extends HomeListenable>
    implements $HomeListenableCopyWith<$Res> {
  _$HomeListenableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_value.copyWith(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as HomeEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HomeListenableImplCopyWith<$Res>
    implements $HomeListenableCopyWith<$Res> {
  factory _$$HomeListenableImplCopyWith(_$HomeListenableImpl value,
          $Res Function(_$HomeListenableImpl) then) =
      __$$HomeListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({HomeEffect effect});
}

/// @nodoc
class __$$HomeListenableImplCopyWithImpl<$Res>
    extends _$HomeListenableCopyWithImpl<$Res, _$HomeListenableImpl>
    implements _$$HomeListenableImplCopyWith<$Res> {
  __$$HomeListenableImplCopyWithImpl(
      _$HomeListenableImpl _value, $Res Function(_$HomeListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$HomeListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as HomeEffect,
    ));
  }
}

/// @nodoc

class _$HomeListenableImpl implements _HomeListenable {
  const _$HomeListenableImpl({required this.effect});

  @override
  final HomeEffect effect;

  @override
  String toString() {
    return 'HomeListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeListenableImplCopyWith<_$HomeListenableImpl> get copyWith =>
      __$$HomeListenableImplCopyWithImpl<_$HomeListenableImpl>(
          this, _$identity);
}

abstract class _HomeListenable implements HomeListenable {
  const factory _HomeListenable({required final HomeEffect effect}) =
      _$HomeListenableImpl;

  @override
  HomeEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$HomeListenableImplCopyWith<_$HomeListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

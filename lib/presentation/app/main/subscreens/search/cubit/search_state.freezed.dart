// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchBuildable {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get classesLoaded => throw _privateConstructorUsedError;
  bool get branchesLoaded => throw _privateConstructorUsedError;
  int get activeTab => throw _privateConstructorUsedError;
  String get searchTerm => throw _privateConstructorUsedError;
  List<HomClass> get classes => throw _privateConstructorUsedError;
  List<HomBranch> get branches => throw _privateConstructorUsedError;
  int get classesPage => throw _privateConstructorUsedError;
  int get branchesPage => throw _privateConstructorUsedError;
  int get classesTotalPages => throw _privateConstructorUsedError;
  int get branchesTotalPages => throw _privateConstructorUsedError;
  List<HomCategory> get categories => throw _privateConstructorUsedError;
  HomCategory? get selectedCategory => throw _privateConstructorUsedError;
  FilterResult? get filter => throw _privateConstructorUsedError;
  double? get lat => throw _privateConstructorUsedError;
  double? get lng => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchBuildableCopyWith<SearchBuildable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchBuildableCopyWith<$Res> {
  factory $SearchBuildableCopyWith(
          SearchBuildable value, $Res Function(SearchBuildable) then) =
      _$SearchBuildableCopyWithImpl<$Res, SearchBuildable>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isLoadingMore,
      bool classesLoaded,
      bool branchesLoaded,
      int activeTab,
      String searchTerm,
      List<HomClass> classes,
      List<HomBranch> branches,
      int classesPage,
      int branchesPage,
      int classesTotalPages,
      int branchesTotalPages,
      List<HomCategory> categories,
      HomCategory? selectedCategory,
      FilterResult? filter,
      double? lat,
      double? lng});

  $HomCategoryCopyWith<$Res>? get selectedCategory;
}

/// @nodoc
class _$SearchBuildableCopyWithImpl<$Res, $Val extends SearchBuildable>
    implements $SearchBuildableCopyWith<$Res> {
  _$SearchBuildableCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? classesLoaded = null,
    Object? branchesLoaded = null,
    Object? activeTab = null,
    Object? searchTerm = null,
    Object? classes = null,
    Object? branches = null,
    Object? classesPage = null,
    Object? branchesPage = null,
    Object? classesTotalPages = null,
    Object? branchesTotalPages = null,
    Object? categories = null,
    Object? selectedCategory = freezed,
    Object? filter = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      classesLoaded: null == classesLoaded
          ? _value.classesLoaded
          : classesLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
      branchesLoaded: null == branchesLoaded
          ? _value.branchesLoaded
          : branchesLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
      activeTab: null == activeTab
          ? _value.activeTab
          : activeTab // ignore: cast_nullable_to_non_nullable
              as int,
      searchTerm: null == searchTerm
          ? _value.searchTerm
          : searchTerm // ignore: cast_nullable_to_non_nullable
              as String,
      classes: null == classes
          ? _value.classes
          : classes // ignore: cast_nullable_to_non_nullable
              as List<HomClass>,
      branches: null == branches
          ? _value.branches
          : branches // ignore: cast_nullable_to_non_nullable
              as List<HomBranch>,
      classesPage: null == classesPage
          ? _value.classesPage
          : classesPage // ignore: cast_nullable_to_non_nullable
              as int,
      branchesPage: null == branchesPage
          ? _value.branchesPage
          : branchesPage // ignore: cast_nullable_to_non_nullable
              as int,
      classesTotalPages: null == classesTotalPages
          ? _value.classesTotalPages
          : classesTotalPages // ignore: cast_nullable_to_non_nullable
              as int,
      branchesTotalPages: null == branchesTotalPages
          ? _value.branchesTotalPages
          : branchesTotalPages // ignore: cast_nullable_to_non_nullable
              as int,
      categories: null == categories
          ? _value.categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<HomCategory>,
      selectedCategory: freezed == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as HomCategory?,
      filter: freezed == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as FilterResult?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $HomCategoryCopyWith<$Res>? get selectedCategory {
    if (_value.selectedCategory == null) {
      return null;
    }

    return $HomCategoryCopyWith<$Res>(_value.selectedCategory!, (value) {
      return _then(_value.copyWith(selectedCategory: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SearchBuildableImplCopyWith<$Res>
    implements $SearchBuildableCopyWith<$Res> {
  factory _$$SearchBuildableImplCopyWith(_$SearchBuildableImpl value,
          $Res Function(_$SearchBuildableImpl) then) =
      __$$SearchBuildableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isLoadingMore,
      bool classesLoaded,
      bool branchesLoaded,
      int activeTab,
      String searchTerm,
      List<HomClass> classes,
      List<HomBranch> branches,
      int classesPage,
      int branchesPage,
      int classesTotalPages,
      int branchesTotalPages,
      List<HomCategory> categories,
      HomCategory? selectedCategory,
      FilterResult? filter,
      double? lat,
      double? lng});

  @override
  $HomCategoryCopyWith<$Res>? get selectedCategory;
}

/// @nodoc
class __$$SearchBuildableImplCopyWithImpl<$Res>
    extends _$SearchBuildableCopyWithImpl<$Res, _$SearchBuildableImpl>
    implements _$$SearchBuildableImplCopyWith<$Res> {
  __$$SearchBuildableImplCopyWithImpl(
      _$SearchBuildableImpl _value, $Res Function(_$SearchBuildableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? classesLoaded = null,
    Object? branchesLoaded = null,
    Object? activeTab = null,
    Object? searchTerm = null,
    Object? classes = null,
    Object? branches = null,
    Object? classesPage = null,
    Object? branchesPage = null,
    Object? classesTotalPages = null,
    Object? branchesTotalPages = null,
    Object? categories = null,
    Object? selectedCategory = freezed,
    Object? filter = freezed,
    Object? lat = freezed,
    Object? lng = freezed,
  }) {
    return _then(_$SearchBuildableImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      classesLoaded: null == classesLoaded
          ? _value.classesLoaded
          : classesLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
      branchesLoaded: null == branchesLoaded
          ? _value.branchesLoaded
          : branchesLoaded // ignore: cast_nullable_to_non_nullable
              as bool,
      activeTab: null == activeTab
          ? _value.activeTab
          : activeTab // ignore: cast_nullable_to_non_nullable
              as int,
      searchTerm: null == searchTerm
          ? _value.searchTerm
          : searchTerm // ignore: cast_nullable_to_non_nullable
              as String,
      classes: null == classes
          ? _value._classes
          : classes // ignore: cast_nullable_to_non_nullable
              as List<HomClass>,
      branches: null == branches
          ? _value._branches
          : branches // ignore: cast_nullable_to_non_nullable
              as List<HomBranch>,
      classesPage: null == classesPage
          ? _value.classesPage
          : classesPage // ignore: cast_nullable_to_non_nullable
              as int,
      branchesPage: null == branchesPage
          ? _value.branchesPage
          : branchesPage // ignore: cast_nullable_to_non_nullable
              as int,
      classesTotalPages: null == classesTotalPages
          ? _value.classesTotalPages
          : classesTotalPages // ignore: cast_nullable_to_non_nullable
              as int,
      branchesTotalPages: null == branchesTotalPages
          ? _value.branchesTotalPages
          : branchesTotalPages // ignore: cast_nullable_to_non_nullable
              as int,
      categories: null == categories
          ? _value._categories
          : categories // ignore: cast_nullable_to_non_nullable
              as List<HomCategory>,
      selectedCategory: freezed == selectedCategory
          ? _value.selectedCategory
          : selectedCategory // ignore: cast_nullable_to_non_nullable
              as HomCategory?,
      filter: freezed == filter
          ? _value.filter
          : filter // ignore: cast_nullable_to_non_nullable
              as FilterResult?,
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc

class _$SearchBuildableImpl implements _SearchBuildable {
  const _$SearchBuildableImpl(
      {this.isLoading = false,
      this.isLoadingMore = false,
      this.classesLoaded = false,
      this.branchesLoaded = false,
      this.activeTab = 0,
      this.searchTerm = '',
      final List<HomClass> classes = const [],
      final List<HomBranch> branches = const [],
      this.classesPage = 1,
      this.branchesPage = 1,
      this.classesTotalPages = 1,
      this.branchesTotalPages = 1,
      final List<HomCategory> categories = const [],
      this.selectedCategory,
      this.filter,
      this.lat = null,
      this.lng = null})
      : _classes = classes,
        _branches = branches,
        _categories = categories;

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool classesLoaded;
  @override
  @JsonKey()
  final bool branchesLoaded;
  @override
  @JsonKey()
  final int activeTab;
  @override
  @JsonKey()
  final String searchTerm;
  final List<HomClass> _classes;
  @override
  @JsonKey()
  List<HomClass> get classes {
    if (_classes is EqualUnmodifiableListView) return _classes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_classes);
  }

  final List<HomBranch> _branches;
  @override
  @JsonKey()
  List<HomBranch> get branches {
    if (_branches is EqualUnmodifiableListView) return _branches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_branches);
  }

  @override
  @JsonKey()
  final int classesPage;
  @override
  @JsonKey()
  final int branchesPage;
  @override
  @JsonKey()
  final int classesTotalPages;
  @override
  @JsonKey()
  final int branchesTotalPages;
  final List<HomCategory> _categories;
  @override
  @JsonKey()
  List<HomCategory> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  final HomCategory? selectedCategory;
  @override
  final FilterResult? filter;
  @override
  @JsonKey()
  final double? lat;
  @override
  @JsonKey()
  final double? lng;

  @override
  String toString() {
    return 'SearchBuildable(isLoading: $isLoading, isLoadingMore: $isLoadingMore, classesLoaded: $classesLoaded, branchesLoaded: $branchesLoaded, activeTab: $activeTab, searchTerm: $searchTerm, classes: $classes, branches: $branches, classesPage: $classesPage, branchesPage: $branchesPage, classesTotalPages: $classesTotalPages, branchesTotalPages: $branchesTotalPages, categories: $categories, selectedCategory: $selectedCategory, filter: $filter, lat: $lat, lng: $lng)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchBuildableImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.classesLoaded, classesLoaded) ||
                other.classesLoaded == classesLoaded) &&
            (identical(other.branchesLoaded, branchesLoaded) ||
                other.branchesLoaded == branchesLoaded) &&
            (identical(other.activeTab, activeTab) ||
                other.activeTab == activeTab) &&
            (identical(other.searchTerm, searchTerm) ||
                other.searchTerm == searchTerm) &&
            const DeepCollectionEquality().equals(other._classes, _classes) &&
            const DeepCollectionEquality().equals(other._branches, _branches) &&
            (identical(other.classesPage, classesPage) ||
                other.classesPage == classesPage) &&
            (identical(other.branchesPage, branchesPage) ||
                other.branchesPage == branchesPage) &&
            (identical(other.classesTotalPages, classesTotalPages) ||
                other.classesTotalPages == classesTotalPages) &&
            (identical(other.branchesTotalPages, branchesTotalPages) ||
                other.branchesTotalPages == branchesTotalPages) &&
            const DeepCollectionEquality()
                .equals(other._categories, _categories) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.filter, filter) || other.filter == filter) &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      isLoading,
      isLoadingMore,
      classesLoaded,
      branchesLoaded,
      activeTab,
      searchTerm,
      const DeepCollectionEquality().hash(_classes),
      const DeepCollectionEquality().hash(_branches),
      classesPage,
      branchesPage,
      classesTotalPages,
      branchesTotalPages,
      const DeepCollectionEquality().hash(_categories),
      selectedCategory,
      filter,
      lat,
      lng);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchBuildableImplCopyWith<_$SearchBuildableImpl> get copyWith =>
      __$$SearchBuildableImplCopyWithImpl<_$SearchBuildableImpl>(
          this, _$identity);
}

abstract class _SearchBuildable implements SearchBuildable {
  const factory _SearchBuildable(
      {final bool isLoading,
      final bool isLoadingMore,
      final bool classesLoaded,
      final bool branchesLoaded,
      final int activeTab,
      final String searchTerm,
      final List<HomClass> classes,
      final List<HomBranch> branches,
      final int classesPage,
      final int branchesPage,
      final int classesTotalPages,
      final int branchesTotalPages,
      final List<HomCategory> categories,
      final HomCategory? selectedCategory,
      final FilterResult? filter,
      final double? lat,
      final double? lng}) = _$SearchBuildableImpl;

  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get classesLoaded;
  @override
  bool get branchesLoaded;
  @override
  int get activeTab;
  @override
  String get searchTerm;
  @override
  List<HomClass> get classes;
  @override
  List<HomBranch> get branches;
  @override
  int get classesPage;
  @override
  int get branchesPage;
  @override
  int get classesTotalPages;
  @override
  int get branchesTotalPages;
  @override
  List<HomCategory> get categories;
  @override
  HomCategory? get selectedCategory;
  @override
  FilterResult? get filter;
  @override
  double? get lat;
  @override
  double? get lng;
  @override
  @JsonKey(ignore: true)
  _$$SearchBuildableImplCopyWith<_$SearchBuildableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$SearchListenable {
  SearchEffect get effect => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchListenableCopyWith<SearchListenable> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchListenableCopyWith<$Res> {
  factory $SearchListenableCopyWith(
          SearchListenable value, $Res Function(SearchListenable) then) =
      _$SearchListenableCopyWithImpl<$Res, SearchListenable>;
  @useResult
  $Res call({SearchEffect effect});
}

/// @nodoc
class _$SearchListenableCopyWithImpl<$Res, $Val extends SearchListenable>
    implements $SearchListenableCopyWith<$Res> {
  _$SearchListenableCopyWithImpl(this._value, this._then);

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
              as SearchEffect,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SearchListenableImplCopyWith<$Res>
    implements $SearchListenableCopyWith<$Res> {
  factory _$$SearchListenableImplCopyWith(_$SearchListenableImpl value,
          $Res Function(_$SearchListenableImpl) then) =
      __$$SearchListenableImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({SearchEffect effect});
}

/// @nodoc
class __$$SearchListenableImplCopyWithImpl<$Res>
    extends _$SearchListenableCopyWithImpl<$Res, _$SearchListenableImpl>
    implements _$$SearchListenableImplCopyWith<$Res> {
  __$$SearchListenableImplCopyWithImpl(_$SearchListenableImpl _value,
      $Res Function(_$SearchListenableImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? effect = null,
  }) {
    return _then(_$SearchListenableImpl(
      effect: null == effect
          ? _value.effect
          : effect // ignore: cast_nullable_to_non_nullable
              as SearchEffect,
    ));
  }
}

/// @nodoc

class _$SearchListenableImpl implements _SearchListenable {
  const _$SearchListenableImpl({required this.effect});

  @override
  final SearchEffect effect;

  @override
  String toString() {
    return 'SearchListenable(effect: $effect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchListenableImpl &&
            (identical(other.effect, effect) || other.effect == effect));
  }

  @override
  int get hashCode => Object.hash(runtimeType, effect);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchListenableImplCopyWith<_$SearchListenableImpl> get copyWith =>
      __$$SearchListenableImplCopyWithImpl<_$SearchListenableImpl>(
          this, _$identity);
}

abstract class _SearchListenable implements SearchListenable {
  const factory _SearchListenable({required final SearchEffect effect}) =
      _$SearchListenableImpl;

  @override
  SearchEffect get effect;
  @override
  @JsonKey(ignore: true)
  _$$SearchListenableImplCopyWith<_$SearchListenableImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

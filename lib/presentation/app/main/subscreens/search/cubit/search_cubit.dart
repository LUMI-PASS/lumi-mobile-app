import 'dart:async';

import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';

import 'search_state.dart';

@injectable
class SearchCubit extends BaseCubit<SearchBuildable, SearchListenable> {
  SearchCubit(this._repo) : super(const SearchBuildable());
  final HomeRepository _repo;

  double? _lat;
  double? _lng;

  /// Pending category set from outside (e.g. home page).
  /// Picked up on next [applyPendingCategory] call.
  static HomCategory? pendingCategory;

  static const int _pageLimit = 10;
  Timer? _debounce;

  Future<void> init() async {
    build((b) => b.copyWith(isLoading: true));
    await _resolveLocation();
    await Future.wait([
      _fetchCategories(),
      _explore(page: 1, append: false),
    ]);
    build((b) => b.copyWith(isLoading: false));
    applyPendingCategory();
  }

  /// Check if a category was set externally and apply it.
  void applyPendingCategory() {
    final cat = pendingCategory;
    if (cat != null) {
      pendingCategory = null;
      selectCategory(cat);
    }
  }

  Future<void> _resolveLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;
      final position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              timeLimit: Duration(seconds: 5),
            ),
          );
      _lat = position.latitude;
      _lng = position.longitude;
    } catch (_) {}
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await _repo.getAllCategories();
      build((b) => b.copyWith(categories: categories));
    } catch (_) {}
  }

  void setSearchTerm(String term) {
    build((b) => b.copyWith(searchTerm: term));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      refresh();
    });
  }

  void setTab(int tab) {
    build((b) => b.copyWith(activeTab: tab));
  }

  void selectCategory(HomCategory? category) {
    build((b) => b.copyWith(selectedCategory: category));
    refresh();
  }

  void applyFilter(FilterResult? filter) {
    build((b) => b.copyWith(filter: filter));
    refresh();
  }

  void clearFilter() {
    build((b) => b.copyWith(filter: null));
    refresh();
  }

  Future<void> refresh() async {
    build((b) => b.copyWith(isLoading: true));
    await _explore(page: 1, append: false);
    build((b) => b.copyWith(isLoading: false));
  }

  Future<void> loadMore() async {
    if (buildable.isLoadingMore) return;

    final isClassesTab = buildable.activeTab == 0;
    final currentPage =
        isClassesTab ? buildable.classesPage : buildable.branchesPage;
    final totalPages =
        isClassesTab ? buildable.classesTotalPages : buildable.branchesTotalPages;

    if (currentPage > totalPages) return;

    build((b) => b.copyWith(isLoadingMore: true));
    await _explore(page: currentPage, append: true);
    build((b) => b.copyWith(isLoadingMore: false));
  }

  Future<void> _explore({required int page, required bool append}) async {
    try {
      String? fromDate;
      String? toDate;
      int? age;
      String? classGender;
      num? minPrice;
      num? maxPrice;

      final filter = buildable.filter;
      if (filter != null) {
        age = filter.ageYears;

        if (filter.gender == Gender.boy) {
          classGender = 'MALE';
        } else if (filter.gender == Gender.girl) {
          classGender = 'FEMALE';
        }

        if (filter.pricePreset == PricePreset.custom) {
          minPrice = filter.priceRange.start.toInt();
          maxPrice = filter.priceRange.end.toInt();
        }

        final now = DateTime.now();
        switch (filter.datePreset) {
          case DatePreset.none:
            break;
          case DatePreset.today:
            fromDate = _fmtDate(now);
            toDate = _fmtDate(now);
            break;
          case DatePreset.tomorrow:
            final tmr = now.add(const Duration(days: 1));
            fromDate = _fmtDate(tmr);
            toDate = _fmtDate(tmr);
            break;
          case DatePreset.thisWeek:
            fromDate = _fmtDate(now);
            toDate = _fmtDate(
                now.add(Duration(days: DateTime.daysPerWeek - now.weekday)));
            break;
          case DatePreset.custom:
            if (filter.fromDate != null) {
              fromDate = _fmtDate(filter.fromDate!);
              toDate = filter.toDate != null
                  ? _fmtDate(filter.toDate!)
                  : _fmtDate(filter.fromDate!);
            }
            break;
        }
      }

      final result = await _repo.explore(
        page: page,
        limit: _pageLimit,
        search: buildable.searchTerm.isEmpty ? null : buildable.searchTerm,
        categoryId: buildable.selectedCategory?.id,
        fromDate: fromDate,
        toDate: toDate,
        age: age,
        classGender: classGender,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lat: _lat,
        lng: _lng,
      );

      if (append) {
        final existingClassIds = buildable.classes.map((c) => c.id).toSet();
        final uniqueClasses =
            result.classes.where((c) => !existingClassIds.contains(c.id)).toList();
        final existingBranchIds = buildable.branches.map((b) => b.id).toSet();
        final uniqueBranches = result.branches
            .where((b) => !existingBranchIds.contains(b.id))
            .toList();

        build((b) => b.copyWith(
              classes: [...b.classes, ...uniqueClasses],
              branches: [...b.branches, ...uniqueBranches],
              classesPage: buildable.activeTab == 0 ? page + 1 : b.classesPage,
              branchesPage:
                  buildable.activeTab == 1 ? page + 1 : b.branchesPage,
              classesTotalPages: result.classesPages,
              branchesTotalPages: result.branchesPages,
            ));
      } else {
        build((b) => b.copyWith(
              classes: result.classes,
              branches: result.branches,
              classesPage: 2,
              branchesPage: 2,
              classesTotalPages: result.classesPages,
              branchesTotalPages: result.branchesPages,
            ));
      }
    } on DioException catch (error) {
      if (error.response?.statusCode == 500 ||
          error.response?.statusCode == 502) {
        display.error(Strings.serverErrorTryLater);
      } else if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        display.error(Strings.connectionError);
      }
    } catch (_) {}
  }

  int get activeFilterCount {
    final f = buildable.filter;
    if (f == null) return 0;
    int count = 0;
    if (f.ageYears != null) count++;
    if (f.gender != Gender.any) count++;
    if (f.pricePreset == PricePreset.custom) count++;
    if (f.datePreset != DatePreset.none) count++;
    return count;
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}

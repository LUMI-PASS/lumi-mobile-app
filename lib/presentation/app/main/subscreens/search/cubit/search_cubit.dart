import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
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
  String _lastLang = '';

  /// Total matching results per tab, surfaced in the "Все • N" count row.
  int _classesTotal = 0;
  int _branchesTotal = 0;

  /// Total number of results for the active tab (all pages, not just loaded).
  int get resultCount =>
      buildable.activeTab == 0 ? _classesTotal : _branchesTotal;

  /// Categories cached from the home feed (have resolved title strings).
  /// Used by search so we don't depend on the raw categories/ endpoint.
  static List<HomCategory> cachedCategories = [];

  static const int _pageLimit = 10;
  Timer? _debounce;

  /// [tab] selects which result set to load first — 0 classes, 1 branches. The
  /// map screen opens straight on branches, so it doesn't pay for a classes
  /// fetch it will never show.
  ///
  /// [category] is seeded *before* the first fetch so that opening search from
  /// a category costs one filtered request, not an unfiltered one followed by
  /// a filtered one (which also flashed the wrong results on screen).
  Future<void> init({int tab = 0, HomCategory? category}) async {
    _lastLang = currentLang;
    build((b) => b.copyWith(
          isLoading: true,
          activeTab: tab,
          selectedCategory: category,
        ));
    await Future.wait([
      _fetchCategories(),
      _fetchChildren(),
      _fetchTab(tab, page: 1, append: false),
    ]);
    build((b) => b.copyWith(isLoading: false));
  }

  /// The filter sheet offers the parent's children as a shortcut that fills in
  /// the age and gender it would otherwise ask them to type.
  Future<void> _fetchChildren() async {
    try {
      final children = await _repo.getChildren();
      build((b) => b.copyWith(children: children));
    } catch (_) {}
  }

  /// Re-fetches categories and results when the app language has changed.
  Future<void> refreshIfLanguageChanged() async {
    final lang = currentLang;
    if (_lastLang == lang) return;
    _lastLang = lang;
    cachedCategories = [];
    await Future.wait([_fetchCategories(), refresh()]);
  }



  Future<void> _fetchCategories() async {
    if (cachedCategories.isNotEmpty) {
      build((b) => b.copyWith(categories: cachedCategories));
      return;
    }
    try {
      final categories = await _repo.getAllCategories();
      if (categories.isNotEmpty) {
        cachedCategories = categories;
      }
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

  Future<void> setTab(int tab) async {
    if (buildable.activeTab == tab) return;
    build((b) => b.copyWith(activeTab: tab));
    final alreadyLoaded =
        tab == 0 ? buildable.classesLoaded : buildable.branchesLoaded;
    if (!alreadyLoaded) {
      build((b) => b.copyWith(isLoading: true));
      await _fetchTab(tab, page: 1, append: false);
      build((b) => b.copyWith(isLoading: false));
    }
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
    build((b) => b.copyWith(
          isLoading: true,
          classesLoaded: false,
          branchesLoaded: false,
          classes: [],
          branches: [],
        ));
    await _fetchTab(buildable.activeTab, page: 1, append: false);
    build((b) => b.copyWith(isLoading: false));
  }

  Future<void> loadMore() async {
    if (buildable.isLoadingMore) return;

    final tab = buildable.activeTab;
    final currentPage =
        tab == 0 ? buildable.classesPage : buildable.branchesPage;
    final totalPages =
        tab == 0 ? buildable.classesTotalPages : buildable.branchesTotalPages;

    if (currentPage > totalPages) return;

    build((b) => b.copyWith(isLoadingMore: true));
    await _fetchTab(tab, page: currentPage, append: true);
    build((b) => b.copyWith(isLoadingMore: false));
  }

  Future<void> _fetchTab(int tab,
      {required int page, required bool append}) async {
    try {
      final search =
          buildable.searchTerm.isEmpty ? null : buildable.searchTerm;

      if (tab == 0) {
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
              toDate = _fmtDate(now
                  .add(Duration(days: DateTime.daysPerWeek - now.weekday)));
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

        final result = await _repo.getDiscoveryClasses(
          page: page,
          limit: _pageLimit,
          search: search,
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

        _classesTotal = result.total;

        if (append) {
          final existingIds = buildable.classes.map((c) => c.id).toSet();
          final unique = result.classes
              .where((c) => !existingIds.contains(c.id))
              .toList();
          build((b) => b.copyWith(
                classes: [...b.classes, ...unique],
                classesPage: page + 1,
                classesTotalPages: result.totalPages,
                classesLoaded: true,
              ));
        } else {
          build((b) => b.copyWith(
                classes: result.classes,
                classesPage: 2,
                classesTotalPages: result.totalPages,
                classesLoaded: true,
              ));
        }
      } else {
        final result = await _repo.getDiscoveryBranches(
          page: page,
          limit: _pageLimit,
          search: search,
          categoryId: buildable.selectedCategory?.id,
          lat: _lat,
          lng: _lng,
        );

        _branchesTotal = result.total;

        if (append) {
          final existingIds = buildable.branches.map((b) => b.id).toSet();
          final unique = result.branches
              .where((br) => !existingIds.contains(br.id))
              .toList();
          build((b) => b.copyWith(
                branches: [...b.branches, ...unique],
                branchesPage: page + 1,
                branchesTotalPages: result.totalPages,
                branchesLoaded: true,
              ));
        } else {
          build((b) => b.copyWith(
                branches: result.branches,
                branchesPage: 2,
                branchesTotalPages: result.totalPages,
                branchesLoaded: true,
              ));
        }
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
    // The age range is one filter however many of its two bounds are filled.
    if (f.ageYears != null || f.ageToYears != null) count++;
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

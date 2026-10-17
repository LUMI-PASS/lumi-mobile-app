import 'dart:async';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:lumi_pass/common/base/base_cubit.dart';
import 'package:lumi_pass/common/gen/strings.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/common/utils/catalog_revision.dart';
import 'package:lumi_pass/common/utils/user_location.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/recent_search_store.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/time_filter.dart';

import 'search_state.dart';

/// What a search IS, as the map and the list share it: the categories, the
/// filter and the typed term. Not the tab or the results — each view loads
/// its own answer to the same question.
class SearchSnapshot {
  const SearchSnapshot({
    required this.categories,
    required this.filter,
    required this.searchTerm,
  });

  final List<HomCategory> categories;
  final FilterResult? filter;
  final String searchTerm;
}

/// How the map and the list keep one search between them.
///
/// The screen that opens the other passes one of these along. The opened
/// screen keeps [latest] current as its search changes, and when it closes —
/// by its own button, the back arrow or the swipe — the screen underneath
/// takes [latest] over (see [SearchCubit.adoptSearch]). A pop result would
/// miss the swipe-back gesture, which pops without one.
///
/// A screen opened WITH a handoff also goes back rather than opening the other
/// view again, so map → list → map never stacks up.
class SearchHandoff {
  SearchSnapshot? latest;
}

@injectable
class SearchCubit extends BaseCubit<SearchBuildable, SearchListenable> {
  SearchCubit(this._repo, this._recents) : super(const SearchBuildable());
  final HomeRepository _repo;
  final RecentSearchStore _recents;

  double? _lat;
  double? _lng;
  String _lastLang = '';

  /// The catalog revision these results were built from. Course cards are
  /// priced per viewer, so a trial bought from a result re-prices the grid
  /// behind it — see [catalogRevision].
  int _lastCatalogRevision = catalogRevision.value;

  /// Total matching results per tab, surfaced in the "Все • N" count row.
  int _classesTotal = 0;
  int _branchesTotal = 0;

  /// Total number of results for the active tab (all pages, not just loaded).
  ///
  /// One number for the classes tab however the type filter is set: activities
  /// and courses come back from ONE query, so the server's total already counts
  /// exactly what the grid is showing.
  int get resultCount => buildable.activeTab == kSearchTabBranches
      ? _branchesTotal
      : _classesTotal;

  /// Total matching centres, for the centres row above the activities grid.
  int get centresCount => _branchesTotal;

  /// Whether a search of activities also asks for the centres that match.
  ///
  /// The results screen shows both in one grid — the centres first, the
  /// activities after them — so one term finds a place by its name as well as
  /// what runs there. Only for a typed term: with nothing typed the centres
  /// would be every centre there is, standing in front of the activities the
  /// user came to browse. They come back in the SAME response as the activities
  /// (`centres=1`), never from a second request. Not with a filter on: ages, prices, dates and districts
  /// describe a CLASS and `discovery/branches` ignores them, so the row would
  /// show centres the filter was supposed to rule out. And not on the map,
  /// which loads every centre itself.
  bool get _listsCentres =>
      buildable.activeTab == kSearchTabClasses &&
      !_allBranches &&
      buildable.searchTerm.isNotEmpty &&
      activeFilterCount == 0;

  /// Categories cached from the home feed (have resolved title strings).
  /// Used by search so we don't depend on the raw categories/ endpoint.
  static List<HomCategory> cachedCategories = [];

  static const int _pageLimit = 10;

  /// The map has no "load more" — it plots every centre at once, so it asks for
  /// them in big pages instead of ten at a time, and walks the rest.
  static const int _mapPageLimit = 100;

  /// Backstop on the page walk, so a backend that keeps reporting more pages
  /// can't spin here forever.
  static const int _maxMapPages = 20;

  /// Set by the map: branch fetches must return *all* centres, not page one.
  bool _allBranches = false;

  Timer? _debounce;

  /// [tab] selects which result set to load first — [kSearchTabClasses] (the
  /// default: activities and courses in one grid) or [kSearchTabBranches]. The
  /// map screen opens straight on branches, so it doesn't pay for a classes
  /// fetch it will never show.
  ///
  /// [categories] is seeded *before* the first fetch so that opening search
  /// from a category costs one filtered request, not an unfiltered one
  /// followed by a filtered one (which also flashed the wrong results on
  /// screen). Multi-select: usually one (a Home category tap), but the map's
  /// own picker can hand back several already ticked.
  ///
  /// [filter] is seeded for the same reason, and is how Home's "see all courses"
  /// arrives: the row named a type, so the screen opens with that type filter
  /// already on — visible in the filter sheet and removable there, rather than
  /// a hidden mode the user can't see or undo.
  ///
  /// [allBranches] makes every branch fetch (including the ones a category chip
  /// triggers later) load all pages instead of the first — the map plots pins,
  /// so a paged list would silently hide most centres.
  ///
  /// [recentsOnly] opens on the user's own recent activities instead of a
  /// catalog query. Home's search field comes in this way: the tap was the user
  /// asking to type, so the screen has no business spending a request on an
  /// unfiltered page of everything before they have said what they want. The
  /// first character typed (or a category, filter or tab) leaves this mode and
  /// searches for real. With nothing remembered yet there is nothing to show,
  /// so it falls through to the normal fetch.
  Future<void> init({
    int tab = kSearchTabClasses,
    List<HomCategory> categories = const [],
    FilterResult? filter,
    String searchTerm = '',
    bool allBranches = false,
    bool recentsOnly = false,
  }) async {
    _lastLang = currentLang;
    _allBranches = allBranches;

    final recents = _recents.load();
    final openOnRecents = recentsOnly && recents.isNotEmpty;

    build((b) => b.copyWith(
          isLoading: !openOnRecents,
          activeTab: tab,
          selectedCategories: categories,
          filter: filter,
          searchTerm: searchTerm,
          recentClasses: recents,
          showRecents: openOnRecents,
        ));

    if (openOnRecents) {
      // Categories still load: they are what the filter sheet and the chips
      // are made of, and they cost one cached call.
      await _fetchCategories();
      return;
    }

    await Future.wait([
      _fetchCategories(),
      _fetchTab(tab, page: 1, append: false),
    ]);
    build((b) => b.copyWith(isLoading: false));
  }

  /// Puts [model] at the top of the remembered list — called when a result is
  /// opened from the search screen, which is what makes it a "recent search".
  Future<void> rememberRecent(HomClass? model) async {
    await _recents.remember(model);
    final recents = _recents.load();
    build((b) => b.copyWith(recentClasses: recents));
  }

  /// Empties the remembered list. The screen falls back to a real search,
  /// since an empty "recent" section is a dead screen.
  Future<void> clearRecents() async {
    await _recents.clear();
    build((b) => b.copyWith(recentClasses: const [], showRecents: false));
    await refresh();
  }

  /// Leaves the recents screen, if it is up, because the user just asked for
  /// something specific.
  void _leaveRecents() {
    if (buildable.showRecents) build((b) => b.copyWith(showRecents: false));
  }

  /// Re-fetches categories and results when the app language has changed.
  /// Called when the tab regains focus: re-fetch when anything that changes
  /// what the results should SAY has moved since the last load — the language,
  /// or a purchase that re-priced the course cards.
  Future<void> refreshIfLanguageChanged() async {
    final lang = currentLang;
    final langChanged = _lastLang != lang;
    final catalogChanged = _lastCatalogRevision != catalogRevision.value;
    if (!langChanged && !catalogChanged) return;
    _lastCatalogRevision = catalogRevision.value;
    if (!langChanged) {
      // Prices moved, the vocabulary didn't — the category titles still stand.
      await refresh();
      return;
    }
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

    // Clearing the field on the recents screen goes back to the recents rather
    // than firing the unfiltered query the screen deliberately avoided on
    // open. Only where nothing else is narrowing the results — with a category
    // or a filter on, an empty field is a real (narrowed) search.
    if (term.isEmpty &&
        buildable.recentClasses.isNotEmpty &&
        buildable.selectedCategories.isEmpty &&
        activeFilterCount == 0 &&
        buildable.activeTab == kSearchTabClasses) {
      build((b) => b.copyWith(showRecents: true, isLoading: false));
      return;
    }

    _leaveRecents();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      refresh();
    });
  }

  /// Switch between the results grid and centres.
  ///
  /// Always one of the two lit: with only these two left there is no
  /// "everything" state to fall back to, and tapping the lit chip does nothing
  /// rather than emptying the screen.
  Future<void> setTab(int tab) async {
    if (buildable.activeTab == tab) return;
    _leaveRecents();
    build((b) => b.copyWith(activeTab: tab));
    final alreadyLoaded = tab == kSearchTabBranches
        ? buildable.branchesLoaded
        : buildable.classesLoaded;
    if (!alreadyLoaded) {
      build((b) => b.copyWith(isLoading: true));
      await _fetchTab(tab, page: 1, append: false);
      build((b) => b.copyWith(isLoading: false));
    }
  }

  /// Ticks or unticks one category — multi-select, so picking a second never
  /// drops the first.
  void toggleCategory(HomCategory category) {
    _leaveRecents();
    final current = buildable.selectedCategories;
    final without = current.where((c) => c.id != category.id).toList();
    final updated =
        without.length == current.length ? [...current, category] : without;
    build((b) => b.copyWith(selectedCategories: updated));
    refresh();
  }

  /// Replaces the whole category selection at once — what the picker sheet's
  /// Apply commits, so ticking several categories fires one request instead of
  /// one per tick.
  void setCategories(List<HomCategory> categories) {
    _leaveRecents();
    build((b) => b.copyWith(selectedCategories: categories));
    refresh();
  }

  void clearCategories() {
    if (buildable.selectedCategories.isEmpty) return;
    _leaveRecents();
    build((b) => b.copyWith(selectedCategories: const []));
    refresh();
  }

  /// Commits what the filter sheet came back with.
  ///
  /// [categories] is passed when the sheet carried the category grid, so one
  /// Apply is ONE request: setting the filter and the categories through their
  /// two separate setters fired two refreshes, and the first one's results
  /// were thrown away a frame later. Omitted by a caller whose sheet has no
  /// grid (the map screen, which picks categories elsewhere), and the current
  /// selection is then left exactly as it was.
  void applyFilter(FilterResult? filter, {List<HomCategory>? categories}) {
    _leaveRecents();
    build((b) => b.copyWith(
          filter: filter,
          selectedCategories: categories ?? b.selectedCategories,
        ));
    refresh();
  }

  void clearFilter() {
    _leaveRecents();
    build((b) => b.copyWith(filter: null));
    refresh();
  }

  Future<void> refresh() async {
    build((b) => b.copyWith(
          showRecents: false,
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
    // The recents grid is short enough that the scroll listener fires the
    // moment it attaches. There is no next page of "what you looked at last",
    // and paging here would fire the very catalog request this screen exists
    // to avoid.
    if (buildable.showRecents) return;

    final tab = buildable.activeTab;
    final currentPage = tab == kSearchTabBranches
        ? buildable.branchesPage
        : buildable.classesPage;
    final totalPages = tab == kSearchTabBranches
        ? buildable.branchesTotalPages
        : buildable.classesTotalPages;

    if (currentPage > totalPages) return;

    build((b) => b.copyWith(isLoadingMore: true));
    await _fetchTab(tab, page: currentPage, append: true);
    build((b) => b.copyWith(isLoadingMore: false));
  }

  /// The query parameters the current search term and filter add up to.
  ///
  /// Pulled out of [_fetchTab] because the MAP needs exactly the same mapping:
  /// with a filter on, the centres it plots are derived from the classes that
  /// match it (see [_fetchBranchesFromClasses]), so the two must narrow by the
  /// same rules or the map would quietly disagree with the list.
  _ClassQuery _classQuery() {
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

    final categoryIds = buildable.selectedCategories
        .map((c) => c.id)
        .whereType<String>()
        .toList();

    return _ClassQuery(
      search: buildable.searchTerm.isEmpty ? null : buildable.searchTerm,
      categoryIds: categoryIds.isEmpty ? null : categoryIds,
      fromDate: fromDate,
      toDate: toDate,
      age: age,
      classGender: classGender,
      minPrice: minPrice,
      maxPrice: maxPrice,
      districts: filter?.districts.toList(),
      kind: (filter?.kind ?? ActivityKind.any).queryValue,
      radiusKm: filter != null && filter.hasRadius ? filter.radiusKm : null,
      nearLat: filter != null && filter.hasRadius ? filter.nearLat : null,
      nearLng: filter != null && filter.hasRadius ? filter.nearLng : null,
      fromTime: filter != null && filter.hasTime
          ? DayWindow.hhmm(filter.fromMinute)
          : null,
      toTime: filter != null && filter.hasTime
          ? DayWindow.hhmm(filter.toMinute)
          : null,
    );
  }

  Future<void> _fetchTab(int tab,
      {required int page, required bool append}) async {
    try {
      if (tab != kSearchTabBranches) {
        final q = _classQuery();

        // ONE request for both kinds. They used to come from two endpoints and
        // be interleaved here, which meant courses ignored every filter — so
        // the grid quietly dropped them the moment any filter was on. The
        // server now applies the same filters to both and pages them together,
        // which is also the only way the ordering can be honest: two lists
        // zipped client-side put every course second regardless of relevance.
        final result = await _repo.getDiscoveryClasses(
          page: page,
          limit: _pageLimit,
          search: q.search,
          categoryIds: q.categoryIds,
          fromDate: q.fromDate,
          toDate: q.toDate,
          age: q.age,
          classGender: q.classGender,
          minPrice: q.minPrice,
          maxPrice: q.maxPrice,
          // The radius is measured from where the user stood when they picked
          // it, so that point wins over the ordering location.
          lat: q.nearLat ?? _lat,
          lng: q.nearLng ?? _lng,
          districts: q.districts,
          kind: q.kind,
          radiusKm: q.radiusKm,
          fromTime: q.fromTime,
          toTime: q.toTime,
          // First page only: the row is not paged, so a "load more" has no
          // use for them.
          centres: !append && _listsCentres,
        );

        _classesTotal = result.total;
        final centres = result.branches;
        if (centres != null) _branchesTotal = result.branchesTotal;

        if (append) {
          final existingIds = buildable.classes.map((c) => c.id).toSet();
          final unique =
              result.classes.where((c) => !existingIds.contains(c.id)).toList();
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
                branches: centres ?? b.branches,
              ));
        }
      } else {
        // The map, with a filter on. `discovery/branches` knows nothing about
        // ages, prices, dates or districts — those describe a CLASS — so
        // asking it for filtered centres would drop every one of those on the
        // floor and plot the same pins as before. The honest answer to "which
        // centres match this filter" is "the ones running a class that does",
        // so the pins are derived from the filtered classes instead.
        //
        // Not for the radius on its own: it describes where a CENTRE is, and
        // deriving the pins from classes dropped every catalog centre — the
        // listings with nothing bookable, most of the map — so 11 centres
        // inside the circle came back as 3. A radius alone keeps the centre
        // list and is applied to it below.
        if (_allBranches && _hasClassFilter) {
          if (append) return;
          await _fetchBranchesFromClasses();
          return;
        }

        final categoryIds = buildable.selectedCategories
            .map((c) => c.id)
            .whereType<String>()
            .toList();

        final result = await _repo.getDiscoveryBranches(
          page: page,
          limit: _allBranches ? _mapPageLimit : _pageLimit,
          search: buildable.searchTerm.isEmpty ? null : buildable.searchTerm,
          categoryIds: categoryIds.isEmpty ? null : categoryIds,
          lat: _lat,
          lng: _lng,
        );

        // The map walks every page, so the radius can be applied here and the
        // answer is complete. (The paged centres list is left alone — cutting
        // pages short client-side would make its paging lie.)
        final pageBranches =
            _allBranches ? _withinRadius(result.branches) : result.branches;

        _branchesTotal = result.total;

        if (append) {
          final existingIds = buildable.branches.map((b) => b.id).toSet();
          final unique =
              pageBranches.where((br) => !existingIds.contains(br.id)).toList();
          build((b) => b.copyWith(
                branches: [...b.branches, ...unique],
                branchesPage: page + 1,
                branchesTotalPages: result.totalPages,
                branchesLoaded: true,
              ));
        } else {
          build((b) => b.copyWith(
                branches: pageBranches,
                branchesPage: 2,
                branchesTotalPages: result.totalPages,
                branchesLoaded: true,
              ));

          // Map mode: walk the remaining pages so every centre gets a pin. Each
          // page appends, so the map fills in as they land rather than waiting
          // for the last one.
          if (_allBranches) {
            final lastPage = result.totalPages.clamp(1, _maxMapPages);
            for (var next = 2; next <= lastPage; next++) {
              await _fetchTab(tab, page: next, append: true);
            }
          }
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

  /// The centres running a class that matches the current filter.
  ///
  /// Walks the filtered class pages and keeps each distinct branch the results
  /// carry, deduped by id and skipping any without coordinates — a centre with
  /// no position cannot be a pin. Emits after every page so the map fills in
  /// as they land, the same way the unfiltered walk above does.
  Future<void> _fetchBranchesFromClasses() async {
    final q = _classQuery();
    final seen = <String>{};
    final branches = <HomBranch>[];

    for (var page = 1; page <= _maxMapPages; page++) {
      final result = await _repo.getDiscoveryClasses(
        page: page,
        limit: _mapPageLimit,
        search: q.search,
        categoryIds: q.categoryIds,
        fromDate: q.fromDate,
        toDate: q.toDate,
        age: q.age,
        classGender: q.classGender,
        minPrice: q.minPrice,
        maxPrice: q.maxPrice,
        lat: q.nearLat ?? _lat,
        lng: q.nearLng ?? _lng,
        districts: q.districts,
        kind: q.kind,
        radiusKm: q.radiusKm,
        fromTime: q.fromTime,
        toTime: q.toTime,
      );

      for (final item in result.classes) {
        final branch = item.branch;
        final id = branch?.id;
        if (branch == null || id == null || id.isEmpty) continue;
        if (branch.latitude == null || branch.longitude == null) continue;
        if (!seen.add(id)) continue;
        branches.add(branch);
      }

      _branchesTotal = branches.length;
      build((b) => b.copyWith(
            branches: [...branches],
            branchesPage: page + 1,
            // The map has no "load more", and these pins are the whole answer.
            branchesTotalPages: 1,
            branchesLoaded: true,
          ));

      if (page >= result.totalPages) break;
    }
  }

  /// The search this screen is showing — see [SearchSnapshot].
  SearchSnapshot get snapshot => SearchSnapshot(
        categories: buildable.selectedCategories,
        filter: buildable.filter,
        searchTerm: buildable.searchTerm,
      );

  /// Takes over the search the other view was left on, in ONE request.
  ///
  /// Does nothing when it is the search already on screen: the map loads every
  /// centre, and coming back from a list that changed nothing must not make it
  /// fetch them all again. The returning screen hands back the very objects it
  /// was given when nothing was touched, so identity is the test for the
  /// filter.
  void adoptSearch(SearchSnapshot search) {
    final current = buildable;
    final sameCategories = _categoryIds(search.categories) ==
        _categoryIds(current.selectedCategories);
    if (identical(search.filter, current.filter) &&
        sameCategories &&
        search.searchTerm == current.searchTerm) {
      return;
    }
    _debounce?.cancel();
    _leaveRecents();
    build((b) => b.copyWith(
          selectedCategories: search.categories,
          filter: search.filter,
          searchTerm: search.searchTerm,
        ));
    refresh();
  }

  static String _categoryIds(List<HomCategory> categories) =>
      categories.map((c) => c.id ?? '').join(',');

  /// Whether a filter describing a CLASS is on — anything but the radius,
  /// which describes where a centre is. See [_fetchTab].
  bool get _hasClassFilter =>
      activeFilterCount - ((buildable.filter?.hasRadius ?? false) ? 1 : 0) > 0;

  /// [branches] inside the filter's radius, or all of them without one. The
  /// same haversine distance the server's `radius_km` uses.
  List<HomBranch> _withinRadius(List<HomBranch> branches) {
    final f = buildable.filter;
    if (f == null || !f.hasRadius) return branches;
    final centre = UserLocation(f.nearLat!, f.nearLng!, isPrecise: true);
    final metres = f.radiusKm! * 1000;
    return branches.where((b) {
      final d = centre.metersTo(b.latitude, b.longitude);
      return d != null && d <= metres;
    }).toList();
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
    // Districts count once however many are ticked — the badge says "how many
    // filters are on", not "how many values did you pick".
    if (f.districts.isNotEmpty) count++;
    // Narrowing to activities or to courses is a filter like any other, and the
    // badge has to say so — otherwise "see all courses" lands on a filtered
    // screen showing no sign that anything is filtered.
    if (f.kind != ActivityKind.any) count++;
    if (f.hasTime) count++;
    if (f.hasRadius) count++;
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

/// The filter, flattened into the parameters `discovery/classes` takes.
class _ClassQuery {
  const _ClassQuery({
    this.search,
    this.categoryIds,
    this.fromDate,
    this.toDate,
    this.age,
    this.classGender,
    this.minPrice,
    this.maxPrice,
    this.districts,
    this.kind,
    this.radiusKm,
    this.nearLat,
    this.nearLng,
    this.fromTime,
    this.toTime,
  });

  final String? search;
  final List<String>? categoryIds;
  final String? fromDate;
  final String? toDate;
  final int? age;
  final String? classGender;
  final num? minPrice;
  final num? maxPrice;
  final List<String>? districts;
  final String? kind;
  final double? radiusKm;
  final double? nearLat;
  final double? nearLng;
  final String? fromTime;
  final String? toTime;
}

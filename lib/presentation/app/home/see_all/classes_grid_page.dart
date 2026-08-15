import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/common/utils/catalog_revision.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';

/// Which home row a [ClassesGridPage] is showing "all" of.
///
/// Only [near] is a real catalogue. `discovery/feed/`'s `new_classes` slice is
/// a fixed editorial set: the backend ignores `new_classes_page` and returns
/// the same handful of activities for every page, so [popular] is a single
/// page by definition and paging it would just re-request the same rows.
/// [near] covers the whole catalogue, which is what `discovery/classes` serves
/// directly — with `total`/`pages` and a `search` param the feed doesn't have.
enum HomeClassList {
  /// The "Популярное" row — `new_classes`. Fixed set, one page.
  popular,

  /// The "Рядом с вами" row — the full activity catalogue (courses excluded
  /// server-side).
  near,

  /// The "Курсы" row — courses only, via `discovery/courses`.
  courses;

  /// Whether the backend can page beyond the first response.
  bool get isPaged =>
      this == HomeClassList.near || this == HomeClassList.courses;

  /// One page of activities. Searching always goes through
  /// `discovery/classes`: it is the only endpoint that can filter, and it is
  /// also the only one that reports how many results exist.
  Future<ClassesPage> fetch(
    HomeRepository repo, {
    required int page,
    required int limit,
    String? search,
  }) async {
    final searching = search != null && search.isNotEmpty;

    // Courses have their own catalogue endpoint (kept out of discovery/classes).
    if (this == HomeClassList.courses) {
      return repo.getDiscoveryCourses(page: page, limit: limit, search: search);
    }

    if (isPaged || searching) {
      return repo.getDiscoveryClasses(page: page, limit: limit, search: search);
    }

    final model = await repo.getHome(newClassesLimit: limit);
    final classes = model.data?.newClasses?.data ?? const <HomClass>[];
    return ClassesPage(
      classes: classes,
      totalPages: 1,
      total: classes.length,
    );
  }
}

/// "View all" grid for a home activity row — the same [HomeCourseCard]s the row
/// shows, laid out two-up and paginated as you scroll.
///
/// Filtering is always server-side. The loaded pages are never the complete
/// catalogue, so filtering them locally would only ever search what happened to
/// already be on screen.
@RoutePage()
class ClassesGridPage extends StatefulWidget {
  const ClassesGridPage({
    super.key,
    required this.title,
    required this.list,
    this.initialClasses = const [],
  });

  final String title;
  final HomeClassList list;

  /// Whatever the home row had already loaded, so the grid opens populated.
  final List<HomClass> initialClasses;

  @override
  State<ClassesGridPage> createState() => _ClassesGridPageState();
}

class _ClassesGridPageState extends State<ClassesGridPage> {
  static const int _limit = 10;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  final _scrollController = ScrollController();

  /// Seeded from the home row purely so the grid paints instantly. It is *not*
  /// treated as loaded data — page 1 is always fetched and replaces it, because
  /// the row may hold an arbitrary, partial slice of the catalogue.
  late final List<HomClass> _classes = [...widget.initialClasses];

  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _hasMore = true;

  String _search = '';
  Timer? _debounce;

  /// Bumped on every reset so a page that resolves after the term changed
  /// (or after a faster keystroke overtook it) is dropped instead of being
  /// appended to results it doesn't belong to.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // A course card is priced per viewer, so a purchase made from this grid
    // (or from a detail page opened out of it) re-prices the rows behind it.
    // Without this the buyer returns to a card still offering the trial they
    // have just bought.
    catalogRevision.addListener(_restart);
    _loadMore();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    catalogRevision.removeListener(_restart);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300.h) {
      _loadMore();
    }
  }

  void _onSearchChanged(String term) {
    final trimmed = term.trim();
    if (trimmed == _search) return;
    _search = trimmed;

    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, _restart);
  }

  /// Drops the current results and re-fetches page 1 for the active term.
  void _restart() {
    if (!mounted) return;
    _requestId++;
    setState(() {
      _classes.clear();
      _page = 1;
      _totalPages = 1;
      _hasMore = true;
      _isLoading = false;
    });
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;
    final requestId = _requestId;
    final page = _page;
    setState(() => _isLoading = true);

    try {
      final result = await widget.list.fetch(
        getIt<HomeRepository>(),
        page: page,
        limit: _limit,
        search: _search,
      );

      if (!mounted || requestId != _requestId) return;

      setState(() {
        // Page 1 replaces the home-row seed rather than merging with it: the
        // seed can hold rows from any page, in a different order.
        if (page == 1) _classes.clear();

        final seen = _classes.map((c) => c.id).toSet();
        _classes.addAll(result.classes.where((c) => !seen.contains(c.id)));

        _totalPages = result.totalPages;
        _page = page + 1;
        // An empty page also stops us, so a `pages` count the server can't
        // actually deliver can't spin [_fillViewport] forever.
        _hasMore = result.classes.isNotEmpty && _page <= _totalPages;
        _isLoading = false;
      });

      _fillViewport();
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isLoading = false;
        _hasMore = false;
      });
    }
  }

  /// A short page leaves the grid unscrollable, and [_onScroll] only ever fires
  /// on a real scroll — so without this the list would sit there half-empty
  /// with more pages waiting. Keep pulling until the content overflows.
  void _fillViewport() {
    if (!_hasMore) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      if (_scrollController.position.maxScrollExtent <= 0) _loadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final showEmpty = _classes.isEmpty && !_isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchTopBar(
              title: widget.title,
              onBack: () => context.router.maybePop(),
            ),
            12.verticalSpace,
            SearchBarRow(
              initialTerm: _search,
              onChanged: _onSearchChanged,
            ),
            12.verticalSpace,
            Expanded(
              child: showEmpty
                  ? const SearchEmptyView()
                  : GridView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 20.h,
                        // image + gap + info, matching the home row's card.
                        mainAxisExtent: 126.h + 14.h + 118.h,
                      ),
                      itemCount: _classes.length + (_isLoading ? 2 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _classes.length) {
                          return _CardSkeleton(c: c);
                        }
                        final item = _classes[index];
                        return HomeCourseCard(
                          key: ValueKey(item.id ?? index),
                          homClass: item,
                          width: double.infinity,
                          margin: EdgeInsets.zero,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton({required this.c});

  final AppColorScheme c;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
}

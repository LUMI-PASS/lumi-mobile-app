import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/data/service/saved_activity_store.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/domain/repo/home/home_repository.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_common.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/category_grid_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_shortcut_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';

/// The **Qidiruv / Поиск** tab — second in the bottom nav, right after Home.
///
/// Search, opened on the categories instead of on a list: the search field, a
/// row of shortcuts (the map first) and every category as a card in a
/// two-column grid. It is a way IN to the existing search rather than a
/// replacement for it: the field, a shortcut, a category and "all categories"
/// each push the map or [SearchDiscoveryPage] in the state that entry asked
/// for, so results, filters, recents and paging stay where they already work.
///
/// A tab root, so there is no back button, and the pushes go to the ROOT
/// router — over the bottom nav, like every other screen a tab opens.
@RoutePage()
class SearchCategoriesPage extends StatefulWidget {
  const SearchCategoriesPage({super.key});

  @override
  State<SearchCategoriesPage> createState() => _SearchCategoriesPageState();
}

class _SearchCategoriesPageState extends State<SearchCategoriesPage> {
  /// Home has normally loaded these already (it seeds the cache), so the grid
  /// is on screen with the first frame rather than behind a request.
  List<HomCategory> _categories = SearchCubit.cachedCategories;
  bool _loading = false;

  /// How many activities each category holds, by category id, plus the whole
  /// catalogue under [_allKey] for the "Barcha kategoriyalar" card.
  ///
  /// Static, so coming back to the tab shows the numbers it showed last time
  /// instead of a grid of cards that grow a line each as the requests land.
  /// A category count moves when a centre publishes something, which is not
  /// often enough to be worth re-counting on every visit — [_load] refreshes it
  /// when the category list itself is re-fetched.
  static final Map<String, int> _counts = {};

  /// Key [_counts] uses for the catalogue total. Not a real category id, and
  /// cannot collide with one: ids are Mongo hex.
  static const String _allKey = '*all*';

  /// Set while the counts are in flight, so a rebuild (a tab switch, the
  /// keyboard) does not fire the whole batch a second time.
  bool _countsRequested = false;

  final _saved = getIt<SavedActivityStore>();

  @override
  void initState() {
    super.initState();
    if (_categories.isEmpty) {
      _load();
    } else {
      _loadCounts(_categories);
    }
  }

  StackRouter get _root => context.router.root;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final categories = await getIt<HomeRepository>().getAllCategories();
      if (categories.isNotEmpty) SearchCubit.cachedCategories = categories;
      if (!mounted) return;
      setState(() => _categories = categories);
      // Counted against the list we just got, not the cached one: a category
      // added since the last visit has no count yet, and an old count keyed to
      // a category that is gone would never be read.
      _countsRequested = false;
      _loadCounts(categories);
    } catch (_) {
      // The "all categories" card and the search field still work without the
      // list, so a failed fetch leaves a usable screen rather than an error.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Counts the catalogue, and then each category.
  ///
  /// There is no endpoint that returns these — `/api/categories` sends no
  /// count — so each one is asked for with the lightest request that can
  /// answer: page 1, ONE item, `kind: all`, filtered to that category. The
  /// single result row is thrown away and only `total` is kept. That makes the
  /// number on a card the number the grid will show when it is tapped, by
  /// construction: it IS the same query.
  ///
  /// Batched rather than fired all at once: a dozen categories is a dozen
  /// requests, and six in flight fills the grid top-down in a couple of rounds
  /// without putting the whole screen's worth on the wire at the same moment.
  ///
  /// Silent on failure, per category. A card whose count did not come back
  /// carries no line rather than a wrong one, and the rest of the grid is
  /// unaffected.
  Future<void> _loadCounts(List<HomCategory> categories) async {
    if (_countsRequested) return;
    _countsRequested = true;

    final ids = <String>[
      for (final category in categories)
        if ((category.id ?? '').isNotEmpty) category.id!,
    ];

    // The catalogue total first: it is the "all categories" card, which is the
    // first thing in the grid.
    await _countInto(_allKey, null);
    for (var i = 0; i < ids.length; i += _countBatch) {
      if (!mounted) return;
      final batch = ids.skip(i).take(_countBatch);
      await Future.wait([for (final id in batch) _countInto(id, id)]);
    }
  }

  /// How many counts are asked for at a time.
  static const int _countBatch = 6;

  /// Counts one slice of the catalogue into [_counts] under [key].
  /// [categoryId] null means "everything".
  Future<void> _countInto(String key, String? categoryId) async {
    try {
      final page = await getIt<HomeRepository>().getDiscoveryClasses(
        page: 1,
        limit: 1,
        kind: ActivityKind.any.queryValue,
        categoryIds: categoryId == null ? null : [categoryId],
      );
      _counts[key] = page.total;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  void _openSearch() {
    _root.push(SearchDiscoveryRoute(autofocusSearch: true));
  }

  void _openMap() {
    _root.push(BranchesMapRoute(categories: _categories));
  }

  /// Everything there is, which is what the discovery screen calls itself —
  /// "Barcha mashg'ulotlar". It opens unfiltered, so the count on the card is
  /// exactly what the list shows.
  ///
  /// This card used to say "Kurslar" and open courses alone. Courses are a
  /// narrowing of the catalogue, not a section beside it — they are still one
  /// tap away under the filter sheet's Type — and the shortcut row is for the
  /// ways IN, of which "all of it" is the one that was missing.
  void _openActivities() {
    _root.push(SearchDiscoveryRoute());
  }

  void _openSaved() {
    _root.push(const SavedActivitiesRoute());
  }

  void _openCategory(HomCategory? category) {
    _root.push(SearchDiscoveryRoute(initialCategory: category));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // A category with no resolved title would be a blank card.
    final categories =
        _categories.where((e) => (e.title ?? '').isNotEmpty).toList();
    final showSkeleton = _loading && categories.isEmpty;

    final cards = <Widget>[
      CategoryGridCard(
        title: 'all_categories'.tr(),
        count: _counts[_allKey],
        onTap: () => _openCategory(null),
        icon: Assets.icons.categoryAll.svg(
          width: 28.w,
          height: 28.w,
          colorFilter: const ColorFilter.mode(
            AppColors.brandPurple,
            BlendMode.srcIn,
          ),
        ),
      ),
      if (showSkeleton)
        for (var i = 0; i < 5; i++) const CategoryGridCardSkeleton()
      else
        for (final category in categories)
          CategoryGridCard(
            key: ValueKey(category.id),
            title: category.title ?? '',
            imageUrl: category.image,
            count: _counts[category.id],
            onTap: () => _openCategory(category),
          ),
    ];

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.verticalSpace,
            // A tab's own name, set left like the Bookings tab's — a root
            // screen has nothing to go back to, so no top bar.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'search_title'.tr(),
                style: AppText.heading20.copyWith(color: c.textPrimary),
              ),
            ),
            12.verticalSpace,
            // The real search field, as a button: typing happens on the
            // results screen, where the keyboard comes up with it. Drawing the
            // same widget keeps the two fields from drifting apart.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openSearch,
              child: IgnorePointer(
                child: SearchBarRow(initialTerm: '', onChanged: (_) {}),
              ),
            ),
            16.verticalSpace,
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // The other ways in, the map first. Only the ones that
                  // lead somewhere real: a shortcut to a list we cannot fill
                  // is worse than no shortcut.
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      // Three ways in, stretched to one height: where things
                      // are, everything there is, and what you kept. The last
                      // two carry a count, which is the whole reason they are
                      // worth a card rather than a line of text.
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SearchShortcutCard(
                                icon: Assets.icons.location,
                                color: AppColors.green,
                                label: 'map_title'.tr(),
                                onTap: _openMap,
                              ),
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: SearchShortcutCard(
                                icon: Assets.icons.home.book,
                                color: AppColors.brandPink,
                                label: 'activities'.tr(),
                                // No count here. It said the same number the
                                // "Barcha kategoriyalar" card below says, two
                                // rows apart, and a total beside "Saqlanganlar"
                                // read as though the two were comparable.
                                onTap: _openActivities,
                              ),
                            ),
                            8.horizontalSpace,
                            Expanded(
                              // Watches the store, so hearting something on a
                              // detail screen moves this number by the time the
                              // user is back on the tab.
                              child: ValueListenableBuilder<Set<String>>(
                                valueListenable: _saved.savedIds,
                                builder: (_, ids, __) => SearchShortcutCard(
                                  icon: Assets.icons.home.heart,
                                  color: AppColors.error,
                                  label: 'saved_title'.tr(),
                                  // Zero IS the truth here, unlike the
                                  // catalogue count: nothing saved is a fact
                                  // this device knows for certain, and saying
                                  // so is what explains the empty screen behind
                                  // the tap.
                                  count: ids.length,
                                  onTap: _openSaved,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: 24.verticalSpace),
                  SliverToBoxAdapter(
                    child: HomeSectionHeader(title: 'categories'.tr()),
                  ),
                  SliverToBoxAdapter(child: 12.verticalSpace),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      0,
                      16.w,
                      // Clears the floating bottom nav, as Home's feed does.
                      24.h + 64.0 + MediaQuery.viewPaddingOf(context).bottom,
                    ),
                    sliver: SliverList.separated(
                      itemCount: (cards.length / 2).ceil(),
                      separatorBuilder: (_, __) => 8.verticalSpace,
                      // Two columns on the page's 16pt margin with an 8pt
                      // gutter, as the results grid. Rows rather than a grid
                      // delegate, because a grid needs one fixed height and a
                      // card is as tall as its name: the pair in a row match
                      // each other, and a two-line name grows only its row.
                      itemBuilder: (_, row) {
                        final right = row * 2 + 1;
                        return IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: cards[row * 2]),
                              8.horizontalSpace,
                              Expanded(
                                child: right < cards.length
                                    ? cards[right]
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

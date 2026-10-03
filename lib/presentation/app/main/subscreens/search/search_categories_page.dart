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

  @override
  void initState() {
    super.initState();
    if (_categories.isEmpty) _load();
  }

  StackRouter get _root => context.router.root;

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final categories = await getIt<HomeRepository>().getAllCategories();
      if (categories.isNotEmpty) SearchCubit.cachedCategories = categories;
      if (!mounted) return;
      setState(() => _categories = categories);
    } catch (_) {
      // The "all categories" card and the search field still work without the
      // list, so a failed fetch leaves a usable screen rather than an error.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openSearch() {
    _root.push(SearchDiscoveryRoute(autofocusSearch: true));
  }

  void _openMap() {
    _root.push(BranchesMapRoute(categories: _categories));
  }

  void _openCourses() {
    _root.push(SearchDiscoveryRoute(initialKind: ActivityKind.courses));
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
                                label: 'courses'.tr(),
                                onTap: _openCourses,
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

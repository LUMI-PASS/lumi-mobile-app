import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_class_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';

/// Discovery / search screen (Figma `Поиск`).
///
/// Header, search field, the two result tabs, the "view on map" row, the
/// result count and a two-column grid of results — or the empty state when a
/// tab has nothing to show.
///
/// Shared by the root bottom-nav tab and the pushed screen; the only
/// difference is the back button, so [onBack] is null on the tab.
class SearchView extends StatefulWidget {
  const SearchView({
    super.key,
    required this.state,
    this.onBack,
    this.autofocusSearch = false,
  });

  final SearchBuildable state;

  /// Raises the keyboard on the search field as soon as the screen opens — set
  /// when the user got here by tapping Home's search field.
  final bool autofocusSearch;

  /// Omit on the root tab — there is nothing behind it to go back to.
  final VoidCallback? onBack;

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final _scrollController = ScrollController();

  /// A class card carries a provider tag and a price under the photo, so it is
  /// taller than a centre's. Extents are image + gap + info block, as in
  /// [ClassesGridPage].
  static const _classCardExtent = 126.0 + 14.0 + 118.0;
  static const _branchCardExtent = 185.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Page in the next results once the user is within a screenful of the end.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) {
      context.read<SearchCubit>().loadMore();
    }
  }

  /// What the screen is showing, named at the top.
  ///
  /// A category filter is *not* named here — the removable chip above the map
  /// row already carries it, and repeating it in the title said the same word
  /// twice while implying the screen was locked to that category.
  /// Follows the chips rather than the entry point: arriving from Home's "see
  /// all activities" opens on Mashg'ulotlar and reads as such, but the user can
  /// switch chips from here and the header must not keep claiming the old one.
  ///
  /// The type filter deliberately does NOT rename it. It is a filter over this
  /// list like age or price, and none of those rename the screen either — the
  /// filter badge is what says one is on.
  ///
  /// On the recents screen it names THAT — the screen is not showing "all
  /// activities", it is showing the handful the user looked at last.
  String get _title {
    if (widget.state.showRecents) return 'search_title'.tr();
    return widget.state.activeTab == kSearchTabBranches
        ? 'search_tab_centers'.tr()
        : 'all_activities'.tr();
  }

  Future<void> _openFilter() async {
    final cubit = context.read<SearchCubit>();
    final result = await FilterBottomSheet.show(
      context,
      initial: widget.state.filter,
    );
    if (result != null) cubit.applyFilter(result);
  }

  void _openMap() {
    context.router.push(
      BranchesMapRoute(
        branches: widget.state.branches,
        categories: widget.state.categories,
        selectedCategories: widget.state.selectedCategories,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<SearchCubit>();
    final state = widget.state;

    // Opened from Home's search field with nothing typed yet: the screen shows
    // what this user last looked for, not a page of the whole catalog.
    final showRecents = state.showRecents;
    final isClasses = state.activeTab != kSearchTabBranches;
    final items = showRecents
        ? state.recentClasses
        : (isClasses ? state.classes : state.branches);

    // The active category filters, shown as removable chips — one per pick,
    // multi-select. A category with no resolved title would render as a bare
    // × — skip it rather than show that.
    final selectedCategories = state.selectedCategories
        .where((c) => (c.title ?? '').isNotEmpty)
        .toList();

    // Two columns with a 16pt page margin and an 8pt gutter (Figma).
    final columnWidth = (1.sw - 32.w - 8.w) / 2;

    return Scaffold(
      backgroundColor: c.scaffoldBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.verticalSpace,
            SearchTopBar(title: _title, onBack: widget.onBack),
            16.verticalSpace,
            SearchBarRow(
              initialTerm: state.searchTerm,
              onChanged: cubit.setSearchTerm,
              onFilterTap: _openFilter,
              filterCount: cubit.activeFilterCount,
              autofocus: widget.autofocusSearch,
            ),
            // The recents screen carries none of the result furniture: there
            // are no tabs to switch, no total to count and no map to plot —
            // those all describe a search that has not been made yet.
            if (showRecents) ...[
              24.verticalSpace,
              _RecentHeader(onClear: cubit.clearRecents),
              14.verticalSpace,
            ] else ...[
              16.verticalSpace,
              SearchChips(
                // Two chips, and one of them is always lit. Courses used to be
                // a third: they now share the first list with activities, and
                // narrowing to them is a filter (see `ActivityKind`) rather
                // than a place. Display order matches the tab indices, so no
                // remap.
                labels: [
                  'search_tab_classes'.tr(),
                  'search_tab_centers'.tr(),
                ],
                activeIndex: state.activeTab,
                onSelect: cubit.setTab,
              ),
              if (selectedCategories.isNotEmpty) ...[
                16.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final cat in selectedCategories)
                        SearchCategoryChip(
                          label: cat.title ?? '',
                          onRemove: () => cubit.toggleCategory(cat),
                        ),
                    ],
                  ),
                ),
              ],
              16.verticalSpace,
              SearchMapCard(onTap: _openMap),
              24.verticalSpace,
              SearchCountRow(count: cubit.resultCount),
              14.verticalSpace,
            ],
            Expanded(
              child: Builder(
                builder: (context) {
                  final grid = SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 14.h,
                    mainAxisExtent: (isClasses || showRecents
                            ? _classCardExtent
                            : _branchCardExtent)
                        .h,
                  );
                  final padding = EdgeInsets.fromLTRB(
                    16.w,
                    0,
                    16.w,
                    MediaQuery.of(context).padding.bottom + 24.h,
                  );

                  if (showRecents) {
                    return GridView.builder(
                      controller: _scrollController,
                      padding: padding,
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      gridDelegate: grid,
                      itemCount: state.recentClasses.length,
                      itemBuilder: (context, index) {
                        final model = state.recentClasses[index];
                        return HomeCourseCard(
                          key: ValueKey(model.id ?? index),
                          homClass: model,
                          width: double.infinity,
                          margin: EdgeInsets.zero,
                          // Re-opening one moves it back to the front, so the
                          // list stays ordered by what the user actually keeps
                          // coming back to.
                          onOpen: () => cubit.rememberRecent(model),
                        );
                      },
                    );
                  }
                  if (state.isLoading) {
                    return GridView.builder(
                      padding: padding,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: grid,
                      itemCount: 6,
                      itemBuilder: (_, __) => _CardSkeleton(c: c),
                    );
                  }
                  if (items.isEmpty) return const SearchEmptyView();

                  return RefreshIndicator(
                    onRefresh: cubit.refresh,
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: padding,
                      physics: const AlwaysScrollableScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      gridDelegate: grid,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        if (isClasses) {
                          final model = state.classes[index];
                          return HomeCourseCard(
                            key: ValueKey(model.id ?? index),
                            homClass: model,
                            width: double.infinity,
                            margin: EdgeInsets.zero,
                            // What the user opens from a search IS the search,
                            // as far as this screen is concerned — it is what
                            // greets them next time (see [showRecents]).
                            onOpen: () => cubit.rememberRecent(model),
                          );
                        }
                        final branch = state.branches[index];
                        return SearchBranchCard(
                          key: ValueKey(branch.id ?? index),
                          branch: branch,
                          width: columnWidth,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            if (state.isLoadingMore)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Center(
                  child: SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder tile shown while the first page of results loads — matches the
/// skeleton the see-all grids use.
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

/// "Recent searches" + the control that empties them.
class _RecentHeader extends StatelessWidget {
  const _RecentHeader({required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'recent_searches'.tr(),
              style: AppText.semibold16.copyWith(color: c.textPrimary),
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClear,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              child: Text(
                'recent_clear'.tr(),
                style: AppText.medium13.copyWith(color: c.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

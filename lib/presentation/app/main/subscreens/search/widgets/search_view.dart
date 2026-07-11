import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
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
    this.classesOnly = false,
  });

  final SearchBuildable state;

  /// Omit on the root tab — there is nothing behind it to go back to.
  final VoidCallback? onBack;

  /// Drops the Darslar / Ta'lim markazlari chips and the result count, leaving
  /// every activity behind the search field and the filters. Set when the
  /// screen is opened as "see all activities" from Home, where the user asked
  /// for one list and switching it to centres would be a non-sequitur.
  final bool classesOnly;

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
  /// Opened from a category, it is that category — the user tapped "Sport", so
  /// the screen says "Sport" rather than the generic "Izlash", and they can see
  /// what the list is filtered to. Opened as see-all, it is every activity.
  String _title(SearchBuildable state) {
    if (state.selectedCategory != null) {
      final name = state.selectedCategory!.title ?? '';
      if (name.isNotEmpty) return name;
    }
    if (widget.classesOnly) return 'all_activities'.tr();
    return 'search'.tr();
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
        selectedCategory: widget.state.selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final cubit = context.read<SearchCubit>();
    final state = widget.state;
    final isClasses = widget.classesOnly || state.activeTab == 0;
    final items = isClasses ? state.classes : state.branches;

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
            SearchTopBar(title: _title(state), onBack: widget.onBack),
            16.verticalSpace,
            SearchBarRow(
              initialTerm: state.searchTerm,
              onChanged: cubit.setSearchTerm,
              onFilterTap: _openFilter,
              filterCount: cubit.activeFilterCount,
            ),
            if (!widget.classesOnly) ...[
              16.verticalSpace,
              SearchChips(
                labels: [
                  'search_tab_classes'.tr(),
                  'search_tab_centers'.tr(),
                ],
                activeIndex: state.activeTab,
                onSelect: cubit.setTab,
              ),
            ],
            16.verticalSpace,
            SearchMapCard(onTap: _openMap),
            24.verticalSpace,
            if (!widget.classesOnly) ...[
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
                    mainAxisExtent:
                        (isClasses ? _classCardExtent : _branchCardExtent).h,
                  );
                  final padding = EdgeInsets.fromLTRB(
                    16.w,
                    0,
                    16.w,
                    MediaQuery.of(context).padding.bottom + 24.h,
                  );

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

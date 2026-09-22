import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/branches_map_view.dart';

/// The **Xarita / Карта** tab — second in the bottom nav, right after Home.
///
/// The same [BranchesMapView] the pushed "На карте" screen shows, minus the
/// back button. Nothing extra is needed to clear the nav pill: the tabs
/// scaffold runs with `extendBody: true`, so Flutter reports the bar's height
/// to this body as `MediaQuery.padding.bottom` and the map reads it there.
///
/// Every centre is plotted at once — `allBranches` walks the pages — and the
/// controls on top narrow them: the search term, the category, and the
/// results screen's own filter sheet.
@RoutePage()
class MapPage extends BasePage<SearchCubit, SearchBuildable, SearchListenable> {
  const MapPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<SearchCubit>().init(
          tab: kSearchTabBranches,
          allBranches: true,
        );
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    context.read<SearchCubit>().refreshIfLanguageChanged();
    super.onFocusGained(context);
  }

  @override
  Widget builder(BuildContext context, SearchBuildable state) {
    return BranchesMapView(
      branches: state.branches,
      branchesLoaded: state.branchesLoaded,
      isLoading: state.isLoading,
      seed: const [],
      categories: state.categories,
      selectedCategories: state.selectedCategories,
      searchTerm: state.searchTerm,
      filter: state.filter,
      filterCount: context.read<SearchCubit>().activeFilterCount,
    );
  }
}

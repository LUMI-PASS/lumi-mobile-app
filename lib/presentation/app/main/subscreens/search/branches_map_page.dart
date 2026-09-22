import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/branches_map_view.dart';

/// "На карте" — the centres of the current search plotted on a map (Figma
/// `На карте`), PUSHED from the search results.
///
/// It carries over what that screen had loaded and lands showing it, so the
/// map is never empty while its own fetch runs. The map tab (`MapPage`) shows
/// the same [BranchesMapView] with no back button and nothing to carry over.
@RoutePage()
class BranchesMapPage
    extends BasePage<SearchCubit, SearchBuildable, SearchListenable> {
  const BranchesMapPage({
    super.key,
    this.branches = const [],
    this.categories = const [],
    this.selectedCategories = const [],
  });

  /// Results already loaded by the search screen — shown immediately so the
  /// map isn't empty while the branches tab loads.
  final List<HomBranch> branches;
  final List<HomCategory> categories;
  final List<HomCategory> selectedCategories;

  @override
  void init(BuildContext context) {
    // `allBranches` — the map plots pins, so it needs every centre, not the
    // first page the list screens work through.
    context.read<SearchCubit>().init(
          tab: kSearchTabBranches,
          categories: selectedCategories,
          allBranches: true,
        );
    super.init(context);
  }

  @override
  Widget builder(BuildContext context, SearchBuildable state) {
    final categories =
        state.categories.isEmpty ? this.categories : state.categories;

    return BranchesMapView(
      branches: state.branches,
      branchesLoaded: state.branchesLoaded,
      isLoading: state.isLoading,
      seed: branches,
      categories: categories,
      selectedCategories: state.selectedCategories,
      searchTerm: state.searchTerm,
      filter: state.filter,
      filterCount: context.read<SearchCubit>().activeFilterCount,
      onBack: () => context.router.maybePop(),
    );
  }
}

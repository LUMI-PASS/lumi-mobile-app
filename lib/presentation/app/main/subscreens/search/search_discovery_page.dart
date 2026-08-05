import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_view.dart';

/// The pushed discovery screen — same view as the [SearchPage] tab, but with a
/// back button and an optional category to open on (tapping a category on home
/// lands here already filtered).
@RoutePage()
class SearchDiscoveryPage
    extends BasePage<SearchCubit, SearchBuildable, SearchListenable> {
  const SearchDiscoveryPage({
    super.key,
    this.initialCategory,
    this.initialTab,
    this.autofocusSearch = false,
  });

  final HomCategory? initialCategory;

  /// Which type chip to open lit: 0 activities, 2 courses (1 is centres, which
  /// nothing links to yet). Null — the usual case — opens with none lit and
  /// activities and courses merged into one grid. Only Home's two "see all"
  /// rows pass a value, because only there did the user name a type.
  final int? initialTab;

  /// Opens with the keyboard already up. Home's header search field comes in
  /// this way — the tap was the user asking to type. Category taps and
  /// "see all" don't, since those arrive with the list they wanted.
  final bool autofocusSearch;

  @override
  void init(BuildContext context) {
    context.read<SearchCubit>().init(
          tab: initialTab ?? kSearchTabAll,
          category: initialCategory,
        );
    super.init(context);
  }

  @override
  Widget builder(BuildContext context, SearchBuildable state) {
    return SearchView(
      state: state,
      onBack: () => context.router.maybePop(),
      autofocusSearch: autofocusSearch,
    );
  }
}

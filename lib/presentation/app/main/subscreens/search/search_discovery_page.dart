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
    this.classesOnly = false,
    this.autofocusSearch = false,
  });

  final HomCategory? initialCategory;

  /// Opens with the keyboard already up. Home's header search field comes in
  /// this way — the tap was the user asking to type. Category taps and
  /// "see all" don't, since those arrive with the list they wanted.
  final bool autofocusSearch;

  /// Opens as an activities-only list — no Darslar / Ta'lim markazlari chips,
  /// just every activity behind the search field and filters. Home's
  /// "see all popular activities" comes in this way.
  final bool classesOnly;

  @override
  void init(BuildContext context) {
    context.read<SearchCubit>().init(category: initialCategory);
    super.init(context);
  }

  @override
  Widget builder(BuildContext context, SearchBuildable state) {
    return SearchView(
      state: state,
      onBack: () => context.router.maybePop(),
      classesOnly: classesOnly,
      autofocusSearch: autofocusSearch,
    );
  }
}

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/data/api_model/home_model/home_model.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/filter_bottom_sheet.dart';
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
    this.initialKind = ActivityKind.any,
    this.autofocusSearch = false,
  });

  final HomCategory? initialCategory;

  /// Opens with the type filter already set to this.
  ///
  /// [ActivityKind.courses] is how Home's "see all courses" arrives: that row
  /// named a type, so the screen it opens should be narrowed to it. It lands as
  /// a real, visible filter — the badge counts it and the sheet shows it
  /// selected — so the user can widen back to everything without guessing why
  /// the list looked short. [ActivityKind.any], the default, shows both.
  final ActivityKind initialKind;

  /// Opens with the keyboard already up. Home's header search field comes in
  /// this way — the tap was the user asking to type. Category taps and
  /// "see all" don't, since those arrive with the list they wanted.
  final bool autofocusSearch;

  @override
  void init(BuildContext context) {
    context.read<SearchCubit>().init(
          category: initialCategory,
          filter: initialKind == ActivityKind.any
              ? null
              : FilterResult(kind: initialKind),
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

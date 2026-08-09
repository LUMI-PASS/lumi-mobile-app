import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/businesses_coming_page.dart';

/// Учреждения / Muassasalar tab.
///
/// The centres feature is not ready, so the tab shows [BusinessesComingPage]
/// rather than the search screen. It still loads the branches (tab 1) — they
/// are what the coming-soon card is frosted over, so the user gets a real
/// preview of the section rather than a grey placeholder.
///
/// The working search lives on the pushed `SearchDiscoveryPage`.
@RoutePage()
class SearchPage
    extends BasePage<SearchCubit, SearchBuildable, SearchListenable> {
  const SearchPage({super.key});

  @override
  void init(BuildContext context) {
    context.read<SearchCubit>().init(tab: kSearchTabBranches);
    super.init(context);
  }

  @override
  void onFocusGained(BuildContext context) {
    context.read<SearchCubit>().refreshIfLanguageChanged();
    super.onFocusGained(context);
  }

  @override
  Widget builder(BuildContext context, SearchBuildable state) {
    return BusinessesComingPage(state: state);
  }
}

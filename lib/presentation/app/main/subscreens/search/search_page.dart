import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_cubit.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_coming_soon.dart';

/// Учреждения / Explore tab. The discovery feature isn't live yet, so the tab
/// shows the "coming soon" placeholder.
///
/// A root tab has nothing behind it, so no back button — the user leaves via
/// the bottom nav. The pushed [SearchComingSoonPage] is the one that gets one.
@RoutePage()
class SearchPage
    extends BasePage<SearchCubit, SearchBuildable, SearchListenable> {
  @override
  Widget builder(BuildContext context, SearchBuildable state) {
    return const SearchComingSoonView();
  }
}

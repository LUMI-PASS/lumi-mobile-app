import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_coming_soon.dart';

/// Full-screen Учреждения / Explore screen pushed from Home. The feature is not
/// live yet, so it shows the "coming soon" placeholder with a back button.
@RoutePage()
class SearchComingSoonPage extends StatelessWidget {
  const SearchComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SearchComingSoonView(onBack: () => context.router.maybePop());
  }
}

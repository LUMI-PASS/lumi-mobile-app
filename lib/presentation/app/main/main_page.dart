import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/widgets/coupon_promo_dialog.dart';
import 'package:lumi_pass/presentation/app/main/widgets/custom_bottomnavigation.dart';
import 'package:lumi_pass/presentation/app/main/widgets/onboarding_bottomsheet.dart';
import 'package:lumi_pass/presentation/app/main/widgets/profile_prompt_banner.dart';

/// Index of the Profile tab in [MainPage]'s bottom nav. Keep in sync with the
/// `routes` list in [_MainPageState.build] and `_tabs` in [CustomBottomBar].
const int profileTabIndex = 4;

/// Switches the bottom nav to the Profile tab. Callable from anywhere inside a
/// tab (e.g. the Home header), since it walks up to [MainPage]'s tabs router.
void openProfileTab(BuildContext context) =>
    AutoTabsRouter.of(context).setActiveIndex(profileTabIndex);

@RoutePage()
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _storage = getIt<Storage>();

  late bool _showPrompt = _promptIsDue();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // A new user is no longer stopped at the door for their name and child —
      // the banner above the nav asks for those, whenever they feel like it. The
      // flag is still consumed here so the one-time "get coupon" reward popup
      // fires once, for the users who came in registering.
      if (_storage.needsOnboarding.call() != true) return;
      _storage.needsOnboarding.set(false);

      if (_storage.couponPromoShown.call() != true) {
        _storage.couponPromoShown.set(true);
        await Future.delayed(const Duration(milliseconds: 350));
        if (!mounted) return;
        showCouponPromoDialog(
          context,
          onGetCoupon: () => context.router.push(const PlansRoute()),
        );
      }
    });
  }

  /// Ask only while there is something to ask for: the prompt is gone once the
  /// user has closed it, and once they have actually given us a name.
  bool _promptIsDue() =>
      _storage.profilePromptDismissed.call() != true &&
      (_storage.parentName.call() ?? '').isEmpty;

  void _dismissPrompt() {
    _storage.profilePromptDismissed.set(true);
    setState(() => _showPrompt = false);
  }

  /// The banner's own CTA — the same name + child form that used to be forced
  /// on first launch, now opened on purpose.
  Future<void> _openProfileForm() async {
    await showOnboardingBottomsheet(context);
    if (!mounted) return;
    // Filling it in retires the banner; backing out leaves it up.
    setState(() => _showPrompt = _promptIsDue());
  }

  @override
  Widget build(context) {
    // Subscribe to locale changes so the bottom nav labels update immediately.
    context.locale;

    final routes = <PageRouteInfo>[
      const HomeRoute(),
      const ShortsRoute(),
      const CalendarRoute(),
      const SearchRoute(),
      ProfileRoute(),
    ];

    return AutoTabsScaffold(
      extendBody: true,
      routes: routes,
      // The banner is built here, not inside a tab, so it rides above the nav on
      // every tab and survives switching between them.
      bottomNavigationBuilder: (context, tabsRouter) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showPrompt)
              ProfilePromptBanner(
                onTap: _openProfileForm,
                onDismiss: _dismissPrompt,
              ),
            CustomBottomBar(
              selectedIndex: tabsRouter.activeIndex,
              onItemSelected: tabsRouter.setActiveIndex,
            ),
          ],
        );
      },
    );
  }
}

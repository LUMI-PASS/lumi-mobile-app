import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/widgets/coupon_promo_dialog.dart';
import 'package:lumi_pass/presentation/app/main/widgets/custom_bottomnavigation.dart';
import 'package:lumi_pass/presentation/app/main/widgets/onboarding_bottomsheet.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storage = getIt<Storage>();
      // Only users who came in registering see the onboarding sheet — and,
      // once they dismiss it, the one-time premium "get coupon" reward popup.
      if (storage.needsOnboarding.call() == true) {
        await showOnboardingBottomsheet(context);
        if (!mounted) return;
        if (storage.couponPromoShown.call() != true) {
          storage.couponPromoShown.set(true);
          await Future.delayed(const Duration(milliseconds: 350));
          if (!mounted) return;
          showCouponPromoDialog(
            context,
            onGetCoupon: () => context.router.push(const PlansRoute()),
          );
        }
      }
    });
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
      bottomNavigationBuilder: (context, tabsRouter) {
        return CustomBottomBar(
          selectedIndex: tabsRouter.activeIndex,
          onItemSelected: tabsRouter.setActiveIndex,
        );
      },
    );
  }
}

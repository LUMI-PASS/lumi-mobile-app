import 'package:auto_route/auto_route.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:flutter/material.dart';

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(context) {
    return AutoTabsScaffold(
      routes: const [
        HomeRoute(),
        CalendarRoute(),
        SearchRoute(),
        WalletRoute(),
        ProfileRoute(),
      ],
      bottomNavigationBuilder: (context, tabsRouter) {
        return BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          selectedItemColor: context.colors.primary,
          unselectedItemColor: context.colors.title.withOpacity(0.5),
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              activeIcon: Assets.icons.homeFilled.svg(),
              icon: Assets.icons.homeFilled.svg(color: context.colors.black),
              label: "",
            ),
            BottomNavigationBarItem(
              activeIcon: Assets.icons.calendarSelected.svg(),
              icon: Assets.icons.calendar.svg(),
              label: "",
            ),
            BottomNavigationBarItem(
              activeIcon: Assets.icons.searchSelected.svg(),
              icon: Assets.icons.searchUnselected.svg(),
              label: "",
            ),
            BottomNavigationBarItem(
              activeIcon: Assets.icons.walletUnselected
                  .svg(color: context.colors.primary),
              icon: Assets.icons.walletUnselected.svg(),
              label: "",
            ),
            BottomNavigationBarItem(
              activeIcon: Assets.icons.profilelUnselected
                  .svg(color: context.colors.primary),
              icon: Assets.icons.profilelUnselected.svg(),
              label: "",
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int currentIndex,
    required VoidCallback onPressed,
    required Widget activeIcon,
    required Widget inactiveIcon,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onPressed.call(),
      child: isSelected ? activeIcon : inactiveIcon,
    );
  }
}

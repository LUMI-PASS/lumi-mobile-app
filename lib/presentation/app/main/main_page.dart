import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/service/remote_config_service.dart';

@RoutePage()
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(context) {
    final isInReview = RemoteConfigService.instance.isInReview;

    final routes = <PageRouteInfo>[
      const HomeRoute(),
      const CalendarRoute(),
      const SearchRoute(),
      if (!isInReview) const WalletRoute(),
      const ProfileRoute(),
    ];

    return AutoTabsScaffold(
      routes: routes,
      bottomNavigationBuilder: (context, tabsRouter) {
        final primary = context.colors.primary;
        final inactive = Colors.black;

        final navItems = <_NavItem>[
          _NavItem(
            index: 0,
            currentIndex: tabsRouter.activeIndex,
            activeIcon: Assets.icons.homeFilled.svg(
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn)),
            inactiveIcon: Assets.icons.homeFilled.svg(
                colorFilter: ColorFilter.mode(inactive, BlendMode.srcIn)),
            label: 'tab_home'.tr(),
            activeColor: primary,
            onTap: () => tabsRouter.setActiveIndex(0),
          ),
          _NavItem(
            index: 1,
            currentIndex: tabsRouter.activeIndex,
            activeIcon: Assets.icons.calendarSelected.svg(),
            inactiveIcon: Assets.icons.calendar.svg(
                colorFilter: ColorFilter.mode(inactive, BlendMode.srcIn)),
            label: 'tab_calendar'.tr(),
            activeColor: primary,
            onTap: () => tabsRouter.setActiveIndex(1),
          ),
          _NavItem(
            index: 2,
            currentIndex: tabsRouter.activeIndex,
            activeIcon: Assets.icons.searchSelected.svg(),
            inactiveIcon: Assets.icons.searchUnselected.svg(
                colorFilter: ColorFilter.mode(inactive, BlendMode.srcIn)),
            label: 'tab_explore'.tr(),
            activeColor: primary,
            onTap: () => tabsRouter.setActiveIndex(2),
          ),
          if (!isInReview)
            _NavItem(
              index: 3,
              currentIndex: tabsRouter.activeIndex,
              activeIcon: Assets.icons.walletUnselected.svg(
                  colorFilter: ColorFilter.mode(primary, BlendMode.srcIn)),
              inactiveIcon: Assets.icons.walletUnselected.svg(
                  colorFilter: ColorFilter.mode(inactive, BlendMode.srcIn)),
              label: 'tab_wallet'.tr(),
              activeColor: primary,
              onTap: () => tabsRouter.setActiveIndex(3),
            ),
          _NavItem(
            index: isInReview ? 3 : 4,
            currentIndex: tabsRouter.activeIndex,
            activeIcon: Assets.icons.profilelUnselected.svg(
                colorFilter: ColorFilter.mode(primary, BlendMode.srcIn)),
            inactiveIcon: Assets.icons.profilelUnselected.svg(
                colorFilter: ColorFilter.mode(inactive, BlendMode.srcIn)),
            label: 'tab_profile'.tr(),
            activeColor: primary,
            onTap: () => tabsRouter.setActiveIndex(isInReview ? 3 : 4),
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: navItems,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.index,
    required this.currentIndex,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.activeColor,
    required this.onTap,
  });

  final int index;
  final int currentIndex;
  final Widget activeIcon;
  final Widget inactiveIcon;
  final String label;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 14.w : 12.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: isSelected ? activeIcon : inactiveIcon,
            ),
            3.verticalSpace,
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 10.sp : 9.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : Colors.black,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

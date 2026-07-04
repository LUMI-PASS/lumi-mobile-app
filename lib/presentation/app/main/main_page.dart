import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/widgets/coupon_promo_dialog.dart';
import 'package:lumi_pass/presentation/app/main/widgets/onboarding_bottomsheet.dart';

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
        return _CustomBottomBar(
          selectedIndex: tabsRouter.activeIndex,
          onItemSelected: tabsRouter.setActiveIndex,
        );
      },
    );
  }
}

// ── Bottom bar ───────────────────────────────────────────────────────────────

class _CustomBottomBar extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _CustomBottomBar({
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<_CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<_CustomBottomBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  int _fromIdx = 0;
  int _toIdx = 0;

  static const _count = 5;
  static const _barH = 56.0;
  static const _hMargin = 20.0;
  static const _vPad = 8.0;
  static const _pillH = 50.0;
  static const _barRadius = 24.0;

  static const _spring =
      SpringDescription(mass: 1, stiffness: 400, damping: 26);

  double _itemCenterX(int index, double barWidth) {
    final itemW = barWidth / _count;
    return itemW * index + itemW / 2;
  }

  double _pillWidth(double barWidth) => barWidth / _count;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this)..value = 1.0;
    _fromIdx = widget.selectedIndex;
    _toIdx = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(_CustomBottomBar old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex == widget.selectedIndex) return;
    _fromIdx = old.selectedIndex;
    _toIdx = widget.selectedIndex;
    _ctrl.value = 0;
    _ctrl.animateWith(SpringSimulation(_spring, 0, 1, 0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final bottomPad = MediaQuery.of(context).viewPadding.bottom;
    final barW = sw - 2 * _hMargin;
    final pW = _pillWidth(barW);

    return SizedBox(
      height: _barH + _vPad + bottomPad,
      child: Padding(
        padding: EdgeInsets.only(
          left: _hMargin,
          right: _hMargin,
          top: _vPad,
          bottom: bottomPad,
        ),
        child: _GlassBar(
          barW: barW,
          barH: _barH,
          pillW: pW,
          pillH: _pillH,
          barRadius: _barRadius,
          ctrl: _ctrl,
          fromIdx: _fromIdx,
          toIdx: _toIdx,
          itemCenterX: _itemCenterX,
          navItems: _navItems(context),
        ),
      ),
    );
  }

  List<_NavItem> _navItems(BuildContext context) {
    final primary = context.colors.primary;
    const inactive = Color(0xFF6D717C);
    return [
      _NavItem(
        index: 0,
        activeIcon: Assets.icons.homeFilled.svg(
          colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
        ),
        inactiveIcon: Assets.icons.homeFilled.svg(
          colorFilter: const ColorFilter.mode(inactive, BlendMode.srcIn),
        ),
        label: 'tab_home'.tr(),
        onTap: () => widget.onItemSelected(0),
      ),
      _NavItem(
        index: 1,
        activeIcon:
            Icon(Icons.play_circle_fill_rounded, color: primary, size: 22),
        inactiveIcon: const Icon(Icons.play_circle_outline_rounded,
            color: inactive, size: 22),
        label: 'tab_shorts'.tr(),
        onTap: () => widget.onItemSelected(1),
      ),
      _NavItem(
        index: 2,
        activeIcon: Assets.icons.calendarSelected.svg(),
        inactiveIcon: Assets.icons.calendar.svg(
          colorFilter: const ColorFilter.mode(inactive, BlendMode.srcIn),
        ),
        label: 'tab_bookings'.tr(),
        onTap: () => widget.onItemSelected(2),
      ),
      _NavItem(
        index: 3,
        activeIcon: Assets.icons.searchSelected.svg(),
        inactiveIcon: Assets.icons.searchUnselected.svg(
          colorFilter: const ColorFilter.mode(inactive, BlendMode.srcIn),
        ),
        label: 'tab_explore'.tr(),
        onTap: () => widget.onItemSelected(3),
      ),
      _NavItem(
        index: 4,
        activeIcon: Assets.icons.profilelUnselected.svg(
          colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
        ),
        inactiveIcon: Assets.icons.profilelUnselected.svg(
          colorFilter: const ColorFilter.mode(inactive, BlendMode.srcIn),
        ),
        label: 'tab_profile'.tr(),
        onTap: () => widget.onItemSelected(4),
      ),
    ];
  }
}

// ── Shared data ──────────────────────────────────────────────────────────────

class _NavItem {
  final int index;
  final Widget activeIcon;
  final Widget inactiveIcon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.onTap,
  });
}

class _NavItemWidget extends StatelessWidget {
  final _NavItem item;
  final int selectedIndex;
  final double barH;
  final Color activeColor;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.selectedIndex,
    required this.barH,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedIndex == item.index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          height: barH,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: SizedBox(
                  key: ValueKey(isSelected),
                  width: 22,
                  height: 22,
                  child: isSelected ? item.activeIcon : item.inactiveIcon,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  height: 1.0,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w400,
                  letterSpacing: -0.1,
                  color: isSelected ? activeColor : Colors.black,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Pill geometry ────────────────────────────────────────────────────────────
//
// Stretches the pill width during transition (0→0.5 expand, 0.5→1 contract)
// so it looks like the highlight flows between tabs.

class _PillRect {
  final double left, top, width, height;
  const _PillRect(this.left, this.top, this.width, this.height);
}

_PillRect _pillGeometry({
  required double t,
  required double fromCX,
  required double toCX,
  required double pillW,
  required double pillH,
  required double barW,
  required double barH,
}) {
  final tClamped = t.clamp(0.0, 1.0);
  final maxW = (toCX - fromCX).abs() + pillW;

  final double w;
  if (tClamped <= 0.5) {
    w = pillW + (maxW - pillW) * (tClamped * 2);
  } else {
    w = maxW + (pillW - maxW) * ((tClamped - 0.5) * 2);
  }

  final cx = fromCX + (toCX - fromCX) * t;
  final clampedW = w.clamp(pillW, maxW);
  final left = (cx - clampedW / 2).clamp(0.0, barW - clampedW);

  return _PillRect(left, (barH - pillH) / 2, clampedW, pillH);
}

// ── Glass bar (BackdropFilter + gradient pill) ───────────────────────────────
// On web: plain white container — BackdropFilter is extremely expensive in
// the CanvasKit renderer and causes janky scrolling.

class _GlassBar extends StatelessWidget {
  final double barW, barH, pillW, pillH, barRadius;
  final AnimationController ctrl;
  final int fromIdx, toIdx;
  final double Function(int, double) itemCenterX;
  final List<_NavItem> navItems;

  const _GlassBar({
    required this.barW,
    required this.barH,
    required this.pillW,
    required this.pillH,
    required this.barRadius,
    required this.ctrl,
    required this.fromIdx,
    required this.toIdx,
    required this.itemCenterX,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = context.colors.primary;

    // Web: skip blur, gradients, and shadows — all GPU-heavy on CanvasKit.
    if (kIsWeb) {
      return Container(
        width: barW,
        height: barH,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(barRadius),
          border: Border(top: BorderSide(color: Colors.black.withOpacity(0.08))),
        ),
        child: Row(
          children: navItems
              .map((item) => _NavItemWidget(
                    item: item,
                    selectedIndex: toIdx,
                    barH: barH,
                    activeColor: activeColor,
                    onTap: item.onTap,
                  ))
              .toList(),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(barRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 36,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(barRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            width: barW,
            height: barH,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.85),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.65),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(barRadius),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                AnimatedBuilder(
                  animation: ctrl,
                  builder: (_, __) {
                    final pill = _pillGeometry(
                      t: ctrl.value,
                      fromCX: itemCenterX(fromIdx, barW),
                      toCX: itemCenterX(toIdx, barW),
                      pillW: pillW,
                      pillH: pillH,
                      barW: barW,
                      barH: barH,
                    );
                    return Positioned(
                      left: pill.left,
                      top: pill.top,
                      child: _GradientPill(
                        width: pill.width,
                        height: pill.height,
                        accent: activeColor,
                      ),
                    );
                  },
                ),
                Row(
                  children: navItems
                      .map((item) => _NavItemWidget(
                            item: item,
                            selectedIndex: toIdx,
                            barH: barH,
                            activeColor: activeColor,
                            onTap: item.onTap,
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientPill extends StatelessWidget {
  final double width;
  final double height;
  final Color accent;

  const _GradientPill({
    required this.width,
    required this.height,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final r = height / 2;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.5, 1.0],
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.78),
            Colors.white.withOpacity(0.58),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.90),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.13),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.55),
            blurRadius: 4,
            spreadRadius: -1,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 1.5,
          width: width * 0.5,
          margin: EdgeInsets.only(top: height * 0.12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.90),
                Colors.white.withOpacity(0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

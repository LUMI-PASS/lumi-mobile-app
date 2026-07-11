import 'package:cupertino_native_glmv/cupertino_native_glmv.dart';
import 'package:dynamic_glass_glmv/dynamic_glass_glmv.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';

/// Glass bottom navigation with two renderers, both fed the **same Figma tab
/// SVGs** ([_tabs]):
///
///   • **iOS 26+ → the real thing.** A native `UITabBar` ([CNTabBar]) that the
///     system paints with genuine liquid glass — the actual UIKit material,
///     with its refraction and scroll-edge behaviour, not a Flutter imitation.
///     It is a controlled widget (`currentIndex` + `onTap`), so it drives
///     `AutoTabsScaffold`'s router exactly like the pill does.
///   • **Everything else → [GlassPillNavBar]**, the frosted Flutter pill.
///
/// We drive [CNTabBar] **directly** rather than going through
/// `dynamic_glass_glmv`'s [AdaptiveBottomNavigationBar], for one reason: that
/// wrapper hardcodes `preserveColors: true` on every asset icon, which tells
/// UIKit to blit the glyph as-is. Our tab SVGs are `fill="white"`, so they'd
/// come out white-on-glass and would never tint for selection. `CNTabBar`'s own
/// default is `preserveColors: false`, which templates the glyph — UIKit then
/// tints it with [CNTabBar.tint] when selected and system grey when not, which
/// is exactly the behaviour we want. `CNTabBar` already pre-renders SVG asset
/// paths to PNG, so it takes our `Assets.icons.home.*` paths as they are.
///
/// The blur only frosts because `MainPage`'s `AutoTabsScaffold` sets
/// `extendBody: true`, letting the tab content scroll behind the bar.
///
/// Pill surfaces / sizes / colours come straight from the Figma "Бар"
/// component:
///   • light 103:5934 — bar `rgba(255,255,255,0.6)`, pill `#E5E7EA`
///   • dark  103:4120 — bar `rgba(0,0,0,0.6)`,       pill `rgba(63,63,63,0.5)`
/// Tab bar radius 56, pill fully rounded, 2px bar padding, 16px icons, 10px
/// SF-Rounded labels, 4px icon→label gap. The **selected** icon is painted with
/// the brand pink→purple gradient ([AppGradients.brand]); the selected label
/// uses the primary text colour; everything unselected is the Figma grey
/// (`#A5A6BB` dark / `#343539` light).
class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.hidden = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool hidden;

  /// Figma `Primary/Charcoal Gray` — unselected icon/label in light mode.
  static const Color _charcoalGray = Color(0xFF343539);

  /// Figma `Primary/Grey` — unselected icon/label in dark mode.
  static const Color _figmaGrey = Color(0xFFA5A6BB);

  // Tab icon + localization key, per tab (Figma order:
  // Главный · Видео · Броны · Учреждения · Профиль).
  static final List<(SvgGenImage, String)> _tabs = [
    (Assets.icons.home.home, 'tab_home'),
    (Assets.icons.home.video, 'tab_shorts'),
    (Assets.icons.home.calendar, 'tab_bookings'),
    (Assets.icons.home.building, 'tab_explore'),
    (Assets.icons.home.profile, 'tab_profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Selected label = primary text (white in dark, #15141A in light).
    final selectedColor = c.textPrimary;
    // Unselected icon + label — Figma grey per theme.
    final unselectedColor = c.isDark ? _figmaGrey : _charcoalGray;

    final style = GlassPillNavBarStyle(
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      // Real glass: translucent bar so the 24px blur frosts the content behind
      // it. Figma: rgba(0,0,0,0.6) dark · rgba(255,255,255,0.6) light.
      backgroundColor: c.isDark
          ? Colors.black.withValues(alpha: 0.55)
          : Colors.white.withValues(alpha: 0.60),
      // Glass rim: a faint gradient ring (bright top → dim bottom) that gives
      // the pill a defined, floating edge. Without it the frosted white bar
      // vanishes against plain-white pages (Profile). The package paints the
      // ring OUTSIDE the blur and moves the drop shadow onto it, so the bar
      // reads as glass on any backdrop — not just the colourful Home feed.
      borderGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: c.isDark
            ? [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.04),
              ]
            : const [Colors.white, Color(0xFFE4E7EC)],
      ),
      borderWidth: 1,
      borderRadius: 56,
      blurSigma: 24,
      height: 50,
      horizontalPadding: 16,
      // The package's gap below the bar is `MediaQuery.padding.bottom +
      // bottomPadding`, which on a home-indicator iPhone floats the bar ~46pt
      // off the edge. We strip that inset below (`MediaQuery.removePadding`),
      // so this value *is* the full gap.
      bottomPadding: 20,
      // Pill fills its cell (bar has 2px padding → ~4px slack per slot).
      pillHeightFactor: 0.9,
      pillHorizontalInset: 4,
      // Flat pill — Figma `#E5E7EA` light · `rgba(63,63,63,0.5)` dark.
      pillColors: c.isDark
          ? const [Color(0x803F3F3F), Color(0x803F3F3F)]
          : const [Color(0xFFE5E7EA), Color(0xFFE5E7EA)],
      pillBorderColor: Colors.transparent,
      pillBorderWidth: 0,
      pillShineEnabled: false,
      pillShadows: const [],
      iconSize: 16,
      selectedIconSize: 16,
      labelGap: 4,
      // A real drop shadow so the pill visibly floats over any content
      // (this is what makes it read as glass on plain pages, like wisdom).
      // Light also keeps the Figma ambient glow (0 0 32 rgba(159,159,159,.25)).
      shadows: c.isDark
          ? const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
              BoxShadow(color: Color(0x409F9F9F), blurRadius: 32),
            ],
      animationDuration: const Duration(milliseconds: 200),
      animationCurve: Curves.easeOutCubic,
    );

    // The package takes an asset-path String (see its `icon` doc); our own
    // `iconBuilder` below renders it.
    final items = [
      for (final (icon, labelKey) in _tabs)
        AdaptiveNavigationDestination(
          icon: icon.path,
          label: labelKey.tr(),
        ),
    ];

    // iOS 26: the system liquid-glass UITabBar, carrying our own tab SVGs.
    // `preserveColors` is left at its default (false) so UIKit templates each
    // glyph and tints it — brand purple when selected, system grey when not.
    if (PlatformInfo.isIOS26OrHigher()) {
      if (hidden) return const SizedBox.shrink();
      return CNTabBar(
        items: [
          for (final (icon, labelKey) in _tabs)
            CNTabBarItem(
              label: labelKey.tr(),
              assetImage: icon.path,
              // Apple's tab-bar icon metric; without it the pre-rendered PNG
              // would draw at its own size.
              assetSize: 25,
            ),
        ],
        currentIndex: selectedIndex,
        onTap: onItemSelected,
        // UIKit tints flat, so the pill's pink→purple gradient collapses to
        // the brand purple here.
        tint: AppColors.brandPurple,
      );
    }

    Widget iconBuilder(
      BuildContext context,
      AdaptiveNavigationDestination item,
      bool selected,
      Color color,
      double size,
    ) =>
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: KeyedSubtree(
            key: ValueKey(selected),
            child: _NavIcon(
              asset: item.icon as String,
              size: size,
              selected: selected,
              unselectedColor: color,
            ),
          ),
        );

    Widget labelBuilder(
      BuildContext context,
      AdaptiveNavigationDestination item,
      bool selected,
      Color color,
    ) =>
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            height: 1.0,
            fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            color: color,
          ),
        );

    // Every other platform: the frosted Flutter pill.
    //
    // `GlassPillNavBar` pads itself by `MediaQuery.padding.bottom +
    // style.bottomPadding`. Dropping the inset makes `bottomPadding` the single
    // source of truth for how far the pill floats off the screen edge. The
    // native bar lays out its own safe area in UIKit, so this concerns the pill
    // alone.
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: IgnorePointer(
        ignoring: hidden,
        child: GlassPillNavBar(
          items: items,
          selectedIndex: selectedIndex,
          onTap: onItemSelected,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          style: style,
          iconBuilder: iconBuilder,
          labelBuilder: labelBuilder,
        ),
      ),
    );
  }
}

/// A tab icon: brand pink→purple gradient when [selected], flat
/// [unselectedColor] otherwise.
class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.asset,
    required this.size,
    required this.selected,
    required this.unselectedColor,
  });

  final String asset;
  final double size;
  final bool selected;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    if (!selected) {
      return SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: ColorFilter.mode(unselectedColor, BlendMode.srcIn),
      );
    }
    // Flatten the glyph to white, then stamp the brand gradient over it.
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => AppGradients.brand.createShader(bounds),
      child: SvgPicture.asset(
        asset,
        width: size,
        height: size,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      ),
    );
  }
}

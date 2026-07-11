import 'package:dynamic_glass_glmv/dynamic_glass_glmv.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';

/// Glass bottom navigation — the same `AdaptiveBottomNavigationBar` component
/// nexus-mobile-app uses (from `dynamic_glass_glmv`), wired the nexus way: a
/// [GlassPillNavBar] handed in via [AdaptiveBottomNavigationBar.fallbackNavBar]
/// and wrapped in an [IgnorePointer] so it can be hidden. Combined with
/// `useNativeBottomBar: false` this **forces the frosted Flutter glass pill on
/// every platform** — including iOS 26, where the native liquid-glass bar would
/// otherwise take over (it renders raw SVG fills as white and owns its own
/// selection, so it can't drive `AutoTabsScaffold`'s router).
///
/// The blur only frosts because `MainPage`'s `AutoTabsScaffold` sets
/// `extendBody: true`, letting the tab content scroll behind the bar.
///
/// Every surface / size / colour is taken straight from the Figma "Бар"
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

    final items = [
      for (final (icon, labelKey) in _tabs)
        AdaptiveNavigationDestination(
          // The package takes an asset-path String (see its `icon` doc).
          icon: icon.path,
          label: labelKey.tr(),
        ),
    ];

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

    // `GlassPillNavBar` pads itself by `MediaQuery.padding.bottom +
    // style.bottomPadding`. Dropping the inset here makes `bottomPadding` the
    // single source of truth for how far the bar floats off the screen edge.
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: AdaptiveBottomNavigationBar(
        items: items,
        selectedIndex: selectedIndex,
        onTap: onItemSelected,
        // Force the Flutter glass-pill bar on every platform (see class doc).
        useNativeBottomBar: false,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        hidden: hidden,
        // Nexus pattern: supply the glass bar explicitly as the fallback so it
        // is always the widget that renders.
        fallbackNavBar: IgnorePointer(
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
        glassPillStyle: style,
        glassPillIconBuilder: iconBuilder,
        glassPillLabelBuilder: labelBuilder,
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

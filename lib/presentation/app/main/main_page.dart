import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/data/service/deeplink_service.dart';
import 'package:lumi_pass/data/storage/storage.dart';
import 'package:lumi_pass/di/injection.dart';
import 'package:lumi_pass/presentation/app/main/widgets/coupon_promo_dialog.dart';
import 'package:lumi_pass/presentation/app/main/widgets/custom_bottomnavigation.dart';
import 'package:lumi_pass/presentation/app/main/widgets/onboarding_bottomsheet.dart';
import 'package:lumi_pass/presentation/app/main/widgets/packet_ad_screen.dart';
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
    // The tabs exist now, so a deep link finally has a home screen to land on
    // top of. Anything held during the cold start (see DeeplinkService) is
    // replayed here — this is the one chokepoint every route into the app
    // passes through, whether the user came via onboarding, login, or straight
    // in with a token.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<DeeplinkService>().markAppReady();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // The two launch popups, in one place and in order, because the screen
      // can only hold one: whichever fires leaves the other for another launch.
      // Stacking them would put an ad on top of a reward and lose both.
      //
      // The PACKET AD GOES FIRST, and the order matters on the launch that
      // matters most. A freshly registered user has `needsOnboarding` set, so
      // with the coupon popup first the ad lost every first launch — the one
      // launch a campaign with a deadline on it is actually aimed at. Deferring
      // the coupon popup instead costs nothing: it is evergreen, and returning
      // early here leaves `needsOnboarding` unconsumed, so it fires on the next
      // launch exactly as it always did.
      if (await _showPacketAdIfDue()) return;
      await _showCouponPromoIfDue();
    });
  }

  /// The one-time premium "get coupon" reward popup, for the users who came in
  /// registering. Returns whether it was shown.
  ///
  /// A new user is no longer stopped at the door for their name and child — the
  /// banner above the nav asks for those, whenever they feel like it. The
  /// `needsOnboarding` flag is still consumed here so this fires once.
  Future<bool> _showCouponPromoIfDue() async {
    if (_storage.needsOnboarding.call() != true) return false;
    _storage.needsOnboarding.set(false);
    if (_storage.couponPromoShown.call() == true) return false;

    _storage.couponPromoShown.set(true);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return false;
    showCouponPromoDialog(
      context,
      onGetCoupon: () => context.router.push(const PlansRoute()),
    );
    return true;
  }

  /// The full-screen packet ad, gated on Remote Config, `is_ad_seen`, and a
  /// packet actually being on sale — see [maybeShowPacketAd], which owns every
  /// one of those conditions and the settle delay. Returns whether it was shown.
  ///
  /// Here rather than on the home tab because it is an interstitial: it belongs
  /// to the launch, not to a screen, and MainPage is the one chokepoint every
  /// route into the app passes through.
  Future<bool> _showPacketAdIfDue() => maybeShowPacketAd(
        context,
        onBuy: () => context.router.push(AksiyaRoute()),
      );

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

    // Order — Home · Map · Video · Bookings · Profile. The map is second
    // because it is the other way to read the same catalog the home feed
    // lists, so it belongs next to it. `Muassasalar` (the centres tab,
    // `SearchPage`) is off the bar for now — the section is still a
    // coming-soon card, and the centres it would have shown are on the map.
    final routes = <PageRouteInfo>[
      const HomeRoute(),
      const MapRoute(),
      const ShortsRoute(),
      const CalendarRoute(),
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

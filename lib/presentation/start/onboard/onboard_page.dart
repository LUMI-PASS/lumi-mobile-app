import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/utils/app_locale.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_cubit.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_state.dart';

/// First-run carousel: four slides on the purple brand stage, with the
/// language picked inline on the first slide (there is no separate language
/// step any more). Always purple — it does not follow light/dark mode.
@RoutePage()
class OnboardingPage extends BasePage<OnboardingCubit, OnboardingBuildable,
    OnboardingListenable> {
  OnboardingPage({super.key});

  final PageController _pageController = PageController();

  static const _duration = Duration(milliseconds: 400);
  static const _curve = Curves.easeOutCubic;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void listener(BuildContext context, OnboardingListenable state) {
    switch (state.effect) {
      case OnboardEffect.home:
        context.router.replaceAll([const MainRoute()]);
        break;
      case OnboardEffect.login:
        context.router.replaceAll([LoginRoute()]);
        break;
    }
  }

  @override
  Widget builder(BuildContext context, OnboardingBuildable state) {
    final cubit = context.read<OnboardingCubit>();
    // Rebuild the whole page when the language changes.
    final locale = context.locale;
    const count = OnboardingCubit.pageCount;
    final isLast = state.index == count - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.onboardPurple,
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppGradients.onboarding),
          child: DecoratedBox(
            decoration:
                const BoxDecoration(gradient: AppGradients.onboardingGlow),
            child: SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    controller: _pageController,
                    onSkip: cubit.finish,
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: cubit.changeIndex,
                      // Not const: `.tr()` registers no dependency, so const
                      // slides would keep the old language after a switch.
                      children: [
                        _PassSlide(key: ValueKey('pass-$locale')),
                        _BenefitsSlide(key: ValueKey('benefits-$locale')),
                        _ActivitiesSlide(key: ValueKey('activities-$locale')),
                        _StartSlide(key: ValueKey('start-$locale')),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _Dots(count: count, index: state.index),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
                    child: _YellowButton(
                      text: isLast ? 'onb4_start'.tr() : 'onboarding_next'.tr(),
                      onPressed: () {
                        if (isLast) {
                          cubit.finish();
                        } else {
                          _pageController.nextPage(
                            duration: _duration,
                            curve: _curve,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Chrome ──────────────────────────────────────────────────────────────────

/// Logo on the left; language picker and "Skip" on the right. There is no
/// back button — the carousel is swiped. Both right-hand controls fade with
/// the swipe itself (driven by the page position, not by the settled index),
/// so they never pop in or out.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller, required this.onSkip});

  final PageController controller;
  final VoidCallback onSkip;

  static const _lastPage = OnboardingCubit.pageCount - 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      child: Padding(
        padding: EdgeInsets.only(left: 20.w, right: 16.w),
        child: Row(
          children: [
            Assets.icons.logoWhite.image(height: 26.h, fit: BoxFit.contain),
            const Spacer(),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final page = controller.hasClients &&
                        controller.position.hasContentDimensions
                    ? controller.page ?? 0
                    : controller.initialPage.toDouble();
                final languages = (1 - page).clamp(0.0, 1.0);
                // Hidden on slide 1 (where the language picker sits, and its label
                // would jump on every language switch); fades in toward slide
                // 2 and back out toward the last slide.
                final skip = math.min(page, _lastPage - page).clamp(0.0, 1.0);
                // One right-hand slot: the picker and "Skip" overlap and
                // cross-fade, so neither leaves a gap beside the other.
                return Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    _fading(
                      languages,
                      const _LanguageToggle(),
                    ),
                    _fading(
                      skip,
                      TextButton(
                        onPressed: onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                        ),
                        child: Text(
                          'skip'.tr(),
                          style: AppText.semibold16
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Fades and nudges [child] up as [t] goes 1 → 0; untappable once mostly
  /// gone.
  Widget _fading(double t, Widget child) {
    return IgnorePointer(
      ignoring: t < 0.5,
      child: Opacity(
        opacity: Curves.easeOut.transform(t),
        child: Transform.translate(
          offset: Offset(0, -8 * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

/// UZ / RU / EN segmented pill — replaces the old full-screen language step.
///
/// The white thumb slides between fixed-width segments, and the locale is
/// applied only once the slide has finished: `setLocale` rebuilds the whole
/// app, and doing that mid-animation is what made the thumb stutter.
class _LanguageToggle extends StatefulWidget {
  const _LanguageToggle();

  @override
  State<_LanguageToggle> createState() => _LanguageToggleState();
}

class _LanguageToggleState extends State<_LanguageToggle> {
  static const _locales = [
    Locale('uz', 'UZ'),
    Locale('ru', 'RU'),
    Locale('en', 'EN'),
  ];
  static const _slide = Duration(milliseconds: 260);

  /// Spoken by VoiceOver/TalkBack — each language in its own name, since the
  /// reader may not understand the currently selected one.
  static const _names = ['Oʻzbekcha', 'Русский', 'English'];

  int? _selected;

  int _indexOf(String code) {
    final i = _locales.indexWhere((l) => l.languageCode == code);
    return i < 0 ? 0 : i;
  }

  void _select(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
    final locale = _locales[index];
    Future.delayed(_slide, () {
      if (!mounted || _selected != index) return;
      setCurrentLang(locale.languageCode);
      context.setLocale(locale);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected ??= _indexOf(context.locale.languageCode);
    final segment = 44.w;
    final height = 32.h;
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: SizedBox(
        width: segment * _locales.length,
        height: height,
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: _slide,
              curve: Curves.easeOutCubic,
              left: segment * selected,
              top: 0,
              width: segment,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
            Row(
              children: [
                for (var i = 0; i < _locales.length; i++)
                  Semantics(
                    button: true,
                    selected: i == selected,
                    label: _names[i],
                    excludeSemantics: true,
                    onTap: () => _select(i),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _select(i),
                      child: SizedBox(
                        width: segment,
                        height: height,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: _slide,
                            curve: Curves.easeOutCubic,
                            style: AppText.semibold14.copyWith(
                              color: i == selected
                                  ? AppColors.onboardNavy
                                  : AppColors.white.withValues(alpha: 0.8),
                            ),
                            child: Text(
                              _locales[i].languageCode.toUpperCase(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(horizontal: 3.w),
            width: (i == index ? 22 : 8).w,
            height: 8.r,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: i == index ? 1 : 0.45),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
      ],
    );
  }
}

class _YellowButton extends StatelessWidget {
  const _YellowButton({required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54.h,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.onboardYellow,
          foregroundColor: AppColors.onboardNavy,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        child: Text(
          text,
          style: AppText.medium16.copyWith(color: AppColors.onboardNavy),
        ),
      ),
    );
  }
}

// ── Shared slide parts ──────────────────────────────────────────────────────

/// White all-caps headline over a yellow accent line.
class _Headline extends StatelessWidget {
  const _Headline({
    required this.title,
    required this.accent,
    this.body,
  });

  final String title;
  final String accent;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.title24.copyWith(color: AppColors.white),
          ),
          SizedBox(height: 2.h),
          Text(
            accent,
            textAlign: TextAlign.center,
            style: AppText.heading20.copyWith(color: AppColors.onboardYellow),
          ),
          if (body != null) ...[
            SizedBox(height: 12.h),
            Text(
              body!,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppText.regular14.copyWith(
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A hero drawn on a fixed design canvas and scaled down to whatever room the
/// slide leaves, so small phones never overflow.
class _Hero extends StatelessWidget {
  const _Hero({required this.width, required this.height, required this.child});

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(width: width, height: height, child: child),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.image,
    required this.tint,
    this.size = 36,
  });

  final AssetGenImage image;
  final Color tint;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: image.image(fit: BoxFit.contain, excludeFromSemantics: true),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard(
      {required this.rows, this.topPadding = 0, this.badgeSize = 36});

  final List<(AssetGenImage, Color, String)> rows;
  final double topPadding;
  final double badgeSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, topPadding + 6, 16, 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.onboardIndigo.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, color: AppColors.onboardDivider),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _IconBadge(
                    image: rows[i].$1,
                    tint: rows[i].$2,
                    size: badgeSize,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      rows[i].$3,
                      maxLines: 2,
                      style: AppText.semibold16.copyWith(
                        color: AppColors.onboardNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Slide 1 — one pass, hundreds of activities ──────────────────────────────

class _PassSlide extends StatelessWidget {
  const _PassSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _Hero(
            width: 375,
            height: 340,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 78,
                  top: 6,
                  width: 214,
                  height: 315,
                  child: Assets.images.mascot.mascotWave
                      .image(fit: BoxFit.contain, excludeFromSemantics: true),
                ),
                _chip('onb_chip_sport', left: 18, top: 48, angle: -4),
                _chip('onb_chip_arts',
                    right: 22, top: 30, angle: 3, bg: AppColors.onboardYellow),
                _chip('onb_chip_workshops',
                    left: 22,
                    top: 210,
                    angle: 4,
                    bg: AppColors.onboardPink,
                    fg: AppColors.white),
                _chip('onb_chip_science', right: 22, top: 194, angle: -4),
                _chip('onb_chip_playgrounds',
                    left: 30, top: 292, angle: -3, bg: AppColors.onboardSky),
                _chip('onb_chip_more',
                    right: 24,
                    top: 290,
                    angle: 4,
                    bg: AppColors.onboardNavy,
                    fg: AppColors.onboardYellow),
              ],
            ),
          ),
        ),
        _Headline(
          title: 'onb1_title'.tr(),
          accent: 'onb1_accent'.tr(),
          body: 'onb1_body'.tr(),
        ),
      ],
    );
  }

  Widget _chip(
    String key, {
    double? left,
    double? right,
    required double top,
    required double angle,
    Color bg = AppColors.white,
    Color fg = AppColors.onboardNavy,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      child: Transform.rotate(
        angle: angle * math.pi / 180,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.onboardIndigo.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            key.tr(),
            style: AppText.semibold14.copyWith(color: fg),
          ),
        ),
      ),
    );
  }
}

// ── Slide 2 — useful and easy ──────────────────────────────────────────────

class _BenefitsSlide extends StatelessWidget {
  const _BenefitsSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _Hero(
            width: 345,
            height: 392,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _ListCard(
                    topPadding: 64,
                    rows: [
                      (
                        Assets.images.onboarding.iconNoCash,
                        AppColors.onboardPinkTint,
                        'onb2_benefit1'.tr(),
                      ),
                      (
                        Assets.images.onboarding.iconFast,
                        AppColors.onboardYellowTint,
                        'onb2_benefit2'.tr(),
                      ),
                      (
                        Assets.images.onboarding.iconPhone,
                        AppColors.onboardBlueTint,
                        'onb2_benefit3'.tr(),
                      ),
                      (
                        Assets.images.onboarding.iconFamily,
                        AppColors.onboardLilacTint,
                        'onb2_benefit4'.tr(),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  left: 36,
                  top: 0,
                  child: _PassCard(),
                ),
              ],
            ),
          ),
        ),
        _Headline(
          title: 'onb2_title'.tr(),
          accent: 'onb2_accent'.tr(),
          body: 'onb2_body'.tr(),
        ),
      ],
    );
  }
}

/// The tilted yellow "ABONEMENT · Hammasi ichida" card.
class _PassCard extends StatelessWidget {
  const _PassCard();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -6 * math.pi / 180,
      child: Container(
        width: 262,
        height: 160,
        padding: const EdgeInsets.fromLTRB(22, 20, 18, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.onboardYellow, AppColors.warning],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.onboardIndigo.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Assets.icons.logoWordmark.image(height: 40),
                const Spacer(),
                const Icon(Icons.auto_awesome,
                    color: AppColors.white, size: 26),
              ],
            ),
            const Spacer(),
            Text(
              'onb2_card_label'.tr(),
              style: AppText.semibold12.copyWith(
                color: AppColors.onboardNavy.withValues(alpha: 0.7),
                letterSpacing: 1.5,
              ),
            ),
            Text(
              'onb2_card_title'.tr(),
              maxLines: 1,
              style: AppText.heading20.copyWith(color: AppColors.onboardNavy),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slide 3 — let them try it all ──────────────────────────────────────────

class _ActivitiesSlide extends StatelessWidget {
  const _ActivitiesSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _Hero(
            width: 340,
            height: 330,
            child: Stack(
              children: [
                _tile(0, 0, -4, Assets.images.onboarding.iconSwimming,
                    'onb3_swimming', AppColors.white, AppColors.onboardNavy),
                _tile(
                    1,
                    26,
                    4,
                    Assets.images.onboarding.iconDance,
                    'onb3_dance',
                    AppColors.onboardYellow,
                    AppColors.onboardNavy),
                _tile(2, 0, -3, Assets.images.onboarding.iconChess,
                    'onb3_chess', AppColors.onboardPink, AppColors.white),
                _tile(
                    0,
                    168,
                    4,
                    Assets.images.onboarding.iconDrawing,
                    'onb3_drawing',
                    AppColors.onboardSky,
                    AppColors.onboardNavy),
                _tile(1, 194, -3, Assets.images.onboarding.iconFootball,
                    'onb3_football', AppColors.white, AppColors.onboardNavy),
                _tile(2, 168, 5, Assets.images.onboarding.iconMore, 'onb3_more',
                    AppColors.onboardNavy, AppColors.white),
              ],
            ),
          ),
        ),
        _Headline(
          title: 'onb3_title'.tr(),
          accent: 'onb3_accent'.tr(),
          body: 'onb3_body'.tr(),
        ),
      ],
    );
  }

  Widget _tile(
    int column,
    double top,
    double angle,
    AssetGenImage icon,
    String key,
    Color bg,
    Color fg,
  ) {
    const w = 96.0;
    const h = 130.0;
    return Positioned(
      left: 10 + column * (w + 14),
      top: top,
      width: w,
      height: h,
      child: Transform.rotate(
        angle: angle * math.pi / 180,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.onboardIndigo.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon.image(
                width: 52,
                height: 52,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
              const Spacer(),
              Text(
                key.tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.semibold14.copyWith(color: fg, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Slide 4 — let's go ─────────────────────────────────────────────────────

class _StartSlide extends StatelessWidget {
  const _StartSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: _Hero(
            width: 200,
            height: 290,
            child: Assets.images.mascot.mascotSearch
                .image(fit: BoxFit.contain, excludeFromSemantics: true),
          ),
        ),
        _Headline(
          title: 'onb4_title'.tr(),
          accent: 'onb4_accent'.tr(),
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: _ListCard(
            badgeSize: 40,
            rows: [
              (
                Assets.images.onboarding.iconLocation,
                AppColors.onboardPinkTint,
                'onb4_point1'.tr(),
              ),
              (
                Assets.images.onboarding.iconAge,
                AppColors.onboardYellowTint,
                'onb4_point2'.tr(),
              ),
              (
                Assets.images.onboarding.iconHeart,
                AppColors.onboardBlueTint,
                'onb4_point3'.tr(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

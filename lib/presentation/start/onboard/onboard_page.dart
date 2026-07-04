import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/base/base_page.dart';
import 'package:lumi_pass/common/extensions/sizedbox_extensions.dart';
import 'package:lumi_pass/common/extensions/theme_extensions.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_cubit.dart';
import 'package:lumi_pass/presentation/start/onboard/cubit/onboarding_state.dart';

@RoutePage()
class OnboardingPage
    extends BasePage<OnboardingCubit, OnboardingBuildable, OnboardingListenable> {
  OnboardingPage({super.key});

  final PageController _pageController = PageController();

  static const _imageAssets = [
    'assets/images/onboard1.png',
    'assets/images/onboard2.png',
    'assets/images/onboard3.png',
  ];

  // Gradient pairs for each page background
  static const _bgGradients = [
    [Color(0xFFF5F3FF), Color(0xFFEDE9FE)], // violet soft
    [Color(0xFFFDF2F8), Color(0xFFFCE7F3)], // pink soft
    [Color(0xFFEFF6FF), Color(0xFFDBEAFE)], // blue soft
  ];

  static const _accentColors = [
    Color(0xFFA652C7), // purple
    Color(0xFFEC4899), // pink
    Color(0xFF3B82F6), // blue
  ];

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
    final primary = context.colors.primary;
    final pages = Onboard.values;
    final currentAccent = _accentColors[state.index.clamp(0, 2)];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _bgGradients[state.index.clamp(0, 2)][0],
              _bgGradients[state.index.clamp(0, 2)][1],
              Colors.white,
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            _AnimatedCircle(
              top: -40.h, right: -40.w, size: 180.w,
              color: currentAccent.withOpacity(0.08),
              delay: 0,
            ),
            _AnimatedCircle(
              bottom: 200.h, left: -50.w, size: 120.w,
              color: currentAccent.withOpacity(0.06),
              delay: 500,
            ),
            _AnimatedCircle(
              top: 300.h, right: -30.w, size: 80.w,
              color: const Color(0xFFFF7093).withOpacity(0.08),
              delay: 1000,
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top bar with skip
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo/brand
                        Row(
                          children: [
                            Container(
                              width: 32.w, height: 32.w,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(Icons.auto_awesome_rounded,
                                  size: 18.w, color: primary),
                            ),
                            8.kw,
                            Text('LumiPass',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                                color: primary,
                              ),
                            ),
                          ],
                        ),
                        // Skip
                        GestureDetector(
                          onTap: () => context.read<OnboardingCubit>().skipAll(),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            child: Text(
                              'skip'.tr(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Page content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) =>
                          context.read<OnboardingCubit>().changeIndex(i),
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return _OnboardContent(
                          imagePath: _imageAssets[index],
                          title: pages[index].title,
                          subtitle: pages[index].description,
                          accent: _accentColors[index],
                          index: index,
                        );
                      },
                    ),
                  ),

                  // Bottom controls
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
                    child: Column(
                      children: [
                        // Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(pages.length, (i) {
                            final isActive = state.index == i;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeOutCubic,
                              margin: EdgeInsets.symmetric(horizontal: 4.w),
                              width: isActive ? 32.w : 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                gradient: isActive
                                    ? LinearGradient(colors: [
                                        currentAccent,
                                        currentAccent.withOpacity(0.6),
                                      ])
                                    : null,
                                color: isActive ? null : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          }),
                        ),
                        28.kh,
                        // Button
                        GestureDetector(
                          onTap: () {
                            if (state.index < pages.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutCubic,
                              );
                            } else {
                              context
                                  .read<OnboardingCubit>()
                                  .changeIndex(pages.length);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  currentAccent,
                                  currentAccent.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(18.r),
                              boxShadow: [
                                BoxShadow(
                                  color: currentAccent.withOpacity(0.35),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.index == pages.length - 1
                                      ? 'get_started'.tr()
                                      : 'next'.tr(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                if (state.index < pages.length - 1) ...[
                                  8.kw,
                                  Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 20.w),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Page content ───

class _OnboardContent extends StatelessWidget {
  const _OnboardContent({
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.index,
  });

  final String imagePath;
  final String title;
  final String subtitle;
  final Color accent;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          16.kh,
          // Image area
          Expanded(
            flex: 7,
            child: TweenAnimationBuilder<double>(
              key: ValueKey('img-$index'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.translate(
                offset: Offset(0, 20 * (1 - v.clamp(0.0, 1.0))),
                child: Transform.scale(
                  scale: 0.85 + (0.15 * v),
                  child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28.r),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Text area
          Expanded(
            flex: 2,
            child: TweenAnimationBuilder<double>(
              key: ValueKey('txt-$index'),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, v, child) => Transform.translate(
                offset: Offset(0, 30 * (1 - v)),
                child: Opacity(opacity: v, child: child),
              ),
              child: Column(
                children: [
                  8.kh,
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1E293B),
                      height: 1.25,
                    ),
                  ),
                  12.kh,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade500,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Animated decorative circle ───

class _AnimatedCircle extends StatefulWidget {
  const _AnimatedCircle({
    this.top, this.bottom, this.left, this.right,
    required this.size, required this.color, this.delay = 0,
  });
  final double? top, bottom, left, right;
  final double size;
  final Color color;
  final int delay;

  @override
  State<_AnimatedCircle> createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<_AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top, bottom: widget.bottom,
      left: widget.left, right: widget.right,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) {
          final s = 1.0 + (_ctrl.value * 0.1);
          return Transform.scale(scale: s, child: child);
        },
        child: Container(
          width: widget.size, height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

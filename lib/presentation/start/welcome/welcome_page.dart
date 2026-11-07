import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/auth/auth_scaffold.dart';

/// Splash / welcome screen — waving mascot centred, the "Lumi" wordmark at the
/// foot of the screen, on a brightness-aware background; auto-advances into the
/// onboarding carousel.
@RoutePage()
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) context.router.replace(OnboardingRoute());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutBack,
                builder: (_, value, child) => Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.85 + (0.15 * value),
                    child: child,
                  ),
                ),
                child: Assets.images.mascot.mascotHelloClean.image(
                  width: 210.w,
                  height: 290.w,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          // The wordmark sits at the foot of the screen, fading in after
          // the mascot has landed.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 700),
            curve: const Interval(0.4, 1, curve: Curves.easeOut),
            builder: (_, value, child) => Opacity(opacity: value, child: child),
            child: Padding(
              padding: EdgeInsets.only(bottom: 32.h),
              child: Assets.icons.logoWordmark.image(height: 40.h),
            ),
          ),
        ],
      ),
    );
  }
}

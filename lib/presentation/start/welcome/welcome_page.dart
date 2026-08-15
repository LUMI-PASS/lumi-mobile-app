import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/router/app_router.dart';
import 'package:lumi_pass/common/widget/auth/auth_scaffold.dart';
import 'package:lumi_pass/common/widget/auth/auth_misc.dart';

/// Splash / welcome screen — waving mascot over the "Lumi" mark on a
/// brightness-aware background, then auto-advances into the language step.
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
      if (mounted) context.router.replace(const LanguageRoute());
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutBack,
          builder: (_, value, child) => Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.85 + (0.15 * value), child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.images.mascot.mascotHello.image(
                width: 180.w,
                height: 180.w,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
              SizedBox(height: 16.h),
              const LumiWordmark(height: 56),
            ],
          ),
        ),
      ),
    );
  }
}

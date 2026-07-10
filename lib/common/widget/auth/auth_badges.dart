import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/auth_assets.dart';

/// Big gradient circle holding a white glyph — the globe on the language
/// screen. Figma: 64×64, pink→purple, 16px padding, 32px icon.
class GradientIconBadge extends StatelessWidget {
  const GradientIconBadge({super.key, required this.asset, this.size = 64});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.r,
      height: size.r,
      padding: EdgeInsets.all((size / 4).r),
      decoration: const BoxDecoration(
        gradient: AppGradients.brand,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          // Soft inner top highlight.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 0.9,
                  colors: [
                    Colors.white.withValues(alpha: 0.35),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SvgPicture.asset(
              asset,
              colorFilter: const ColorFilter.mode(
                AppColors.onBrand,
                BlendMode.srcIn,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single square in [AuthIconBadgeRow].
class AuthBadgeSpec {
  const AuthBadgeSpec(this.color, this.asset);
  final Color color;
  final String asset;
}

/// The row of three overlapping colored icon squares that tops the
/// authorization / confirmation screens. Figma: 22×22, r6, 15px step.
class AuthIconBadgeRow extends StatelessWidget {
  const AuthIconBadgeRow({super.key, this.specs = _authSpecs});

  static const List<AuthBadgeSpec> _authSpecs = [
    AuthBadgeSpec(AppColors.badgeBlue, AuthAssets.userAi),
    AuthBadgeSpec(AppColors.badgeGreen, AuthAssets.loginCircle),
    AuthBadgeSpec(AppColors.badgePink, AuthAssets.login02),
  ];

  /// Onboarding uses a playful trio.
  static const List<AuthBadgeSpec> onboardSpecs = [
    AuthBadgeSpec(AppColors.badgeBlue, AuthAssets.rockingHorse),
    AuthBadgeSpec(AppColors.badgeGreen, AuthAssets.rocket),
    AuthBadgeSpec(AppColors.badgePink, AuthAssets.maskTheater),
  ];

  final List<AuthBadgeSpec> specs;

  @override
  Widget build(BuildContext context) {
    final border = context.appColors.badgeBorder;
    const step = 15.0;
    return SizedBox(
      width: (step * (specs.length - 1) + 22).w,
      height: 22.r,
      child: Stack(
        children: [
          for (var i = 0; i < specs.length; i++)
            Positioned(
              left: (step * i).w,
              child: _Badge(spec: specs[i], border: border),
            ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.spec, required this.border});

  final AuthBadgeSpec spec;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.r,
      height: 22.r,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: spec.color,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: SvgPicture.asset(
        spec.asset,
        colorFilter:
            const ColorFilter.mode(AppColors.onBrand, BlendMode.srcIn),
      ),
    );
  }
}

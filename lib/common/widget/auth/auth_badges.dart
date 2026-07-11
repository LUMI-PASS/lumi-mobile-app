import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';

/// Big gradient circle holding a white glyph — the globe on the language
/// screen. Figma: 64×64, pink→purple, 16px padding, 32px icon.
class GradientIconBadge extends StatelessWidget {
  const GradientIconBadge({super.key, required this.asset, this.size = 64});

  final SvgGenImage asset;
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
            child: asset.svg(
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
  final SvgGenImage asset;
}

/// The row of three overlapping colored icon squares that tops the
/// authorization / confirmation screens. Figma: 22×22, r6, 15px step.
class AuthIconBadgeRow extends StatelessWidget {
  /// [specs] defaults to [_authSpecs]. It can't be a default parameter value
  /// because the generated asset getters aren't const expressions.
  const AuthIconBadgeRow({super.key, this.specs});

  static final List<AuthBadgeSpec> _authSpecs = [
    AuthBadgeSpec(AppColors.badgeBlue, Assets.icons.auth.userAi),
    AuthBadgeSpec(AppColors.badgeGreen, Assets.icons.auth.loginCircle),
    AuthBadgeSpec(AppColors.badgePink, Assets.icons.auth.login02),
  ];

  /// Onboarding uses a playful trio.
  static final List<AuthBadgeSpec> onboardSpecs = [
    AuthBadgeSpec(AppColors.badgeBlue, Assets.icons.auth.rockingHorse),
    AuthBadgeSpec(AppColors.badgeGreen, Assets.icons.auth.rocket01),
    AuthBadgeSpec(AppColors.badgePink, Assets.icons.auth.maskTheater),
  ];

  final List<AuthBadgeSpec>? specs;

  @override
  Widget build(BuildContext context) {
    final border = context.appColors.badgeBorder;
    final specs = this.specs ?? _authSpecs;
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
      child: spec.asset.svg(
        colorFilter:
            const ColorFilter.mode(AppColors.onBrand, BlendMode.srcIn),
      ),
    );
  }
}

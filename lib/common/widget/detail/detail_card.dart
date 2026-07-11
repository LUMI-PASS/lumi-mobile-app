import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_shadows.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/widget/frosted_card.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/home/widgets/home_icons.dart';

/// Building blocks of the "Детали" detail screens (class detail, branch
/// detail): a hero image with floating frosted controls, then a stack of white
/// cards separated by a 6px canvas gap.
///
/// Shared so the two detail screens stay visually identical — don't re-declare
/// the card decoration or the gradient icon badge inline.

/// Subtle "frosted" pill fill for chips nested on a control/surface row. Figma
/// uses translucent white in dark mode; on light backgrounds that vanishes, so
/// we fall back to solid white which still reads as a raised pill.
Color detailChipFill(AppColorScheme c) =>
    c.isDark ? Colors.white.withOpacity(0.10) : Colors.white;

/// Full-bleed white card — the section container every detail screen is built
/// from.
class DetailCard extends StatelessWidget {
  const DetailCard({super.key, required this.c, required this.child});
  final AppColorScheme c;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

/// Card section header — gradient icon badge + title.
class DetailCardHeader extends StatelessWidget {
  const DetailCardHeader({
    super.key,
    required this.c,
    required this.icon,
    required this.iconGradient,
    required this.title,
  });
  final AppColorScheme c;
  final SvgGenImage icon;
  final Gradient iconGradient;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            gradient: iconGradient,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: HomeIcon(icon, size: 14, color: Colors.white),
        ),
        6.horizontalSpace,
        Text(title, style: AppText.semibold16.copyWith(color: c.textPrimary)),
      ],
    );
  }
}

/// Frosted chip floating over the hero — back / share / heart.
class DetailControlButton extends StatelessWidget {
  const DetailControlButton({
    super.key,
    required this.child,
    required this.onTap,
  });
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FrostedCard(
      onTap: onTap,
      boxShadow: AppShadows.control,
      child: child,
    );
  }
}

/// Soft haze pinned to the top of the screen: the content scrolling underneath
/// is progressively blurred and washed into [color], so the floating controls
/// stay legible without a hard header bar.
class DetailTopScrim extends StatelessWidget {
  const DetailTopScrim({
    super.key,
    required this.color,
    required this.height,
  });

  final Color color;
  final double height;

  /// Stacked blur passes. Each covers a shorter slice of the top, so the passes
  /// accumulate towards the status bar and taper to nothing at the bottom edge
  /// — a progressive blur rather than a hard-cut blurred rectangle.
  static const int _passes = 6;
  static const double _sigma = 1.6;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < _passes; i++)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * (_passes - i) / _passes,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withOpacity(0.92),
                  color.withOpacity(0.60),
                  color.withOpacity(0),
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

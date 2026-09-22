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
///
/// **This widget is rebuilt on every scroll frame**, so it is built to be cheap
/// and it fades ITSELF via [t] — never wrap it in an [Opacity].
///
/// Two things were making these screens stutter while scrolling, both of them
/// here:
///
///   • it used to stack SIX overlapping [BackdropFilter]s to fake a
///     progressive blur. Each one is a `saveLayer` plus a read-back of what is
///     behind it, and they overlap — so the top strip of the screen was being
///     blurred six times per frame, on top of the frosted hero controls that
///     sit in the same strip;
///   • the caller faded it with an [Opacity] driven by the scroll offset.
///     Opacity forces the whole subtree into an offscreen layer every frame,
///     and a `BackdropFilter` inside one samples THAT layer rather than the
///     screen — so the passes were also paying for a blur that could not read
///     the content it was meant to be hazing.
///
/// Now: one blur pass over the whole strip, a second over the top half so the
/// haze still accumulates towards the status bar, and the fade folded into the
/// blur sigma and the gradient's own alpha — no offscreen layer at all. Fully
/// faded out, it draws nothing.
class DetailTopScrim extends StatelessWidget {
  const DetailTopScrim({
    super.key,
    required this.color,
    required this.height,
    this.t = 1,
  });

  final Color color;
  final double height;

  /// How far the scrim has faded in, 0…1. Drive it straight from the scroll
  /// progress; it scales both the blur and the wash.
  final double t;

  /// Blur strength at full fade-in. Applied twice over the top half, which is
  /// what gives the haze its taper.
  static const double _sigma = 2.2;

  /// Below this the scrim is invisible anyway, and skipping the whole subtree
  /// keeps an un-scrolled hero completely free of blur work.
  static const double _floor = 0.01;

  @override
  Widget build(BuildContext context) {
    final progress = t.clamp(0.0, 1.0);
    if (progress <= _floor) {
      return SizedBox(height: height, width: double.infinity);
    }

    final sigma = _sigma * progress;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
              child: const SizedBox.expand(),
            ),
          ),
          // The second pass only covers the top half, so the haze thickens
          // towards the status bar and tapers out at the bottom edge.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: height / 2,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
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
                  color.withValues(alpha: 0.92 * progress),
                  color.withValues(alpha: 0.60 * progress),
                  color.withValues(alpha: 0),
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

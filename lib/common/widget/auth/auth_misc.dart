import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/common/styles/auth_assets.dart';

/// Clock glyph + `mm:ss` countdown. Figma: 14px icon, muted 12px text.
class CountdownTimer extends StatelessWidget {
  const CountdownTimer({super.key, required this.seconds});

  final int seconds;

  String get _formatted {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final muted = context.appColors.textMuted;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AuthAssets.time,
          width: 14.r,
          height: 14.r,
          colorFilter: ColorFilter.mode(muted, BlendMode.srcIn),
        ),
        SizedBox(width: 4.w),
        Text(_formatted, style: AppText.regular12.copyWith(color: muted)),
      ],
    );
  }
}

/// Onboarding page indicator wrapped in the Figma rounded surface pill.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(32.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              margin: EdgeInsets.only(right: i == count - 1 ? 0 : 6.w),
              width: (i == index ? 20 : 8).w,
              height: 8.r,
              decoration: BoxDecoration(
                color: i == index
                    ? AppColors.brandPurple
                    : colors.textMuted.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
        ],
      ),
    );
  }
}

/// The "Lumi" brand wordmark (reuses the existing app logo asset).
class LumiWordmark extends StatelessWidget {
  const LumiWordmark({super.key, this.height = 24});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(AuthAssets.logo, height: height.h, fit: BoxFit.contain);
  }
}

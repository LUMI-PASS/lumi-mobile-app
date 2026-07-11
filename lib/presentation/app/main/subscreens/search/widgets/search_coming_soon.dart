import 'dart:ui';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';

/// "Coming soon" placeholder for the Учреждения / Explore feature.
///
/// Renders a faint, frosted-blurred preview of the search layout with a
/// centered card, so the screen reads as an intentional upcoming feature
/// rather than an empty state. Used both by the bottom-nav tab and by the
/// full-screen route pushed from Home.
class SearchComingSoonView extends StatelessWidget {
  const SearchComingSoonView({super.key, this.onBack});

  /// Back affordance — set it when the screen was *pushed* onto a route (from
  /// Home or the categories grid) so the user can get back where they came
  /// from. Left null on the Explore bottom-nav tab, which is a root
  /// destination: there is no previous screen, so it shows no back button.
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final topInset = MediaQuery.of(context).viewPadding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: c.overlayStyle,
      child: Scaffold(
        backgroundColor: c.scaffoldBg,
        body: Column(
          children: [
            SizedBox(height: topInset + 8.h),
            SearchTopBar(title: 'tab_explore'.tr(), onBack: onBack),
            16.verticalSpace,
            Expanded(
              // The ClipRect is load-bearing: a BackdropFilter frosts its whole
              // layer, not just its own bounds, so without it the blur climbs
              // over the top bar and smears the back button and title away.
              child: ClipRect(
                child: Stack(
                  children: [
                    // Faint preview of the eventual search layout.
                    Positioned.fill(child: _PreviewSkeleton()),
                    // Frost the preview so it reads as "not ready yet".
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(color: c.scaffoldBg.withOpacity(0.6)),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.w),
                        child: const _ComingSoonCard(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Static, non-interactive mock of the search screen shown behind the blur.
class _PreviewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final itemW = (1.sw - 32.w - 8.w) / 2;

    Widget bar(double w, double h) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(8.r),
          ),
        );

    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search field + filter
            Row(
              children: [
                Expanded(child: bar(double.infinity, 40.h)),
                8.horizontalSpace,
                bar(40.h, 40.h),
              ],
            ),
            16.verticalSpace,
            // Category chips
            Row(
              children: [
                bar(90.w, 32.h),
                8.horizontalSpace,
                bar(110.w, 32.h),
              ],
            ),
            20.verticalSpace,
            // Result cards grid
            Expanded(
              child: Wrap(
                spacing: 8.w,
                runSpacing: 20.h,
                children: List.generate(6, (_) {
                  return SizedBox(
                    width: itemW,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 126.h,
                          decoration: BoxDecoration(
                            color: c.surface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        10.verticalSpace,
                        bar(itemW * 0.7, 14.h),
                        8.verticalSpace,
                        bar(itemW * 0.5, 12.h),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The centered "Coming soon" card.
class _ComingSoonCard extends StatelessWidget {
  const _ComingSoonCard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: c.controlBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppGradients.brand,
            ),
            child: Icon(Icons.hourglass_top_rounded,
                size: 34.sp, color: Colors.white),
          ),
          20.verticalSpace,
          Text(
            'coming_soon'.tr(),
            textAlign: TextAlign.center,
            style: AppText.bold18.copyWith(color: c.textPrimary),
          ),
          8.verticalSpace,
          Text(
            'coming_soon_desc'.tr(),
            textAlign: TextAlign.center,
            style: AppText.regular14.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

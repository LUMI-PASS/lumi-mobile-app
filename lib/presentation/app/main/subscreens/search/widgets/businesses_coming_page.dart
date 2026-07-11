import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lumi_pass/common/gen/assets.gen.dart';
import 'package:lumi_pass/common/styles/app_color_scheme.dart';
import 'package:lumi_pass/common/styles/app_colors.dart';
import 'package:lumi_pass/common/styles/app_gradients.dart';
import 'package:lumi_pass/common/styles/app_text_styles.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/cubit/search_state.dart';
import 'package:lumi_pass/presentation/app/main/subscreens/search/widgets/search_widgets.dart';

/// "Coming soon" screen for the Учреждения / Muassasalar bottom-nav tab.
///
/// The tab is not a search screen yet, but it should not read as an empty one
/// either. So it renders the *real* branch grid — real photos, real names,
/// fetched by the cubit on tab 1 — frosted behind a blur, with a crisp card on
/// top. The user sees exactly what is coming, just out of reach.
class BusinessesComingPage extends StatelessWidget {
  const BusinessesComingPage({super.key, required this.state});

  final SearchBuildable state;

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
            // A root tab has nothing behind it, so the bar carries the tab's
            // name and no back button.
            SearchTopBar(title: 'tab_explore'.tr()),
            16.verticalSpace,
            Expanded(
              // Load-bearing: a BackdropFilter frosts its entire layer, not
              // just its own bounds. Without this clip the blur climbs over the
              // top bar and smears the title away.
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned.fill(child: _BranchBackdrop(state: state)),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: ColoredBox(
                          color: c.scaffoldBg.withValues(alpha: 0.55),
                        ),
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

/// The real search layout, rendered with real branches and made inert.
///
/// Falls back to plain surface tiles while the branches are still loading (or
/// if the request failed) so the blur always has something behind it — an
/// empty backdrop would leave the card floating on a bare scaffold.
class _BranchBackdrop extends StatelessWidget {
  const _BranchBackdrop({required this.state});

  final SearchBuildable state;

  /// Same extents the live branch grid uses in [SearchView].
  static const _branchCardExtent = 185.0;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final branches = state.branches;
    final columnWidth = (1.sw - 32.w - 8.w) / 2;

    return IgnorePointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The field is real, but inert — nothing here takes input.
          SearchBarRow(initialTerm: '', onChanged: (_) {}),
          16.verticalSpace,
          SearchMapCard(onTap: () {}),
          24.verticalSpace,
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 14.h,
                mainAxisExtent: _branchCardExtent.h,
              ),
              itemCount: branches.isEmpty ? 6 : branches.length,
              itemBuilder: (context, index) {
                if (branches.isEmpty) return _PlaceholderTile(c: c);
                return SearchBranchCard(
                  key: ValueKey(branches[index].id ?? index),
                  branch: branches[index],
                  width: columnWidth,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Stand-in tile for when there are no branches to show behind the blur.
class _PlaceholderTile extends StatelessWidget {
  const _PlaceholderTile({required this.c});

  final AppColorScheme c;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
    );
  }
}

/// The crisp card that sits on top of the frost.
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
        // Lifts the card clear of the frost so it reads as sitting *above* the
        // blurred grid rather than being part of it.
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: c.isDark ? 0.35 : 0.10),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
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
            child: Assets.icons.time.svg(
              width: 32.w,
              height: 32.w,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
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
